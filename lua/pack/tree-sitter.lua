local G = require('G')
local nvim_treesitter_config = require('nvim-treesitter.configs')

require("nvim-treesitter.install").prefer_git = true

nvim_treesitter_config.setup {
    ensure_installed = 'all',
    ignore_install = { "swift", "phpdoc" },

    highlight = {
        enable = false,
        additional_vim_regex_highlighting = false,
        disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
    },
    incremental_selection = {
      enable = true,
    },
}

G.map({ { 'n', 'H', ':TSHighlightCapturesUnderCursor<CR>', {silent = true, noremap = true}} })

-- some custom highlights
G.cmd('match Todo /TODO\\(:.*\\)*/')
