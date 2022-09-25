
local G = require('G')

G.g['prettier#quickfix_enabled'] = 1
G.g['prettier#autoformat'] = 0
G.g['prettier#autoformat_require_pragma'] = 0

G.g['prettier#autoformat_config_files'] = '~/.prettierrc'
G.g['prettier#exec_cmd_path'] = '/usr/local/bin/prettier'


G.map({
  { 'n', '<F3>', ":PrettierAsync<cr>", {silent = true, noremap = true} },
})

