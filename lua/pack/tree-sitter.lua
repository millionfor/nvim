local G = require('G')
local M = {}
function M.parser_bootstrap()
    local parsers = require("nvim-treesitter.parsers")
    local lang = parsers.ft_to_lang(G.api.nvim_eval('&ft'))
    local has_parser = parsers.has_parser(lang)
    if not has_parser then
        G.cmd("try | call execute('TSInstall " .. lang .. "') | catch | endtry")
    end
end

function M.config()
    G.map({
        { 'n', 'H', ':TSHighlightCapturesUnderCursor<CR>', { silent = true, noremap = true } },
        { 'n', 'R', ':write | edit | TSBufEnable highlight<CR>', { silent = true, noremap = true } },
    })
    -- some custom highlights
    G.cmd('match Todo /TODO\\(:.*\\)*/')
end

function M.setup()
    require('nvim-treesitter.configs').setup({
        -- 列举常用语言自动安装parser
        ensure_installed = { 'typescript', 'javascript', 'vue', 'go', 'lua', 'markdown' },
        highlight = {
            enable = true
        },
    })
    M.parser_bootstrap()
    G.cmd([[ au FileType * lua require('pack/tree-sitter').parser_bootstrap() ]])
end

return M
