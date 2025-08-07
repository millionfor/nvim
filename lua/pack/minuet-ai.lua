

local G = require('G')
local M = {}

function M.config()
end

function M.setup()
    require('minuet').setup {
      rovider = 'claude'
    }
end

return M

