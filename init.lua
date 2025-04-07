require('profile')  -- 基础配置
require('packinit') -- 插件配置
require('keymap')   -- 按键配置
require('autocmd')  -- 自动命令配置
require('template') -- 触发模板

-- 保存更新当前时间
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local current_time = os.date("%a, %m %d, %Y %H:%M")
        local line = vim.fn.search("^\\s*\\* @LastModified\\s*\\zs.*", "w")
        if line > 0 then
            vim.fn.setline(line, " * @LastModified    " .. current_time)
        end
    end,
})
