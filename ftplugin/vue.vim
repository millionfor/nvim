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

