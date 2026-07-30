-- Copilot Chat. Uses the same auth as copilot.lua (`:Copilot auth`).
-- `:CopilotChatModels` lists every model the account can reach.

local curl = require('CopilotChat.utils.curl')

-- WORKAROUND for "Model not found: <id>" on every request.
--
-- The stock provider filters GitHub's /models response on
-- `model.model_picker_enabled`, but GitHub now returns false for that field on
-- *every* model and marks user-facing ones with `model_picker_category`
-- instead. The stock filter therefore matches nothing, the model table comes
-- back empty, and CopilotChat.client:ask() dies on its first lookup -- even
-- for its own default model.
--
-- This is the upstream implementation with the stale field swapped out, plus
-- a policy check so we only list models the account may actually use. Drop
-- this whole override once upstream fixes the filter.
local function get_models(headers)
  local base_url = headers['x-copilot-base-url'] or 'https://api.githubcopilot.com'
  local request_headers = vim.tbl_extend('force', headers, {['x-copilot-base-url'] = nil})

  local response, err = curl.get(base_url .. '/models', {
    json_response = true,
    headers = request_headers,
  })

  if err then
    error(err)
  end

  local models = vim
    .iter(response.body.data)
    :filter(function(model)
      return model.capabilities.type == 'chat'
        -- was: model.model_picker_enabled
        and model.model_picker_category ~= nil
        -- Only models already cleared for this account. Upstream POSTs to
        -- /policy to auto-enable the rest; skipped deliberately so loading
        -- the model list never changes account state on its own.
        and (not model.policy or model.policy.state == 'enabled')
    end)
    :map(function(model)
      local supported_endpoints = model.supported_endpoints or {}

      return {
        id = model.id,
        name = model.name,
        tokenizer = model.capabilities.tokenizer,
        max_input_tokens = model.capabilities.limits.max_prompt_tokens,
        max_output_tokens = model.capabilities.limits.max_output_tokens,
        streaming = model.capabilities.supports.streaming,
        tools = model.capabilities.supports.tool_calls,
        policy = true,
        version = model.version,
        multiplier = model.billing and model.billing.multiplier or nil,
        use_responses = vim.tbl_contains(supported_endpoints, '/responses'),
        base_url = base_url,
      }
    end)
    :totable()

  -- Keep only the newest version of each display name, as upstream does.
  local name_map = {}
  for _, model in ipairs(models) do
    if not name_map[model.name] or model.version > name_map[model.name].version then
      name_map[model.name] = model
    end
  end

  models = vim.tbl_values(name_map)

  -- Auto model selector. Note it can still resolve to a model outside the
  -- list above, which errors -- pick a model explicitly if that happens.
  table.insert(models, {
    id = 'auto',
    name = 'Auto (Copilot)',
    description = 'Auto selects the best model for your request.',
    base_url = base_url,
  })

  return models
end

require('CopilotChat').setup({
  -- This account's plan (sku `free_educational_quota`) only serves a subset of
  -- the advertised models; the rest return HTTP 400 `model_not_supported`.
  -- Verified working: gpt-4.1, gpt-4o, gpt-4o-mini, gpt-3.5-turbo.
  -- Verified refused: gpt-5-mini (the plugin default), claude-*, gemini-*.
  -- Nothing in the /models payload distinguishes the two sets, so this is
  -- pinned by hand rather than filtered.
  model = 'gpt-4.1',

  -- Merged into the built-in copilot provider; every other function on it
  -- (get_headers, resolve_model, get_url, ...) is left untouched.
  providers = {
    copilot = {
      get_models = get_models,
    },
  },

  window = {
    layout = 'vertical',
    width = 0.4,
  },
})
