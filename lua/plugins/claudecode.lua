-- Claude Code IDE integration. Starts a WebSocket server on 127.0.0.1 that the
-- `claude` CLI connects to -- the same protocol as the VS Code extension -- so
-- Claude sees the current file and selection and proposes edits as diffs here.
--
-- Needs `claude` on $PATH (set `terminal_cmd` to its full path otherwise).
-- `:ClaudeCodeStatus` shows whether a client is connected.
require('claudecode').setup({
  terminal = {
    -- The default, "auto", quietly falls back to a plain :terminal split when
    -- snacks.nvim can't be loaded. Naming it makes that fallback log a warning.
    provider = 'snacks',
  },
})
