
local G = require('G')
local M = {}


function M.config()
end

function M.setup()
  G.map({
      { 'x', 'ga', '<Plug>(EasyAlign)', {silent = true, noremap = true}},
      { 'n', 'ga', '<Plug>(EasyAlign)', {silent = true, noremap = true}},
      
      { 'x', 'Ga', '<Plug>(LiveEasyAlign)', {silent = true, noremap = true}},
      { 'n', 'Ga', '<Plug>(LiveEasyAlign)', {silent = true, noremap = true}},
      
  })
end

return M


