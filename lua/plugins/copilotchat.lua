-- Copilot Chat. Uses the same auth as copilot.lua (`:Copilot auth`).
-- `:CopilotChatModels` lists every model the account can reach -- a Pro+
-- subscription unlocks the premium ones there.

require('CopilotChat').setup({
  -- Leave `model` unset to use the account default; override it after
  -- picking one from :CopilotChatModels.
  window = {
    layout = 'vertical',
    width = 0.4,
  },
})
