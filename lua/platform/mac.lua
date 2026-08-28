local M = {}

--- 配置 macOS 专属环境变量与路径
local function setup_env()
    local extra_paths = {
        "/opt/homebrew/bin",
        "/opt/homebrew/sbin",
        "/usr/local/bin",
        vim.fn.expand("$HOME/.local/bin"),
        vim.fn.expand("$HOME/.cargo/bin"),
    }

    local current_path = vim.env.PATH or ""
    local new_paths = {}

    for _, p in ipairs(extra_paths) do
        if vim.fn.isdirectory(p) == 1 and not string.find(":" .. current_path .. ":", ":" .. p .. ":", 1, true) then
            table.insert(new_paths, p)
        end
    end

    if #new_paths > 0 then
        vim.env.PATH = table.concat(new_paths, ":") .. ":" .. current_path
    end
end

--- 配置 macOS 专属输入法自动切换 (macism)
local function setup_input_method()
    local has_macism = (vim.fn.executable("macism") == 1)
    if not has_macism then
        return
    end

    local im_group = vim.api.nvim_create_augroup("MacInputMethodSwitch", { clear = true })

    -- 切换回窗口或 buffer 时切回英文输入法
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
        group = im_group,
        callback = function()
            vim.fn.jobstart({ "macism", "com.apple.keylayout.ABC" }, { detach = true })
        end,
    })

    -- 离开插入模式时自动切回英文输入法
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = im_group,
        pattern = "*",
        callback = function()
            vim.fn.jobstart({ "macism", "com.apple.keylayout.ABC" }, { detach = true })
        end,
    })
end

--- macOS 专用初始化
function M.setup()
    setup_env()
    setup_input_method()
end

return M
