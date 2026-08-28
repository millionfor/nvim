local M = {}

--- 配置 Linux / Debian 专属环境变量与路径
local function setup_env()
    local priority_paths = {
        vim.fn.expand("$HOME/.local/bin"),
        vim.fn.expand("$HOME/.cargo/bin"),
        "/usr/local/bin",
    }

    local current_path = vim.env.PATH or ""
    vim.env.PATH = table.concat(priority_paths, ":") .. ":" .. current_path
end

--- 剪贴板环境校验与适配 (xclip / wl-clipboard / OSC52)
local function setup_clipboard()
    local has_xclip = (vim.fn.executable("xclip") == 1)
    local has_wlcopy = (vim.fn.executable("wl-copy") == 1)
    local has_xsel = (vim.fn.executable("xsel") == 1)

    -- 如果没有检测到系统剪切板工具且在无头/SSH终端，可启用 Neovim 0.10+ 内置 OSC52 剪切板
    if not has_xclip and not has_wlcopy and not has_xsel then
        if vim.g.clipboard == nil and vim.fn.has("nvim-0.10") == 1 then
            vim.g.clipboard = {
                name = 'OSC 52',
                copy = {
                    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
                    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
                },
                paste = {
                    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
                    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
                },
            }
        end
    end
end

--- Linux 输入法自动切换适配 (fcitx5 / fcitx)
local function setup_input_method()
    local im_cmd = nil
    if vim.fn.executable("fcitx5-remote") == 1 then
        im_cmd = "fcitx5-remote"
    elseif vim.fn.executable("fcitx-remote") == 1 then
        im_cmd = "fcitx-remote"
    end

    if not im_cmd then
        return
    end

    local im_group = vim.api.nvim_create_augroup("LinuxInputMethodSwitch", { clear = true })
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = im_group,
        pattern = "*",
        callback = function()
            -- -c 关闭输入法/切换至英文
            vim.fn.jobstart({ im_cmd, "-c" }, { detach = true })
        end,
    })
end

--- Linux / Debian 专用初始化
function M.setup()
    setup_env()
    setup_clipboard()
    setup_input_method()
end

return M
