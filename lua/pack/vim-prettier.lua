
local G = require('G')
local M = {}


function M.config()
  G.g['prettier#quickfix_enabled'] = 1
  G.g['prettier#autoformat'] = 0
  G.g['prettier#autoformat_require_pragma'] = 0

  G.g['prettier#autoformat_config_files'] = '~/.prettierrc'
  G.g['prettier#exec_cmd_path'] = '/usr/local/bin/prettier'


  G.map({
    { 'n', 'pr', ":PrettierAsync<cr>", {silent = true, noremap = true} },
  })
end

function M.setup()
    -- do nothing
end

return M


