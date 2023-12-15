

local G = require('G')
local M = {}


function M.config()
    G.g.jsdoc_formatter = 'tsdoc'

    G.map({
      { 'n', '<leader>z', '<Plug>(jsdoc)', { noremap = true, silent = true } },

      { 'v', 'zz', ":JsDoc<cr>", { noremap = true } },
    })

    G.cmd('autocmd BufRead,BufNewFile *.vue,*.ts,*.js setlocal filetype=javascript.html')

end

function M.setup()
    -- do nothing
end

return M



