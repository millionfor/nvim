local M = {}

local uname = vim.uv.os_uname()
M.os = uname.sysname
M.is_mac = (M.os == "Darwin")
M.is_linux = (M.os == "Linux")
M.is_windows = (M.os == "Windows_NT" or vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1)

--- 使用系统默认查看器打开文件或 URL
--- @param path string
function M.open_file(path)
    if not path or path == "" then return end
    local escaped_path = path:gsub("'", "'\\''")
    
    if M.is_mac then
        vim.cmd("silent !/usr/bin/open '" .. escaped_path .. "'")
    elseif M.is_linux then
        vim.cmd("silent !xdg-open '" .. escaped_path .. "' >/dev/null 2>&1 &")
    elseif M.is_windows then
        vim.cmd("silent !start '' '" .. escaped_path .. "'")
    else
        vim.notify("未知的操作系统类型，无法打开文件: " .. path, vim.log.levels.WARN)
    end
end

--- 平台专用环境与特性初始化
function M.setup()
    if M.is_mac then
        local ok, mac = pcall(require, "platform.mac")
        if ok and mac.setup then
            mac.setup()
        end
    elseif M.is_linux then
        local ok, linux = pcall(require, "platform.linux")
        if ok and linux.setup then
            linux.setup()
        end
    end
end

return M
