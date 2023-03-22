local G = require('G')
local M = {}


function M.config()
  G.map({
      { 'v', 'C', ':<c-u>VECHO<cr>', {silent = true, noremap = true}},
  })

  G.g.vim_echo_by_file = { js = 'console.log("logger-[[ECHO]]", [ECHO]);', vue = 'console.log("logger-[[ECHO]]", [ECHO]);', ts = 'console.log("logger-[[ECHO]]", [ECHO]);' }
end

function M.setup()
    -- do nothing
end

return M




