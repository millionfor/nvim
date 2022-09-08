vnoremap <buffer><silent> = :!js-beautify -s 2 --space-in-paren --space-in-empty-paren --space-after-anon-function -b collapse,preserve-inline<cr>
nnoremap <buffer><silent> = :.!js-beautify -s 2 --space-in-paren --space-in-empty-paren --space-after-anon-function -b collapse,preserve-inline<cr>


vnoremap <silent><buffer> C :<c-u>call <SID>console()<cr>
func s:console()
    let tag = getline(line("."))[col("'<") - 1 : col("'>") - 2]
    let l = line('.')
    let space = substitute(getline(l), '\v(^\s*).*', '\1', '')

    call appendbufline('%', line('.'), printf(space . 'console.log(`[logger-%s] => `, %s)', tag, tag)) 
endf

