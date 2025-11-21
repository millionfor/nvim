
local G = require('G')
local M = {}

function M.config()
  -- 配置在插件加载前执行，这里可以设置一些全局变量
end

function M.setup()
  -- 插件加载后设置 colorscheme
  G.cmd([[colorscheme onedark]])
end

return M



