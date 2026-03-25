local M = {}

-- 获取路径下的所有可能文件
local function get_possible_files(path)
    local extensions = { '', '.vue', '.js', '.ts', '.tsx', '.jsx', '/index.vue', '/index.js', '/index.ts' }
    local files = {}
    for _, ext in ipairs(extensions) do
        table.insert(files, path .. ext)
    end
    return files
end

-- 查找项目根目录 (含有 package.json 或 .git 的目录)
local function get_root()
    return vim.fs.dirname(vim.fs.find({ 'package.json', '.git' }, { upward = true })[1]) or vim.fn.getcwd()
end

function M.jump()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed

    -- 查找光标所在的字符串内容
    local start_pos, end_pos, quote_char
    local search_pos = 1
    while true do
        local s, e, q = line:find([[(['"`])(.-)]]..'%1', search_pos)
        if not s then break end
        if col >= s and col <= e then
            start_pos, end_pos, quote_char = s + 1, e - 1, q
            break
        end
        search_pos = e + 1
    end

    if not start_pos then
        -- 如果没有在字符串内，执行标准的 Lspsaga goto_definition
        vim.cmd('Lspsaga goto_definition')
        return
    end

    local path_str = line:sub(start_pos, end_pos)

    -- 处理别名 @/
    if path_str:sub(1, 2) == '@/' then
        local root = get_root()
        path_str = root .. '/src' .. path_str:sub(2)
    elseif path_str:sub(1, 1) == '.' then
        -- 处理相对路径
        local current_dir = vim.fn.expand('%:p:h')
        path_str = current_dir .. '/' .. path_str
    else
        -- 可能是 node_modules 或者其他，回退
        vim.cmd('Lspsaga goto_definition')
        return
    end

    -- 查找可能的文件
    local found_file = nil
    for _, file in ipairs(get_possible_files(path_str)) do
        if vim.fn.filereadable(file) == 1 then
            found_file = file
            break
        end
    end

    if found_file then
        vim.cmd('e ' .. vim.fn.fnameescape(found_file))
    else
        -- 找不到文件，回退
        vim.cmd('Lspsaga goto_definition')
    end
end

return M
