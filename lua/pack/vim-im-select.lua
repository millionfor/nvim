
local G = require('G')
local M = {}


function M.config()
  G.g.im_select_get_im_cmd = { 'im-select' }
  G.g.im_select_default = 'com.apple.keylayout.ABC'
end

function M.setup()
    -- do nothing
end

return M




