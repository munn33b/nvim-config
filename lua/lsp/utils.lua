-- LSP helper function

local cmd = vim.cmd

local M = {}

cmd([[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]])
cmd([[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])

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
