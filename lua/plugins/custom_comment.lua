local M = {}

local function generate_multiline_header()
    local time = os.date("%Y-%m-%d %H:%M:%S")
    return string.format('Modified by QuanQuan<millionfor@apache.org> %s @Description "comment: xxx"', time)
end

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

function M.comment_code()
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
    
    local ft = vim.bo.filetype
    local is_html, is_css, is_js
    
    if ft == "vue" then
        local target_row = math.floor((start_row + end_row) / 2) - 1
        local target_col = 0
        local sub_lang = get_vue_language_at_cursor(0, target_row, target_col)
        
        is_html = (sub_lang == "html")
        is_css = (sub_lang == "css")
        is_js = (sub_lang == "js")
    else
        is_html = (ft == "html" or ft == "xml" or ft == "markdown")
        is_css = (ft == "css" or ft == "scss" or ft == "less")
        is_js = not is_html and not is_css
    end
    
    local is_lua = (ft == "lua")
    local is_py = (ft == "python")
    local is_sh = (ft == "sh" or ft == "bash" or ft == "zsh")
    
    local is_multiline = #lines > 1
    local tab_str = "  " -- 2 spaces padding
    
    local function is_already_commented()
        if is_multiline then
            local first = vim.trim(lines[1])
            local last = vim.trim(lines[#lines])
            if is_html then
                return first:match("^<!%-%-.*QuanQuan.*") and last:match("^%-%->")
            elseif is_css or is_js then
                return first:match("^/%*.*QuanQuan.*") and last:match("^%*/$") or last:match("^%*/%s*$")
            elseif is_lua then
                return first:match("^%-%-%[%[.*QuanQuan.*") and last:match("^%]%]$") or last:match("^%]%]%s*$")
            elseif is_py then
                return first:match('^"""(.*)QuanQuan(.*)') and last:match('^"""$') or last:match('^"""%s*$')
            elseif is_sh then
                return first:match("^:%s*<<'EOF'.*QuanQuan.*") and last:match("^EOF$") or last:match("^EOF%s*$")
            end
        else
            local line = lines[1]
            if is_html then
                return line:match("^%s*<!%-%-.*%-%->%s*$")
            elseif is_css then
                return line:match("^%s*/%*.*%*/%s*$")
            elseif is_lua then
                return line:match("^%s*%-%-.*")
            elseif is_py or is_sh then
                return line:match("^%s*#.*")
            else
                return line:match("^%s*//.*")
            end
        end
    end

    local commented_lines = {}
    
    if is_already_commented() then
        if is_multiline then
            for i = 2, #lines - 1 do
                -- Remove the exact `tab_str` prefix if it exists
                local unindented = lines[i]
                if unindented:sub(1, #tab_str) == tab_str then
                    unindented = unindented:sub(#tab_str + 1)
                end
                table.insert(commented_lines, unindented)
            end
        else
            local line = lines[1]
            local leading_space = string.match(line, "^(%s*)") or ""
            local inner = ""
            if is_html then
                inner = string.match(line, "^%s*<!%-%-%s?(.*)%s?%-%->%s*$") or ""
                -- clean up trailing space before -->
                inner = inner:gsub("%s*$", "")
            elseif is_css then
                inner = string.match(line, "^%s*/%*%s?(.*)%s?%*/%s*$") or ""
                inner = inner:gsub("%s*$", "")
            elseif is_lua then
                inner = string.match(line, "^%s*%-%-%s?(.*)$") or ""
            elseif is_py or is_sh then
                inner = string.match(line, "^%s*#%s?(.*)$") or ""
            else
                inner = string.match(line, "^%s*//%s?(.*)$") or ""
            end
            table.insert(commented_lines, leading_space .. inner)
        end
    else
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
        
        if is_multiline then
            local header = generate_multiline_header()
            if is_html then
                table.insert(commented_lines, min_indent .. "<!-- " .. header)
                for _, line in ipairs(lines) do 
                    if vim.trim(line) == "" then table.insert(commented_lines, "") else table.insert(commented_lines, tab_str .. line) end
                end
                table.insert(commented_lines, min_indent .. "-->")
            elseif is_lua then
                table.insert(commented_lines, min_indent .. "--[[ " .. header)
                for _, line in ipairs(lines) do
                    if vim.trim(line) == "" then table.insert(commented_lines, "") else table.insert(commented_lines, tab_str .. line) end
                end
                table.insert(commented_lines, min_indent .. "]]")
            elseif is_py then
                table.insert(commented_lines, min_indent .. '""" ' .. header)
                for _, line in ipairs(lines) do
                    if vim.trim(line) == "" then table.insert(commented_lines, "") else table.insert(commented_lines, tab_str .. line) end
                end
                table.insert(commented_lines, min_indent .. '"""')
            elseif is_sh then
                table.insert(commented_lines, min_indent .. ": <<'EOF' " .. header)
                for _, line in ipairs(lines) do
                    if vim.trim(line) == "" then table.insert(commented_lines, "") else table.insert(commented_lines, tab_str .. line) end
                end
                table.insert(commented_lines, min_indent .. "EOF")
            elseif is_css then
                table.insert(commented_lines, min_indent .. "/* " .. header)
                for _, line in ipairs(lines) do
                    if vim.trim(line) == "" then table.insert(commented_lines, "") else table.insert(commented_lines, tab_str .. line) end
                end
                table.insert(commented_lines, min_indent .. " */")
            else
                table.insert(commented_lines, min_indent .. "/* " .. header)
                for _, line in ipairs(lines) do
                    if vim.trim(line) == "" then
                        table.insert(commented_lines, "")
                    else
                        table.insert(commented_lines, tab_str .. line)
                    end
                end
                table.insert(commented_lines, min_indent .. "*/")
            end
        else
            local line = lines[1]
            if vim.trim(line) ~= "" then
                local leading_space, content = string.match(line, "^(%s*)(.*)")
                if not leading_space then
                    leading_space = ""
                    content = line
                end
                
                if is_html then
                    table.insert(commented_lines, leading_space .. "<!-- " .. content .. " -->")
                elseif is_css then
                    table.insert(commented_lines, leading_space .. "/* " .. content .. " */")
                elseif is_lua then
                    table.insert(commented_lines, leading_space .. "-- " .. content)
                elseif is_py or is_sh then
                    table.insert(commented_lines, leading_space .. "# " .. content)
                else
                    table.insert(commented_lines, leading_space .. "// " .. content)
                end
            end
        end
    end
    
    vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, commented_lines)
end

return {
    "custom_comment",
    virtual = true,
    init = function()
        vim.keymap.set({'n', 'v'}, '?', function() M.comment_code() end, { desc = 'Custom Comment', silent = true })
        vim.keymap.set({'n', 'v'}, '<S-/>', function() M.comment_code() end, { desc = 'Custom Comment', silent = true })
    end,
}
