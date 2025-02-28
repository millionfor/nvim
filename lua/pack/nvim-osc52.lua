
-- https://github.com/ojroques/nvim-osc52
-- lua/pack/nvim-osc52.lua
-- a机器与b机器copy内容

local G = require('G')
local M = {}


function M.config()
end

function M.setup()
  require('osc52').setup({
    max_length = 0,           -- Maximum length of selection (0 for no limit)
    silent = false,           -- Disable message on successful copy
    trim = false,             -- Trim surrounding whitespaces before copy
    tmux_passthrough = false, -- Use tmux passthrough (requires tmux: set -g allow-passthrough on)
  })
end

return M




