

local G = require('G')
local M = {}


function M.config()
    -- g.g.jsdoc_formatter = 'jsdoc'

    G.map({
      { 'n', '<leader>z', '<Plug>(jsdoc)', { noremap = true, silent = true } },

      { 'v', 'zz', ":JsDoc<cr>", { noremap = true } },
    })

    G.cmd('autocmd BufRead,BufNewFile *.vue setlocal filetype=javascript.html')

end

function M.setup()
    -- do nothing
end

return M



