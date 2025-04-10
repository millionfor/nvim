
local G = require('G')
local M = {}


function M.config()
    -- 设置模板目录
    G.g.tmpl_search_paths = G.fn.stdpath('config') .. '/config/templates'

    G.g.tmpl_author_name = 'QuanQuan'
    G.g.tmpl_author_email = 'millionfor@apache.org'
    G.g.tmpl_author_hostname = 'quanquan.app'
end

function M.setup()
    -- 这里可以添加插件加载后的配置

end

return M

