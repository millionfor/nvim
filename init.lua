require('profile')  -- 基础配置
require('packinit') -- 插件配置
require('keymap')   -- 按键配置
require('autocmd')  -- 自动命令配置

-- 保存更新当前时间
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        -- 保存当前光标位置
        local current_pos = vim.api.nvim_win_get_cursor(0)
        local current_time = os.date("%a, %m %d, %Y %H:%M:%S CST")
        
        -- 尝试JavaScript风格的注释
        local line = vim.fn.search("^\\s*\\* @LastModified\\s*\\zs.*", "wn")
        if line > 0 then
            vim.fn.setline(line, " * @LastModified    " .. current_time)
        else
            -- 尝试shell风格的注释
            line = vim.fn.search("^\\s*#\\s*LastModified\\s*\\zs.*", "wn")
            if line > 0 then
                vim.fn.setline(line, "# LastModified     " .. current_time)
            end
        end
        
        -- 恢复光标位置
        vim.api.nvim_win_set_cursor(0, current_pos)
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

-- 关闭当前 buffer 同时切换到右边的 buffer，如果右边没有则切换到最后一个
vim.api.nvim_set_keymap('n', 'sd', '', {
  noremap = true,
  silent = true,
  callback = function()
    local current_buf = vim.api.nvim_get_current_buf()
    local bufs = vim.api.nvim_list_bufs()
    local valid_bufs = {}
    
    -- 过滤出有效的 buffer（已加载且可切换的）
    for _, buf in ipairs(bufs) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, 'buflisted') then
        table.insert(valid_bufs, buf)
      end
    end
    
    if #valid_bufs <= 1 then
      -- 只有一个或没有 buffer，直接关闭
      vim.cmd('bd')
      return
    end
    
    -- 找到当前 buffer 在列表中的位置
    local current_idx = nil
    for i, buf in ipairs(valid_bufs) do
      if buf == current_buf then
        current_idx = i
        break
      end
    end
    
    if current_idx then
      -- 如果右边有 buffer，切换到右边的
      if current_idx < #valid_bufs then
        vim.api.nvim_set_current_buf(valid_bufs[current_idx + 1])
      else
        -- 右边没有（当前是最后一个），切换到倒数第二个（即列表中的最后一个有效 buffer）
        if #valid_bufs > 1 then
          vim.api.nvim_set_current_buf(valid_bufs[#valid_bufs - 1])
        end
      end
    end
    
    -- 关闭原来的 buffer
    vim.cmd('bd ' .. current_buf)
  end
})

-- 只剩一个 buffer 时自动退出
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local wins = vim.api.nvim_list_wins()
    if #wins > 1 then
      vim.cmd("q!")  -- 保存所有文件并退出
    end
  end,
})

-- 驼峰转下划线
vim.keymap.set('v', '<leader>c', ':s/\\v([a-z])([A-Z])/\\1-\\l\\2/g<CR>', { noremap = true })

-- nvim-dap 配置（延迟加载，确保在正确的工作目录中初始化）
vim.defer_fn(function()
  local ok, dap_ui = pcall(require, 'pack.nvim-dap-ui')
  if ok then
    dap_ui.setup()
  end
end, 100)  -- 延迟 100ms 加载，确保 Neovim 完全启动


vim.g.gist_comment_templates = {
  lua = {
    "-- GistID: %Gist_ID%",
    "-- GistURL: https://gist.github.com/%Gist_ID%",
    "",
  },
  typescript = {
    "/**",
    " * GistID: %Gist_ID%",
    " * GistURL: https://gist.github.com/%Gist_ID%",
    " */",
    "",
  },
}
