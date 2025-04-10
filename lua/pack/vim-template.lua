local G = require('G')
local M = {}


function M.config()
    -- 设置模板目录
    G.g.templates_directory = G.fn.stdpath('config') .. '/config/templates'
    
    -- 设置模板变量
    G.g.templates_global_name_prefix = 'template'
    
    -- 设置模板变量
    G.g.templates_user_variables = {
    }
    
end

function M.setup()
    -- 这里可以添加插件加载后的配置

end

return M

