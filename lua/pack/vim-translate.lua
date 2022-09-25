
local G = require('G')

G.g['translate#default_languages'] = { ['zh-CN']='en', ['en']='zh-CN' }

G.map({
  { 'n', 'M', ":TranslateVisual<CR>", {silent = true} },
  { 'v', 'mm', ":TranslateReplace<CR>", {silent = true} },
})

