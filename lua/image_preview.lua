local M = {}

local current_state = {
    filepath = nil,
    zoom = 1.0,
    win_id = nil,
    buf_id = nil,
}

local IMAGE_EXTS = {
    png = true,
    jpg = true,
    jpeg = true,
    gif = true,
    webp = true,
    bmp = true,
    ico = true,
    svg = true,
    avif = true,
    tiff = true,
    tif = true,
    heic = true,
    hdr = true,
}

--- 判断是否为图片文件
--- @param path string
--- @return boolean
function M.is_image(path)
    if not path or path == "" then return false end
    local ext = vim.fn.fnamemodify(path, ":e"):lower()
    return IMAGE_EXTS[ext] == true
end

--- 获取当前背景色的 Hex 字符串（用于透明通道混合）
local function get_bg_hex()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    if normal and normal.bg then
        return string.format("#%06x", normal.bg)
    end
    return "#1e1e1e"
end

--- 关闭当前图片预览弹窗
function M.close()
    if current_state.win_id and vim.api.nvim_win_is_valid(current_state.win_id) then
        vim.api.nvim_win_close(current_state.win_id, true)
    end
    if current_state.buf_id and vim.api.nvim_buf_is_valid(current_state.buf_id) then
        pcall(vim.api.nvim_buf_delete, current_state.buf_id, { force = true })
    end
    current_state.win_id = nil
    current_state.buf_id = nil
    current_state.filepath = nil
    current_state.zoom = 1.0
end

--- 渲染并刷新弹窗内容
local function render_and_display()
    local filepath = current_state.filepath
    if not filepath or filepath == "" or not vim.fn.filereadable(filepath) then
        return
    end

    local screen_cols = vim.o.columns
    local screen_lines = vim.o.lines

    local max_cols = math.max(math.floor(screen_cols * 0.85) - 4, 30)
    local max_rows = math.max(math.floor(screen_lines * 0.85) - 4, 10)

    local script_path = vim.fn.stdpath("config") .. "/lua/utils/image_render.py"
    local bg_hex = get_bg_hex()

    local out = vim.fn.system({
        "python3",
        script_path,
        filepath,
        tostring(max_cols),
        tostring(max_rows),
        tostring(current_state.zoom),
        bg_hex,
    })

    local ok, data = pcall(vim.json.decode, out)
    if not ok or not data or data.error then
        local err_msg = (data and data.error) or "Failed to decode image preview response"
        vim.notify("图片预览错误: " .. err_msg, vim.log.levels.WARN)
        return
    end

    -- 计算弹窗尺寸与居中位置
    local width = math.max(data.cols, 44)
    local height = data.rows

    -- 避免超过屏幕尺寸
    width = math.min(width, screen_cols - 4)
    height = math.min(height, screen_lines - 4)

    local col = math.max(math.floor((screen_cols - width) / 2), 1)
    local row = math.max(math.floor((screen_lines - height) / 2) - 1, 1)

    local filename = vim.fn.fnamemodify(filepath, ":t")
    local zoom_pct = math.floor(current_state.zoom * 100)

    local title = string.format(" 󰋩 %s [%dx%d %s] ", filename, data.orig_w, data.orig_h, data.size_str)
    local footer = string.format(" [q] 退出 | [+/-] 缩放 (%d%%) | [r] 重置 | [o] 系统查看 | [y] 复制路径 ", zoom_pct)

    local border = {}
    local ok_border, gb = pcall(require, "gradient_border")
    if ok_border and gb.get then
        border = gb.get()
    else
        border = "rounded"
    end

    local win_opts = {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = border,
        title = title,
        title_pos = "center",
        footer = footer,
        footer_pos = "center",
        zindex = 120,
    }

    -- 创建或更新窗口
    local buf
    local win = current_state.win_id

    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, win_opts)
        -- 重新创建 buffer 以避免通道内容重叠
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(win, buf)
        if current_state.buf_id and vim.api.nvim_buf_is_valid(current_state.buf_id) then
            pcall(vim.api.nvim_buf_delete, current_state.buf_id, { force = true })
        end
        current_state.buf_id = buf
    else
        buf = vim.api.nvim_create_buf(false, true)
        current_state.buf_id = buf
        win = vim.api.nvim_open_win(buf, true, win_opts)
        current_state.win_id = win
    end

    -- 设置 buffer 属性
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "image_preview"
    vim.bo[buf].swapfile = false

    -- 窗口外观配置
    vim.wo[win].cursorline = false
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].wrap = false
    vim.wo[win].signcolumn = "no"

    -- 写入 ANSI 真彩色流
    local chan = vim.api.nvim_open_term(buf, {})
    local h_pad = math.max(math.floor((width - data.cols) / 2), 0)
    local pad_str = string.rep(" ", h_pad)

    for _, line in ipairs(data.lines) do
        vim.api.nvim_chan_send(chan, pad_str .. line .. "\r\n")
    end

    -- 确保聚焦并处于 normal 模式
    vim.api.nvim_set_current_win(win)
    vim.cmd("stopinsert")

    -- 绑定按键 (支持 normal 模式与 terminal 模式)
    local map_opts = { buffer = buf, noremap = true, silent = true }
    
    -- 关闭
    for _, key in ipairs({ "q", "<Esc>", "<CR>", "d", "x", "<BS>" }) do
        vim.keymap.set({ "n", "t" }, key, M.close, map_opts)
    end

    -- 放大
    vim.keymap.set({ "n", "t" }, "+", function() M.zoom(0.2) end, map_opts)
    vim.keymap.set({ "n", "t" }, "=", function() M.zoom(0.2) end, map_opts)

    -- 缩小
    vim.keymap.set({ "n", "t" }, "-", function() M.zoom(-0.2) end, map_opts)
    vim.keymap.set({ "n", "t" }, "_", function() M.zoom(-0.2) end, map_opts)

    -- 重置缩放
    vim.keymap.set({ "n", "t" }, "0", M.reset_zoom, map_opts)
    vim.keymap.set({ "n", "t" }, "r", M.reset_zoom, map_opts)

    -- 系统默认查看器打开
    vim.keymap.set({ "n", "t" }, "o", function()
        local escaped_path = filepath:gsub("'", "'\\''")
        vim.cmd("silent !/usr/bin/open '" .. escaped_path .. "'")
        vim.notify("已在系统默认查看器中打开: " .. filename, vim.log.levels.INFO)
    end, map_opts)

    -- 复制路径
    vim.keymap.set({ "n", "t" }, "y", function()
        vim.fn.setreg("+", filepath)
        vim.notify("已复制图片路径: " .. filepath, vim.log.levels.INFO)
    end, map_opts)
end

--- 打开图片预览弹窗
--- @param filepath string
function M.open(filepath)
    if not filepath or filepath == "" then return end
    local abs_path = vim.fn.fnamemodify(filepath, ":p")
    if not vim.fn.filereadable(abs_path) then
        vim.notify("图片文件不可读: " .. abs_path, vim.log.levels.WARN)
        return
    end

    current_state.filepath = abs_path
    current_state.zoom = 1.0
    render_and_display()
end

--- 缩放调整
--- @param delta number
function M.zoom(delta)
    local new_zoom = current_state.zoom + delta
    if new_zoom < 0.2 then new_zoom = 0.2 end
    if new_zoom > 3.0 then new_zoom = 3.0 end
    current_state.zoom = new_zoom
    render_and_display()
end

--- 重置缩放
function M.reset_zoom()
    current_state.zoom = 1.0
    render_and_display()
end

--- 初始化全局设置与 BufReadCmd 拦截
function M.setup()
    -- 创建用户命令
    vim.api.nvim_create_user_command("ImagePreview", function(opts)
        local path = (opts.args and opts.args ~= "") and opts.args or vim.fn.expand("%:p")
        M.open(path)
    end, { nargs = "?", complete = "file", desc = "预览图片弹窗" })

    -- 全局拦截直接打开图片文件（如 :e logo.png 或命令行 nvim logo.png），防止 buffer 显示二进制乱码
    local patterns = {}
    for ext in pairs(IMAGE_EXTS) do
        table.insert(patterns, "*." .. ext)
        table.insert(patterns, "*." .. ext:upper())
    end

    vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = patterns,
        callback = function(ev)
            local filepath = vim.fn.expand("<afile>:p")
            vim.bo[ev.buf].buftype = "nofile"
            vim.bo[ev.buf].bufhidden = "wipe"
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(ev.buf) then
                    pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
                end
                M.open(filepath)
            end)
        end,
        desc = "拦截图片文件读取并展示图片预览弹窗",
    })
end

return M
