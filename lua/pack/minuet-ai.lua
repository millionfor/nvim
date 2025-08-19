

local G = require('G')
local M = {}
local minuet = require('minuet')

function M.config()
    minuet.setup({
      virtualtext = {
          auto_trigger_ft = {
            -- '*'
          },
          keymap = {
              -- accept whole completion
              accept = '<Tab>',
              -- accept one line
              accept_line = '<A-a>',
              -- accept n lines (prompts for number)
              -- e.g. "A-z 2 CR" will accept 2 lines
              accept_n_lines = '<A-z>',
              -- Cycle to prev completion item, or manually invoke completion
              prev = '<C-Left>',
              -- Cycle to next completion item, or manually invoke completion
              next = '<C-Right>',
              dismiss = '<A-e>',
          },
      },

      throttle = 1000,

      debounce = 200,

      provider = 'claude',

      provider_options = {
        -- Openrouter DeepSeek
        -- openai_compatible = {
        --     api_key = 'OPENROUTER_API_KEY',
        --     end_point = 'https://openrouter.ai/api/v1/chat/completions',
        --     model = 'deepseek/deepseek-chat-v3-0324',
        --     name = 'Openrouter',
        --     optional = {
        --         max_tokens = 256,
        --         top_p = 0.9,
        --         provider = {
        --              -- Prioritize throughput for faster completion
        --             sort = 'throughput',
        --         },
        --     },
        -- },

        -- DeepSeek 慢
        -- openai_fim_compatible = {
        --     model = 'deepseek-chat',
        --     end_point = 'https://api.deepseek.com/beta/completions',
        --     api_key = 'DEEPSEEK_API_KEY',
        --     name = 'Deepseek',
        --     stream = true,
        --     -- a list of functions to transform the endpoint, header, and request body
        --     transform = {},
        --     -- Custom function to extract LLM-generated text from JSON output
        --     get_text_fn = {},
        --     optional = {
        --         stop = nil,
        --         max_tokens = nil,
        --     },
        -- },

        -- Anthropic Claude
        claude = {
            max_tokens = 512,
            model = 'claude-sonnet-4-20250514',
            stream = true,
            api_key = 'ANTHROPIC_API_KEY',
            end_point = 'https://api.anthropic.com/v1/messages',
            optional = {
                -- pass any additional parameters you want to send to claude request,
                -- e.g.
                -- stop_sequences = nil,
            },
        },
      },
    })

    -- vim.cmd("Minuet virtualtext enable")

end

function M.setup()
end

return M

