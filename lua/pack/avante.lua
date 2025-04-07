
local G = require('G')
local M = {}
local avante = require('avante')

function M.config()
  -- 预配置，在插件加载前执行
end

function M.setup()
  avante.setup()
end

return M

