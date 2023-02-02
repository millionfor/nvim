
local G = require('G')
local M = {}


function M.config()
  G.g['translate#default_languages'] = { ['zh-CN']='en', ['en']='zh-CN' }

  G.map({
    { 'n', 'M', ":TranslateVisual<CR>", {silent = true} },
    { 'v', 'mm', ":TranslateReplace<CR>", {silent = true} },
  })
end

function M.setup()
    -- do nothing
end

return M



