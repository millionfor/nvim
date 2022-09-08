" 正常
vnoremap <buffer><silent> = :!js-beautify -s 2 --space-in-paren --space-in-empty-paren --space-after-anon-function -b collapse,preserve-inline<cr>
nnoremap <buffer><silent> = :.!js-beautify -s 2 --space-in-paren --space-in-empty-paren --space-after-anon-function -b collapse,preserve-inline<cr>

" html 
vnoremap <buffer><silent> hh :!vue-beautify <cr>
nnoremap <buffer><silent> hh :.!vue-beautify <cr>
" js
vnoremap <buffer><silent> jj :!js-beautify -b collapse-preserve-inline<cr>
nnoremap <buffer><silent> jj :.!js-beautify -b collapse-preserve-inline<cr>
" css
vnoremap <buffer><silent> cc :!js-beautify --type css<cr>
nnoremap <buffer><silent> cc :.!js-beautify --type css<cr>


vnoremap <silent><buffer> C :<c-u>call <SID>console()<cr>
func s:console()
    let tag = getline(line("."))[col("'<") - 1 : col("'>") - 2]
    let l = line('.')
    let space = substitute(getline(l), '\v(^\s*).*', '\1', '')

    call appendbufline('%', line('.'), printf(space . 'console.log(`[logger-%s] => `, %s)', tag, tag)) 
endf


