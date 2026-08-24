local M = {}

function M.init()
    vim.api.nvim_set_hl(0, "@identifier", { fg = "NONE" })
    vim.api.nvim_set_hl(0, "@variable", { fg = "NONE" })
    vim.api.nvim_set_hl(0, "@function", { fg = "#0087ff" })
    vim.api.nvim_set_hl(0, "@function.call", { fg = "#0087ff" })
    vim.api.nvim_set_hl(0, "@operator", { fg = "#d75f00" })
    vim.api.nvim_set_hl(0, "@keyword.operator", { fg = "#d75f00" })
    vim.api.nvim_set_hl(0, "@property", { fg = "#d78700" })
    vim.api.nvim_set_hl(0, "@field", { fg = "#afd7af" })
    vim.api.nvim_set_hl(0, "@method", { fg = "#d75f00" })
    vim.api.nvim_set_hl(0, "@method.call", { fg = "#ff0000" })
    vim.api.nvim_set_hl(0, "@parameter", { fg = "#ff0000" })
    vim.api.nvim_set_hl(0, "@keyword", { fg = "#ff6666" })
    vim.api.nvim_set_hl(0, "@keyword.function", { fg = "#0087ff" })
    vim.api.nvim_set_hl(0, "@exception", { fg = "#0087ff" })
    vim.api.nvim_set_hl(0, "@statement", { fg = "#d75f00" })
    vim.api.nvim_set_hl(0, "@special", { fg = "#d78700" })
    vim.api.nvim_set_hl(0, "@comment", { fg = "#5faf5f", italic = true })
    vim.api.nvim_set_hl(0, "@include", { fg = "#800000" })
    vim.api.nvim_set_hl(0, "@type", { fg = "#d7af5f" })
    vim.api.nvim_set_hl(0, "@type.builtin", { fg = "#afd7af" })
    vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = "#afd7d7" })
    vim.api.nvim_set_hl(0, "@constructor", { fg = "#d78700" })
    vim.api.nvim_set_hl(0, "@namespace", { fg = "#d78700" })
    vim.api.nvim_set_hl(0, "@string", { fg = "#00afaf" })
    vim.api.nvim_set_hl(0, "@number", { fg = "#00afaf" })
    vim.api.nvim_set_hl(0, "@boolean", { fg = "#00afaf" })
    vim.api.nvim_set_hl(0, "@tag", { fg = "#d78700" })
    vim.api.nvim_set_hl(0, "@tag.attribute", { fg = "#d75f00" })
    vim.api.nvim_set_hl(0, "@tag.delimiter", { fg = "#afd7af" })
    vim.api.nvim_set_hl(0, "@conditional.ternary", { fg = "#800000" })
    vim.api.nvim_set_hl(0, "@punctuation.special", { fg = "#d78700" })
    vim.api.nvim_set_hl(0, "@text.literal", { fg = "#c0c0c0" })
    vim.api.nvim_set_hl(0, "@text.todo.unchecked", { fg = "#d78700" })
    vim.api.nvim_set_hl(0, "@text.todo.checked", { fg = "#00afaf" })
    vim.api.nvim_set_hl(0, "@markup.heading.1", { fg = "#87d7ff", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.2", { fg = "#00afff", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.3", { fg = "#afafff", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.4", { fg = "#d78700", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.5", { fg = "#d7af5f", bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading.6", { fg = "#ff0000", bold = true })
    vim.api.nvim_set_hl(0, "@markup.raw.block@label", { fg = "#008000" })
    vim.api.nvim_set_hl(0, "@markup.raw.block", { fg = "#c0c0c0" })
    vim.api.nvim_set_hl(0, "@markup.quote", { fg = "#5faf5f", italic = true })
    vim.api.nvim_set_hl(0, "@markup.italic", { italic = true })
    vim.api.nvim_set_hl(0, "@markup.bold", { bold = true })
    vim.api.nvim_set_hl(0, "@markup.strikethrough", { strikethrough = true })
    vim.api.nvim_set_hl(0, "@markup.link", { fg = "#afafff", underline = true })
    vim.api.nvim_set_hl(0, "@markup.list", { fg = "#5fafd7" })
    vim.api.nvim_set_hl(0, "Todo", { fg = "#1c1c1c", bg = "#00afd7", bold = true })
    vim.api.nvim_set_hl(0, "TodoText", { fg = "#00afd7", bg = 'NONE', bold = true })
    vim.api.nvim_set_hl(0, "Note", { fg = "#1c1c1c", bg = "#5fd787", bold = true })
    vim.api.nvim_set_hl(0, "NoteText", { fg = "#5fd787", bg = 'NONE', bold = true })
end

function M.start_treesitter(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    
    local ft = vim.bo[bufnr].filetype
    if not ft or ft == "" or ft == "lazy" or ft == "mason" or ft == "NvimTree" then return end

    -- 大文件保护（超过 100KB 禁用 treesitter 高亮，防止卡顿）
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" then
        local ok_stat, stats = pcall(vim.uv.fs_stat, name)
        if ok_stat and stats and stats.size > 100 * 1024 then
            return
        end
    end

    local ok = pcall(vim.treesitter.start, bufnr)
    if ok then
        -- 启动 Treesitter 后关闭 Vim 传统慢速正则语法高亮，避免重复双重渲染卡顿
        vim.bo[bufnr].syntax = ""
    end
end

function M.config()
    require('nvim-treesitter').setup()

    -- 自动配置 autotag
    pcall(function()
        require('nvim-ts-autotag').setup()
    end)

    -- 监听文件类型与读取事件，启动高性能 Treesitter 高亮
    local group = vim.api.nvim_create_augroup("TreeSitterStarter", { clear = true })
    vim.api.nvim_create_autocmd({ "FileType", "BufReadPost" }, {
        group = group,
        callback = function(args)
            M.start_treesitter(args.buf)
        end,
    })

    M.start_treesitter()
end

return {
    "nvim-treesitter/nvim-treesitter",
    build = ':TSUpdate',
    dependencies = { 'windwp/nvim-ts-autotag' },
    init = M.init,
    config = M.config,
    M = M,
}
