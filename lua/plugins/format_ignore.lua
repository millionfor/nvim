local M = {}

--- 获取 Vue 文件中指定位置的子语言类型
--- @param bufnr number 缓冲区编号
--- @param row number 行号 (0-indexed)
--- @param col number 列号 (0-indexed)
--- @return string 语言类型 ("js", "css", "html")
local function get_vue_language_at_cursor(bufnr, row, col)
    local has_ts, ts = pcall(require, "vim.treesitter")
    if not has_ts then return "html" end
    
    local ok, parser = pcall(ts.get_parser, bufnr)
    if not ok or not parser then return "html" end
    
    -- 解析语法树并获取当前位置的节点
    local root = parser:parse()[1]:root()
    local node = root:named_descendant_for_range(row, col, row, col)
    
    -- 向上遍历父节点以确定所属的 Vue 层级
    while node do
        local type = node:type()
        if type == "script_element" then return "js" end
        if type == "style_element" then return "css" end
        if type == "template_element" then return "html" end
        node = node:parent()
    end
    
    return "html"
end

--- 为选中的代码行包裹 eslint/prettier 忽略注释
function M.wrap_format_ignore()
    local mode = vim.api.nvim_get_mode().mode
    local start_row, end_row
    
    -- 处理视觉模式下的选择范围
    if mode:match("[vV\x16]") then
        start_row = vim.fn.line("v")
        end_row = vim.fn.line(".")
        -- 退出视觉模式以应用更改
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    else
        start_row = vim.fn.line(".")
        end_row = start_row
    end
    
    -- 确保 start_row 小于 end_row
    if start_row > end_row then
        start_row, end_row = end_row, start_row
    end
    
    -- 获取缓冲区内容
    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    if #lines == 0 then return end
    
    -- 如果只有一行且为空，则不处理
    if #lines == 1 and vim.trim(lines[1]) == "" then
        return
    end

    local ft = vim.bo.filetype
    local is_html
    
    -- 针对 Vue 文件进行特殊处理，检测当前所在区域
    if ft == "vue" then
        local target_row = math.floor((start_row + end_row) / 2) - 1
        local target_col = 0
        local sub_lang = get_vue_language_at_cursor(0, target_row, target_col)
        is_html = (sub_lang == "html")
    else
        -- 其他常见 HTML 类似文件
        is_html = (ft == "html" or ft == "xml" or ft == "markdown")
    end

    -- 找到选中行中的最小缩进，以便对齐注释
    local min_indent = nil
    for _, line in ipairs(lines) do
        if vim.trim(line) ~= "" then
            local indent = string.match(line, "^%s*")
            if not min_indent or #indent < #min_indent then
                min_indent = indent
            end
        end
    end
    min_indent = min_indent or ""

    local new_lines = {}
    local indent_str = min_indent
    
    -- 构造新的行列表，包裹忽略注释
    -- TODO: 如果是 HTML 模式，可能需要使用 <!-- --> 注释
    table.insert(new_lines, indent_str .. "/* eslint-disable */")
    table.insert(new_lines, indent_str .. "/* prettier-ignore */")
    for _, line in ipairs(lines) do
        -- 保持原有内容的相对缩进
        if string.match(line, "^" .. vim.pesc(min_indent)) then
            local content = string.sub(line, #min_indent + 1)
            table.insert(new_lines, indent_str .. content)
        else
            table.insert(new_lines, line)
        end
    end
    table.insert(new_lines, indent_str .. "/* eslint-enable */")

    -- 将修改后的内容写回缓冲区
    vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, new_lines)
end

return {
    "format_ignore",
    virtual = true,
    init = function()
        -- 绑定快捷键 'E'，在普通模式和视觉模式下均生效
        vim.keymap.set({'n', 'v'}, 'E', function() M.wrap_format_ignore() end, { desc = 'Format Ignore (eslint/prettier)', silent = true })
    end,
}
