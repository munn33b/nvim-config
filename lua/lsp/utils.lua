-- LSP helper function

local cmd = vim.cmd

local M = {}

cmd([[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]])
cmd([[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])

-- Registers the buffer-local setup below on LspAttach.
--
-- NOTE: deliberately not passed as `on_attach` to vim.lsp.config('*'). Nvim
-- resolves a server config as
--   tbl_deep_extend('force', config['*'], <runtimepath lsp/*.lua>, <per-server>)
-- so a server definition that ships its own on_attach (nvim-lspconfig does for
-- pyright, among others) silently overwrites the wildcard one. LspAttach is
-- additive, so every client gets it.
function M.setup()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('user_lsp_attach', {clear = true}),
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      -- Copilot & friends attach to every buffer but serve none of these
      -- requests -- don't let them install the keymaps.
      if not client or not client:supports_method('textDocument/definition') then
        return
      end

      M.common_on_attach(client, args.buf)
    end,
  })
end

-- This function defines the on_attach function for several languages which share the same key-bidings
function M.common_on_attach(client, bufnr)
  -- Set omnifunc (Nvim 0.11 also does this on attach, kept for clarity)
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

  -- Helper function
  local opts = {noremap = true, silent = true}
  local function bufnnoremap(lhs, rhs)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, opts)
  end

  -- Keymaps: we need to define keymaps for each of the LSP functionalities manually
  -- Go to definition and declaration (use leader to presever standard use of 'gd')
  bufnnoremap("<leader>gd", "<Cmd>lua vim.lsp.buf.definition()<CR>")
  bufnnoremap("<leader>gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>")

  -- Go to implementation
  bufnnoremap("<leader>gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>")

  -- List symbol uses
  -- bufnnoremap("<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>")  -- Uses quickfix
  bufnnoremap("<leader>gr", "<cmd>Telescope lsp_references<CR>")  -- Uses Telescope

  -- Inspect function
  bufnnoremap("K", "<Cmd>lua vim.lsp.buf.hover()<CR>")

  -- Signature help
  bufnnoremap("<A-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>")

  -- Rename all references of symbol
  bufnnoremap("<leader>R", "<Cmd>lua vim.lsp.buf.rename()<CR>")

  -- Navigate diagnostics
  bufnnoremap("<C-n>", "<Cmd>lua vim.diagnostic.goto_next()<CR>")
  bufnnoremap("<C-p>", "<Cmd>lua vim.diagnostic.goto_prev()<CR>")

  -- Markdown preview TODO: make this conditional, but I also don't use it all that much
  -- bufnnnoremap("<leader>P", "<Cmd>Glow<CR>")

  -- NOTE: this branch has never fired -- the capability was renamed to
  -- `documentFormattingProvider` back in Nvim 0.8, so format-on-save is off.
  -- Rename the field below to turn it on.
  if client.server_capabilities.document_formatting then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function() vim.lsp.buf.format({async = false}) end,
    })
  end
end

return M
