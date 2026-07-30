-- Server setup using the Nvim 0.11+ API (`vim.lsp.config` / `vim.lsp.enable`).
-- The per-server definitions (cmd, filetypes, root markers) come from the
-- `lsp/` directory that nvim-lspconfig puts on the runtimepath, so there is no
-- `require('lspconfig')` here -- that "framework" is deprecated.

local utils = require('lsp.utils')

local servers = {"intelephense", "bashls", "clangd", "pyright", "jsonls", "dockerls"}

-- Must run first: this is what puts ~/.local/share/nvim/mason/bin on $PATH,
-- so the servers below are found when they start.
require('mason').setup()

-- add capabilities from nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Capabilities are safe to merge into every server config; the buffer-local
-- keymaps are registered via LspAttach instead (see lua/lsp/utils.lua).
vim.lsp.config('*', {
  capabilities = capabilities,
})

utils.setup()

-- Installs anything in `servers` that is missing, and enables the ones that
-- are present (`automatic_enable` defaults to true). Use `:Mason` to browse.
require('mason-lspconfig').setup({
  ensure_installed = servers,
})

-- Also enable explicitly, so servers installed outside mason (system packages)
-- still start. Harmless for the ones mason-lspconfig already enabled.
vim.lsp.enable(servers)

-- require('lsp.sumneko')

-- signature help hover
require "lsp_signature".setup({ })
