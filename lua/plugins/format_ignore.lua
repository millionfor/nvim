local M = {}

local function get_vue_language_at_cursor(bufnr, row, col)
    local has_ts, ts = pcall(require, "vim.treesitter")
    if not has_ts then return "html" end
    
    local ok, parser = pcall(ts.get_parser, bufnr)
    if not ok or not parser then return "html" end
    
    local root = parser:parse()[1]:root()
    local node = root:named_descendant_for_range(row, col, row, col)
    
    while node do
        local type = node:type()
        if type == "script_element" then return "js" end
        if type == "style_element" then return "css" end
        if type == "template_element" then return "html" end
        node = node:parent()
    end
    
    return "html"
end

function M.wrap_format_ignore()
    local mode = vim.api.nvim_get_mode().mode
    local start_row, end_row
    
    if mode:match("[vV\x16]") then
        start_row = vim.fn.line("v")
        end_row = vim.fn.line(".")
        -- Exit visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    else
        start_row = vim.fn.line(".")
        end_row = start_row
    end
    
    if start_row > end_row then
        start_row, end_row = end_row, start_row
    end
    
    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    if #lines == 0 then return end
    
    -- If there's only one line and it's empty, do nothing
    if #lines == 1 and vim.trim(lines[1]) == "" then
        return
    end

    local ft = vim.bo.filetype
    local is_html
    
    if ft == "vue" then
        local target_row = math.floor((start_row + end_row) / 2) - 1
        local target_col = 0
        local sub_lang = get_vue_language_at_cursor(0, target_row, target_col)
        is_html = (sub_lang == "html")
    else
        is_html = (ft == "html" or ft == "xml" or ft == "markdown")
    end

    -- Find minimum indentation
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
    
    table.insert(new_lines, indent_str .. "/* eslint-disable */")
    table.insert(new_lines, indent_str .. "/* prettier-ignore */")
    for _, line in ipairs(lines) do
        if string.match(line, "^" .. vim.pesc(min_indent)) then
            local content = string.sub(line, #min_indent + 1)
            table.insert(new_lines, indent_str .. content)
        else
            table.insert(new_lines, line)
        end
    end
    table.insert(new_lines, indent_str .. "/* eslint-enable */")

    
    vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, new_lines)
end

return {
    "format_ignore",
    virtual = true,
    init = function()
        vim.keymap.set({'n', 'v'}, 'E', function() M.wrap_format_ignore() end, { desc = 'Format Ignore', silent = true })
    end,
}
