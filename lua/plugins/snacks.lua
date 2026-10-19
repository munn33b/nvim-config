-- snacks.nvim: a collection of small plugins (terminal, picker, dashboard, ...).
-- Used here as the terminal claudecode.nvim opens Claude in. Snacks.terminal
-- works without being enabled, so nothing below needs to be on for that.
--
-- Every other module is opt-in: add `<name> = { enabled = true }` to the table.
-- A few duplicate plugins this config already runs -- dashboard (alpha-nvim),
-- explorer (nvim-tree) and picker (Telescope) -- so swap rather than stack.
-- `:checkhealth snacks` verifies the setup.
require('snacks').setup({})
