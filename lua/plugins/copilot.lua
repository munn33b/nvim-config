-- GitHub Copilot inline suggestions (ghost text)
-- Run `:Copilot auth` once to sign in, `:Copilot status` to check the session.

-- The Copilot language server needs Node 22.13+, but nvm may have an older
-- version active. Pick the newest qualifying install out of nvm and fall back
-- to whatever `node` resolves to on $PATH.
local COPILOT_MIN_NODE = {22, 13, 0}

local function copilot_node()
  local versions = vim.fn.glob(vim.fn.expand('~/.nvm/versions/node') .. '/v*', false, true)
  table.sort(versions, function(a, b)
    return vim.version.lt(vim.fn.fnamemodify(b, ':t'), vim.fn.fnamemodify(a, ':t'))
  end)
  for _, dir in ipairs(versions) do
    local version = vim.version.parse(vim.fn.fnamemodify(dir, ':t'))
    if version
      and not vim.version.lt(version, COPILOT_MIN_NODE)
      and vim.fn.executable(dir .. '/bin/node') == 1
    then
      return dir .. '/bin/node'
    end
  end
  return 'node'
end

require('copilot').setup({
  copilot_node_command = copilot_node(),

  panel = {
    enabled = true,
    auto_refresh = false,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>",
    },
    layout = {position = "bottom", ratio = 0.4},
  },

  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    -- <Tab> is already taken by nvim-cmp/luasnip and <C-l> by window
    -- navigation, so Copilot stays on the Alt-key defaults.
    keymap = {
      accept = "<M-l>",
      accept_word = "<M-w>",
      accept_line = "<M-j>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },

  -- Filetypes where inline suggestions are unwanted
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
  },
})
