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

--- 配置 iTerm2 / 终端工作目录自动同步 (OSC 7 & OSC 1337)
--- 解决 iTerm2 分屏 (Cmd+D / Cmd+Shift+D) 时无法继承 Neovim 当前项目根路径的问题
local function setup_iterm2_cwd_sync()
    local zsh_cache_dir = vim.fn.expand("~/.config/zsh/cache")
    local zsh_cache_file = zsh_cache_dir .. "/currentdir"

    -- 常见工程与构建标记列表
    local root_markers = {
        ".git",
        "package.json",
        "pnpm-workspace.yaml",
        "Cargo.toml",
        "go.mod",
        "pom.xml",
        "build.gradle",
        "pyproject.toml",
        "Makefile",
        ".root",
    }

    --- 向上递归探测指定路径所属的项目根目录（严格保证返回项目根路径，而非子目录）
    local function find_project_root(start_path)
        if not start_path or start_path == "" then
            start_path = vim.fn.getcwd()
        end
        if vim.fn.filereadable(start_path) == 1 then
            start_path = vim.fs.dirname(start_path)
        end
        if vim.fn.isdirectory(start_path) ~= 1 then
            start_path = vim.fn.getcwd()
        end

        -- 1. 优先使用 Git 根目录（最权威的项目根路径）
        local git_root = vim.fs.root(start_path, ".git")
        if git_root then
            return git_root
        end

        -- 2. 其次匹配工程文件根目录（package.json, Cargo.toml 等）
        local project_root = vim.fs.root(start_path, root_markers)
        if project_root then
            return project_root
        end

        -- 3. 若从当前文件未找到，尝试从 Neovim 当前工作目录向上寻找
        local cwd = vim.fn.getcwd()
        local cwd_git = vim.fs.root(cwd, ".git")
        if cwd_git then
            return cwd_git
        end
        local cwd_root = vim.fs.root(cwd, root_markers)
        if cwd_root then
            return cwd_root
        end

        -- 4. 兜底返回当前 getcwd()
        return cwd
    end

    --- 获取当前活跃窗口/buffer 所属的项目根目录
    local function get_active_project_root()
        local buftype = vim.bo.buftype
        local bufname = vim.api.nvim_buf_get_name(0)

        -- 1. 处理 NvimTree 插件目录
        if vim.bo.filetype == "NvimTree" then
            local ok, api = pcall(require, "nvim-tree.api")
            if ok then
                local node = api.tree.get_node_under_cursor()
                if node and node.absolute_path then
                    return find_project_root(node.absolute_path)
                end
            end
        end

        -- 2. 常规文件 buffer
        if buftype == "" and bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
            return find_project_root(bufname)
        end

        -- 3. 终端 buffer
        if buftype == "terminal" and vim.b.osc7_dir and vim.fn.isdirectory(vim.b.osc7_dir) == 1 then
            return find_project_root(vim.b.osc7_dir)
        end

        -- 4. 兜底使用当前工作目录对应的项目根
        return find_project_root(vim.fn.getcwd())
    end

    local last_reported_dir = nil

    --- 发送转义码给终端并更新 zsh 缓存
    --- @param force boolean 是否强制重新上报（切回聚焦时使用，防止其他终端分屏冲掉路径）
    local function sync_cwd(force)
        local dir = get_active_project_root()
        if not dir or dir == "" or vim.fn.isdirectory(dir) ~= 1 then
            return
        end

        -- 同步 Neovim 自身进程的 CWD 到项目根目录
        -- 使得 macOS 内核层面的进程嗅探 (proc_pidinfo) 拿到的也是精准的项目根路径
        if vim.fn.getcwd() ~= dir then
            pcall(vim.fn.chdir, dir)
        end

        -- 非强制模式下，相同目录不重复发送
        if not force and dir == last_reported_dir then
            return
        end
        last_reported_dir = dir

        -- 1. 构造 OSC 7 (通用终端标准) 与 OSC 1337 (iTerm2 专用) 转义序列
        local hostname = vim.fn.hostname()
        local encoded_dir = dir:gsub("[^%w%-_%.%~/]", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        local osc7 = string.format("\x1b]7;file://%s%s\x07", hostname, encoded_dir)
        local osc1337 = string.format("\x1b]1337;CurrentDir=%s\x07", dir)
        local seq = osc7 .. osc1337

        -- 多通道确保终端必定接收到转义序列
        if vim.api.nvim_ui_send then
            pcall(vim.api.nvim_ui_send, seq)
        end
        if vim.v.stderr then
            pcall(vim.api.nvim_chan_send, vim.v.stderr, seq)
        end
        pcall(function()
            io.stdout:write(seq)
            io.stdout:flush()
        end)

        -- 2. 同步写入 ~/.config/zsh/cache/currentdir 供 zsh hook.zsh 闭环
        if vim.fn.isdirectory(zsh_cache_dir) == 1 then
            local f = io.open(zsh_cache_file, "w")
            if f then
                f:write(dir .. "\n")
                f:close()
            end
        end
    end

    local cwd_group = vim.api.nvim_create_augroup("ItermCwdSync", { clear = true })
    vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "WinEnter", "DirChanged" }, {
        group = cwd_group,
        callback = function()
            vim.schedule(function() sync_cwd(false) end)
        end,
    })

    -- 当分屏切回或聚焦回 Neovim 窗口时，强制刷新一次
    -- 确保如果另一个分屏刚刚执行了 cd，当前 nvim 所在分屏能立刻重新接管记录
    vim.api.nvim_create_autocmd({ "FocusGained" }, {
        group = cwd_group,
        callback = function()
            vim.schedule(function() sync_cwd(true) end)
        end,
    })
end

--- macOS 专用初始化
function M.setup()
    setup_env()
    setup_input_method()
    setup_iterm2_cwd_sync()
end

return M
