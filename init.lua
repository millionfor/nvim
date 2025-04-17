require('profile')  -- 基础配置
require('packinit') -- 插件配置
require('keymap')   -- 按键配置
require('autocmd')  -- 自动命令配置

-- 保存更新当前时间
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local current_time = os.date("%a, %m %d, %Y %H:%M:%S CST")
        -- Try JavaScript-style comment pattern first
        local line = vim.fn.search("^\\s*\\* @LastModified\\s*\\zs.*", "w")
        if line > 0 then
            vim.fn.setline(line, " * @LastModified    " .. current_time)
        else
            -- Try shell-style comment pattern
            line = vim.fn.search("^\\s*#\\s*LastModified\\s*\\zs.*", "w")
            if line > 0 then
                vim.fn.setline(line, "# LastModified     " .. current_time)
            end
        end
    end,
})

-- 自动切换到英文输入法（适用于 Neovim 0.7+）
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
    callback = function()
        os.execute("macism com.apple.keylayout.ABC") -- ABC 是默认英文输入法
    end
})
vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    callback = function()
        vim.fn.system("macism com.apple.keylayout.ABC") -- 切换到英文输入法
    end,
})

-- 关闭当前 buffer 同时切换到上一个
vim.api.nvim_set_keymap('n', 'sd', '', {
  noremap = true,
  silent = true,
  callback = function()
    local buf_count = #vim.api.nvim_list_bufs()
    if buf_count > 1 then
      vim.cmd('bd')
      vim.cmd('bp')
    else
      vim.cmd('bd')
    end
  end
})

function KeepOnlyCurrentBuffer()
    local current_buf = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end

-- 映射快捷键（例如 `<Leader>bo` 表示 "buffer only"）
vim.keymap.set('n', '<Leader>bo', KeepOnlyCurrentBuffer, { desc = "Close all other buffers" })
