
local G = require('G')
local M = {}


function M.config()
  G.cmd([[colorscheme onedark]])
end

function M.setup()
  -- do nothing
  require('onedark').setup {
      style = 'darker'
  }
  require('onedark').load()
end

return M



