local G = require('G')
G.g.coc_global_extensions = {
    'coc-tsserver',
    '@yaegassy/coc-volar',
    'coc-json',
    'coc-html', 'coc-css',
    'coc-clangd',
    'coc-go',
    'coc-lua',
    'coc-vimlsp',
    'coc-sh', 'coc-db',
    'coc-java', 'coc-pyright',
    'coc-toml', 'coc-solidity',
    'coc-prettier',
    'coc-snippets', 'coc-pairs', 'coc-word',
    'coc-translator',
    'coc-git',
    'coc-gist',
    'coc-vetur'
    -- 'coc-tabnine'
}
G.cmd('autocmd FileType javascript,typescript,json,vue vmap <buffer> = <Plug>(coc-format-selected)')
G.cmd('autocmd FileType javascript,typescript,json,vue nmap <buffer> = <Plug>(coc-format-selected)')
G.cmd("command! -nargs=? Fold :call CocAction('fold', <f-args>)")
G.cmd("hi! link CocPum Pmenu")
G.cmd("hi! link CocMenuSel PmenuSel")

G.map({
    -- { 'n', '<F2>', '<Plug>(coc-rename)', {silent = true} },
    { 'n', 'gd', '<Plug>(coc-definition)', {silent = true} },
    { 'n', 'gy', '<Plug>(coc-type-definition)', {silent = true} },
    { 'n', 'gi', '<Plug>(coc-implementation)', {silent = true} },
    { 'n', 'gr', '<Plug>(coc-references)', {silent = true} },
    { 'n', 'K', ':call CocAction("doHover")<cr>', {silent = true} },
    { 'i', '<TAB>', "coc#pum#visible() ? coc#pum#next(1) : col('.') == 1 || getline('.')[col('.') - 2] =~# '\\s' ? \"\\<TAB>\" : coc#refresh()", {silent = true, noremap = true, expr = true} },
    { 'i', '<s-tab>', "coc#pum#visible() ? coc#pum#prev(1) : \"\\<s-tab>\"", {silent = true, noremap = true, expr = true} },
    { 'i', '<cr>', "coc#pum#visible() ? coc#_select_confirm() : \"\\<c-g>u\\<cr>\\<c-r>=coc#on_enter()\\<cr>\"", {silent = true, noremap = true, expr = true} },
    -- { 'n', '<F3>', ":silent CocRestart<cr>", {silent = true, noremap = true} },
    { 'n', '<F4>', "get(g:, 'coc_enabled', 0) == 1 ? ':CocDisable<cr>' : ':CocEnable<cr>'", {silent = true, noremap = true, expr = true} },
    { 'n', '<F9>', ":CocCommand snippets.editSnippets<cr>", {silent = true, noremap = true} },
    { 'n', '<c-e>', ":CocList diagnostics<cr>", {silent = true} },
    { 'n', 'pp', "<Plug>(coc-translator-p)", {silent = true} },
    { 'v', 'pp', "<Plug>(coc-translator-pv)", {silent = true} },
    { 'n', '(', "<Plug>(coc-git-prevchunk)", {silent = true} },
    { 'n', ')', "<Plug>(coc-git-nextchunk)", {silent = true} },
    { 'n', 'C', "get(b:, 'coc_git_blame', '') ==# 'Not committed yet' ? \"<Plug>(coc-git-chunkinfo)\" : \"<Plug>(coc-git-commit)\"", {silent = true, expr = true} },
    { 'n', '<leader>g', ":call coc#config('git.addGBlameToVirtualText',  !get(g:coc_user_config, 'git.addGBlameToVirtualText', 0)) | call nvim_buf_clear_namespace(bufnr(), -1, line('.') - 1, line('.'))<cr>", {silent = true} },
    -- { 'n', '<c-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : \"\\<C-f>\"',  {silent = true, noremap = true, expr = true, nowait = true} },
    { 'n', '<c-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : \"\\<C-b>\"',  {silent = true, noremap = true, expr = true, nowait = true} },
    -- { 'v', '<c-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : \"\\<C-f>\"',  {silent = true, noremap = true, expr = true, nowait = true} },
    { 'v', '<c-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : \"\\<C-b>\"',  {silent = true, noremap = true, expr = true, nowait = true} },
    -- { 'i', '<c-f>', 'coc#float#has_scroll() ? \"\\<c-r>=coc#float#scroll(1)\\<cr>\" : \"\\<Right>\"',  {silent = true, noremap = true, expr = true, nowait = true} },
    { 'i', '<c-b>', 'coc#float#has_scroll() ? \"\\<c-r>=coc#float#scroll(0)\\<cr>\" : \"\\<Left>\"',  {silent = true, noremap = true, expr = true, nowait = true} },

    { 'n', 'gl', ":CocList gist<cr>", {silent = true, noremap = true} },
    { 'n', 'gc', ":CocCommand gist.create<cr>", {silent = true, noremap = true} },
    { 'n', 'gu', ":CocCommand gist.update<cr>", {silent = true, noremap = true} },
    { 'n', '=', "<Plug>(coc-format-selected)", {silent = true} },
    { 'x', '=', "<Plug>(coc-format-selected)", {silent = true} },
})
