local G = require('G')
local M = {}

function M.config()
    -- keep default completion mark unless customized later
    G.g.vim_dadbod_completion_mark = '[DB]'
end

function M.setup()
    local group = vim.api.nvim_create_augroup('VimDadbodCompletion', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = { 'sql', 'mysql', 'plsql' },
        callback = function()
            vim.bo.omnifunc = 'vim_dadbod_completion#omni'
        end,
    })
end

return M

