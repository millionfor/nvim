local G = require('G')

G.map({
  { 'n', '<leader>z', '<Plug>(jsdoc)', { noremap = true, silent = true } },

  { 'v', 'zz', ":JsDoc<cr>", { noremap = true } },
})

G.cmd('autocmd BufRead,BufNewFile *.vue setlocal filetype=javascript.html')
