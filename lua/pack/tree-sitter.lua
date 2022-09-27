local G = require('G')
local nvim_treesitter_config = require('nvim-treesitter.configs')

require("nvim-treesitter.install").prefer_git = true

nvim_treesitter_config.setup {
    options = {
      theme = 'onedark',
    },
    ensure_installed = 'all',
    ignore_install = { "swift", "phpdoc" },

    highlight = {
        enable = false,
        additional_vim_regex_highlighting = false
    },
}
G.map({ { 'n', 'H', ':TSHighlightCapturesUnderCursor<CR>', {silent = true, noremap = true}} })
