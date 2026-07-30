-- Server setup using the Nvim 0.11+ API (`vim.lsp.config` / `vim.lsp.enable`).
-- The per-server definitions (cmd, filetypes, root markers) come from the
-- `lsp/` directory that nvim-lspconfig puts on the runtimepath, so there is no
-- `require('lspconfig')` here -- that "framework" is deprecated.

local utils = require('lsp.utils')

-- add capabilities from nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Common settings, merged into every server config
vim.lsp.config('*', {
  on_attach = utils.common_on_attach,
  capabilities = capabilities,
})

-- Enable language servers
vim.lsp.enable({"intelephense", "bashls", "clangd", "pyright", "jsonls", "dockerls"})

-- require('lsp.sumneko')

-- signature help hover
require "lsp_signature".setup({ })
