local G = require('G')

G.map({
    { 'v', 'C', ':<c-u>VECHO<cr>', {silent = true, noremap = true}},
})

G.g.vim_echo_by_ft = { vim = 'echo(%s)', go = 'fmt.Println(%s)', vue = 'console.log(`logger-%s`, %s)', js = 'console.log(`logger-%s`, %s)', ts = 'console.log(%s)', sh = 'echo $%s' }
