-- Case Converter Plugin for Neovim

local M = {}

-- Split text into individual words
local function get_words(text)
    local words = {}
    if not text or text == "" then return words end
    
    -- Split by separators first: _, -, .
    local temp = text:gsub('[-_.]', ' ')
    -- Then deal with camelCase/PascalCase boundaries
    temp = temp:gsub('(%l)(%u)', '%1 %2')
    temp = temp:gsub('(%u)(%u%l)', '%1 %2') 
    
    for word in temp:gmatch('%S+') do
        table.insert(words, word:lower())
    end
    return words
end

-- Formatters for different case styles
local formatters = {
    ['camelCase'] = function(words)
        if #words == 0 then return "" end
        local res = {words[1]}
        for i = 2, #words do
            table.insert(res, words[i]:sub(1, 1):upper() .. words[i]:sub(2))
        end
        return table.concat(res)
    end,
    ['PascalCase'] = function(words)
        local res = {}
        for _, w in ipairs(words) do
            table.insert(res, w:sub(1, 1):upper() .. w:sub(2))
        end
        return table.concat(res)
    end,
    ['kebab-case'] = function(words)
        return table.concat(words, '-')
    end,
    ['snake_case'] = function(words)
        return table.concat(words, '_')
    end,
    ['SCREAMING_SNAKE_CASE'] = function(words)
        local res = {}
        for _, w in ipairs(words) do
            table.insert(res, w:upper())
        end
        return table.concat(res, '_')
    end,
    ['Train-Case'] = function(words)
        local res = {}
        for _, w in ipairs(words) do
            table.insert(res, w:sub(1, 1):upper() .. w:sub(2))
        end
        return table.concat(res, '-')
    end,
    ['dot.case'] = function(words)
        return table.concat(words, '.')
    end,
    ['flatcase'] = function(words)
        return table.concat(words, '')
    end,
    ['UPPERCASE'] = function(words)
        local res = {}
        for _, w in ipairs(words) do
            table.insert(res, w:upper())
        end
        return table.concat(res, '')
    end,
}

local format_options = {
    'camelCase',
    'PascalCase',
    'kebab-case',
    'snake_case',
    'SCREAMING_SNAKE_CASE',
    'Train-Case',
    'dot.case',
    'flatcase',
    'UPPERCASE',
}

-- Detect word range under cursor in normal mode
local function get_word_range()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    
    local start_col = col
    while start_col > 1 and line:sub(start_col - 1, start_col - 1):match("[%w_.-]") do
        start_col = start_col - 1
    end
    
    local end_col = col
    while end_col <= #line and line:sub(end_col, end_col):match("[%w_.-]") do
        end_col = end_col + 1
    end
    
    return start_col, end_col - 1
end

function M.convert()
    local mode = vim.api.nvim_get_mode().mode
    local start_pos, end_pos, text

    if mode:find('[vV]') then
        -- Visual mode
        local _start = vim.fn.getpos("'<")
        local _end = vim.fn.getpos("'>")
        local line_start, col_start = _start[2], _start[3]
        local line_end, col_end = _end[2], _end[3]
        
        -- Adjust for end of line selection
        local lines = vim.api.nvim_buf_get_text(0, line_start - 1, col_start - 1, line_end - 1, col_end, {})
        text = table.concat(lines, "\n")
        start_pos = {line_start, col_start}
        end_pos = {line_end, col_end}
    else
        -- Normal mode
        local sc, ec = get_word_range()
        local line = vim.api.nvim_get_current_line()
        text = line:sub(sc, ec)
        if text == "" then return end
        
        local row = vim.api.nvim_win_get_cursor(0)[1]
        start_pos = {row, sc}
        end_pos = {row, ec}
    end

    local words = get_words(text)
    if #words == 0 then return end

    vim.ui.select(format_options, {
        prompt = 'Convert "' .. text .. '" to:',
        format_item = function(item)
            return string.format("%-22s (e.g. %s)", item, formatters[item]({ 'user', 'name' }))
        end,
    }, function(choice)
        if not choice then return end
        local new_text = formatters[choice](words)
        
        if mode:find('[vV]') then
            vim.api.nvim_buf_set_text(0, start_pos[1] - 1, start_pos[2] - 1, end_pos[1] - 1, end_pos[2], {new_text})
        else
            vim.api.nvim_buf_set_text(0, start_pos[1] - 1, start_pos[2] - 1, end_pos[1] - 1, end_pos[2], {new_text})
        end
    end)
end

return {
    "case-converter",
    virtual = true,
    dir = vim.fn.stdpath("config") .. "/lua/plugins",
    init = function()
        vim.keymap.set({'n', 'v'}, '<leader>t', function()
            -- Ensure we capture the selection if in visual mode
            if vim.api.nvim_get_mode().mode:find('[vV]') then
                vim.cmd('normal! vv') -- escape to normal to get marks, or just use marks
            end
            M.convert()
        end, { desc = 'Case Converter', silent = true })
    end,
}
