# NVim Configuration

Personal Neovim setup: Lua config, [packer.nvim](https://github.com/wbthomason/packer.nvim)
for plugins, [mason.nvim](https://github.com/mason-org/mason.nvim) for language servers,
and GitHub Copilot for completion and chat.

**Leader key is `<Space>`** (both `mapleader` and `maplocalleader`).

---

## Requirements

| Dependency | Version | Why |
| --- | --- | --- |
| Neovim | **0.11+** | `vim.lsp.config`, `vim.diagnostic.jump`, copilot.lua, Telescope all require it |
| Node.js | **22.13+** | GitHub Copilot language server refuses anything older |
| git, curl, make | any recent | plugin install, CopilotChat, `telescope-fzf-native` |
| A Nerd Font | — | icons in nvim-tree, bufferline, lualine |

Optional:

- `pynvim` at `~/.local/bin/pyenv/versions/pynvim/` — set in `lua/options.lua`.
  Adjust that path or remove it if you don't use pyenv.
- `OPENAI_API_KEY` in your environment — only for ChatGPT.nvim. Without it you get a
  harmless warning on startup.

Node is resolved automatically: `lua/plugins/copilot.lua` scans `~/.nvm/versions/node`
and picks the newest install that satisfies 22.13+, so switching nvm versions per project
won't break Copilot.

---

## Install

```sh
git clone <this-repo> ~/.config/nvim
nvim
```

On first launch packer bootstraps itself and installs everything, then mason installs the
language servers listed in `lua/plugins/lspconfig.lua`. Expect a few hundred MB and a
couple of minutes. Restart when it finishes.

Then authenticate Copilot once:

```vim
:Copilot auth
```

Useful packer commands: `:PackerSync` (install + update + clean), `:PackerStatus`.
`plugins.lua` recompiles automatically on save.

---

## Layout

```
init.lua                 load order: options → keymaps → commands → plugins → themes
lua/
  options.lua            editor settings, diagnostics display, providers
  keymaps.lua            all global keymaps
  commands.lua           user commands and autocommands
  plugins.lua            packer plugin declarations
  themes.lua             colorscheme (loaded last so plugins can't override it)
  utils.lua              nnoremap/vnoremap/inoremap helpers
  lsp/
    utils.lua            LspAttach handler — buffer-local LSP keymaps
    sumneko.lua          dormant lua_ls config, not loaded
  plugins/               one file per plugin's config
```

Per-plugin config lives in `lua/plugins/<name>.lua` and is wired up from the `config`
field of the matching `use({...})` block in `plugins.lua`.

---

## Keymaps

### Files and search (Telescope)

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fhf` | Find files, including hidden |
| `<leader>fb` | Buffers |
| `<leader>fg` | Live grep |
| `<leader>fd` | Diagnostics, current file |
| `<leader>tel` | Telescope pickers menu |
| `<leader>e` | Toggle file tree |

### Windows and buffers

| Key | Action |
| --- | --- |
| `<C-h/j/k/l>` | Move between windows |
| `<leader>ws` / `<leader>vs` | Horizontal / vertical split |
| `<leader>pp` | Widen window by 10 columns |
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<A-w>` | Delete buffer |
| `<C-s>` | Save |
| `<C-c>` | Quit window |

### Editing

| Key | Action |
| --- | --- |
| `Y` | Yank to end of line |
| `<leader>y` | Yank to system clipboard (normal + visual) |
| `<leader><C-v>` | Paste from system clipboard |
| `<leader>s` / `<leader>S` | Substitute in line / file |
| `<leader><C-s>` | Substitute in file, with confirmation |
| `<leader>nh` | Clear search highlight |
| `<leader>xo` | Open current file in default application |

### Terminal (Floaterm)

| Key | Action |
| --- | --- |
| `<leader>t` | Show floating terminal |
| `<leader>l` | Hide floating terminal |
| `<C-x>` | Terminal mode → normal mode |

### Git (fugitive)

| Key | Action |
| --- | --- |
| `<leader>G` | `:Git` status |
| `<leader>gh` | Commit log |

### Lists

| Key | Action |
| --- | --- |
| `<leader>lo` / `<leader>lc` | Open / close location list |
| `<leader>co` / `<leader>cc` | Open / close quickfix |
| `<C-n>` / `<C-p>` | Next / previous location-list entry |
| `<C-N>` / `<C-P>` | Next / previous quickfix entry |

> In a buffer with a language server attached, `<C-n>` / `<C-p>` are overridden
> buffer-locally to jump between diagnostics instead.

### LSP

Active only in buffers with a language server attached.

| Key | Action |
| --- | --- |
| `<leader>gd` / `<leader>gD` | Go to definition / declaration |
| `<leader>gi` | Go to implementation |
| `<leader>gr` | References (Telescope) |
| `K` | Hover |
| `<A-k>` | Signature help |
| `<leader>R` | Rename symbol |
| `<C-n>` / `<C-p>` | Next / previous diagnostic |

### Diagnostics

| Key | Action |
| --- | --- |
| `<leader>d` | Float with the current line's diagnostic |
| `<leader>D` | All diagnostics in this file → location list |
| `<leader><A-d>` | All diagnostics in open buffers → quickfix |
| `<leader>fd` | Diagnostics for this file in Telescope |

Inline display is **off** by default — `lua/options.lua` sets `virtual_text = false` and
`underline = false`, leaving only gutter signs. Flip those to `true` if you want errors
shown in the buffer.

### Completion (nvim-cmp)

| Key | Action |
| --- | --- |
| `<C-Space>` | Open / close completion menu |
| `<Tab>` / `<S-Tab>` | Next / previous item, or jump snippet placeholder |
| `<CR>` | Confirm |
| `<C-d>` / `<C-f>` | Scroll docs |
| `<C-c>` | Close menu |

---

## Language servers

Managed by mason. Configured in `lua/plugins/lspconfig.lua`:

```
intelephense  bashls  clangd  pyright  jsonls  dockerls
```

Add one by appending its lspconfig name to the `servers` table — `ensure_installed`
picks it up on next start. `:Mason` opens the installer UI, `:checkhealth vim.lsp` shows
what's attached to the current buffer.

This config uses the Neovim 0.11 API (`vim.lsp.config` / `vim.lsp.enable`), not the
deprecated `require('lspconfig')` framework. Server definitions come from the `lsp/`
directory that nvim-lspconfig puts on the runtimepath.

Buffer-local keymaps are applied through an `LspAttach` autocmd in `lua/lsp/utils.lua`
rather than an `on_attach` field. This is deliberate — Neovim merges server configs as
`tbl_deep_extend('force', config['*'], <runtimepath config>, <per-server>)`, so a
wildcard `on_attach` is silently discarded for any server whose nvim-lspconfig definition
ships its own (pyright does). The autocmd skips clients that don't serve
`textDocument/definition`, which keeps Copilot from installing LSP keymaps everywhere.

---

## Copilot

Two plugins, one login (`:Copilot auth`).

### Inline suggestions — `copilot.lua`

Ghost text appears automatically as you type.

| Key | Action |
| --- | --- |
| `<M-l>` | Accept suggestion |
| `<M-w>` / `<M-j>` | Accept one word / one line |
| `<M-]>` / `<M-[>` | Next / previous alternative |
| `<C-]>` | Dismiss |
| `<M-CR>` | Open panel with multiple suggestions |

Alt-based on purpose: `<Tab>` belongs to nvim-cmp and `<C-l>` to window navigation.

**Disabled in** `markdown`, `yaml`, `gitcommit`, `gitrebase`, `help`, and svn/hg/cvs
commit buffers — see the `filetypes` table in `lua/plugins/copilot.lua`. If you see no
ghost text, check the filetype first.

Commands: `:Copilot status`, `:Copilot disable`, `:Copilot enable`, `:checkhealth copilot`.

### Chat — `CopilotChat.nvim`

| Key | Action |
| --- | --- |
| `<leader>ct` | Toggle chat window |
| `<leader>cm` | Model picker |
| `<leader>cr` | Review buffer |
| `<leader>cf` | Fix (normal + visual) |
| `<leader>ce` | Explain selection (visual) |

`lua/plugins/copilotchat.lua` contains two deliberate deviations from upstream defaults,
both documented in the file:

1. **`get_models` is overridden.** GitHub now returns `model_picker_enabled: false` on
   every model, and the stock provider filters on exactly that field — producing an empty
   model list and `Model not found: <id>` on every request, including its own default.
   The override filters on `model_picker_category` instead.
2. **`model` is pinned to `gpt-4.1`.** Not every advertised model is actually served;
   the rest return HTTP 400 `model_not_supported`, and nothing in the API response
   distinguishes them. The model picker will still list models that fail — the pinned
   default is what keeps day-to-day use working.

Which models a given account can use depends on its Copilot plan. Re-check with the
picker after a plan change and update the `model` line.

---

## Editor defaults worth knowing

- Relative line numbers, cursorline, always-visible sign column
- 2-space indents, tabs expanded
- `scrolloff = 12` — the cursor stays well away from screen edges
- Spell check **on** (`en_us`); in Neovim it only checks comments and strings
- `hlsearch` off, `ignorecase` + `smartcase` on
- Splits open below and to the right
- Mouse enabled

---

## Troubleshooting

**No Copilot ghost text.** Check the filetype isn't in the disabled list above, then
`:Copilot status`. If a suggestion appears but `<M-l>` won't accept it, your terminal is
probably sending `Esc`+`l` instead of a real Alt keypress — rebind in
`lua/plugins/copilot.lua`.

**No diagnostics.** A language server has to be installed *and* attached. `:Mason` to
check the former, `:checkhealth vim.lsp` for the latter. Remember inline display is off —
use `<leader>d` or `<leader>D`.

**Plugin errors after an update.** `:PackerSync`, then restart. If a git clone times out,
clone it manually into
`~/.local/share/nvim/site/pack/packer/start/` and re-run `:PackerSync`.

**Telescope fzf sorting not working.** `telescope-fzf-native` needs its C library built:

```sh
cd ~/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim && make
```

**`OPENAI_API_KEY variable not set` on startup.** ChatGPT.nvim, harmless. Export the key
or remove the plugin from `plugins.lua`.
