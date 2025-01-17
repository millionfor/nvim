

local G = require('G')
local M = {}


function M.config()
end

function M.setup()
  require('smear_cursor').setup({
    cursor_color = '#969eab',
  })
end

return M




