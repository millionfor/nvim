local M = {}

function M.config()
    -- 配置默认的翻译语言
    vim.g['translate#default_languages'] = { ['zh-CN'] = 'en', ['en'] = 'zh-CN' }

    local opts = { silent = true }
    
    -- 映射快捷键
    -- 注意: 原配置 'v' 在现代 Neovim 中也可以用 'x'
    vim.keymap.set('n', 'M', ":TranslateVisual<CR>", opts)
    vim.keymap.set('v', 'MM', ":TranslateReplace<CR>", opts)
end

return {
    "VincentCordobes/vim-translate",
    init = M.config,
}
