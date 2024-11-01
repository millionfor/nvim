
local G = require('G')
local M = {}

-- vim ~/.translate-shell/init.trans
-- {
--  :translate-shell "0.9.0"
--  :verbose         false
--  :hl              "en"
--  :tl              "zh"
--  :proxy           "http://127.0.0.1:7890"
-- }


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



