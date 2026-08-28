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

--- 自动加载 QuanQuan.rc 本地用户专属账号密码与密钥配置
local function load_user_rc()
    local rc_file = vim.fn.stdpath("config") .. "/QuanQuan.rc"
    if vim.fn.filereadable(rc_file) ~= 1 then
        return
    end

    local lines = vim.fn.readfile(rc_file)
    for _, line in ipairs(lines) do
        local trimmed = vim.trim(line)
        if trimmed ~= "" and not trimmed:match("^#") then
            local key, val = trimmed:match("^export%s+([%w_]+)%s*=%s*['\"]?(.-)['\"]?$")
            if not key then
                key, val = trimmed:match("^([%w_]+)%s*=%s*['\"]?(.-)['\"]?$")
            end
            if key and val and val ~= "" then
                vim.env[key] = val
                if key == "GITLAB_BASE_URL" then vim.g.gitlab_snippet_base_url = val end
                if key == "GITLAB_TOKEN" then vim.g.gitlab_snippet_token = val end
            end
        end
    end
end

--- 平台专用环境与特性初始化
function M.setup()
    load_user_rc()
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
