
" }}}

" vimdiff {{{1

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
endif

set diffopt+=vertical
set diffopt+=iwhite " ignore whitespace

" diff buffers in current window
com! -nargs=0 Diff :sil! call s:ToggleDiff()
fun! s:ToggleDiff()
  if exists('b:diff') && b:diff
    let b:diff = 0
    windo diffoff | set nowrap
  else
    let b:diff = 1
    windo diffoff | diffthis
  endif
endfun

if has('win32')
  set diffexpr=MyDiff()
  fun! MyDiff()
    let opt='-a --binary '
    if &diffopt =~ 'icase' | let opt=opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt=opt . '-b ' | endif
    let arg1=v:fname_in
    if arg1 =~ ' ' | let arg1='"' . arg1 . '"' | endif
    let arg2=v:fname_new
    if arg2 =~ ' ' | let arg2='"' . arg2 . '"' | endif
    let arg3=v:fname_out
    if arg3 =~ ' ' | let arg3='"' . arg3 . '"' | endif
    let eq=''
    if $VIMRUNTIME =~ ' '
      if &sh =~ '\<cmd'
        let cmd='""' . $VIMRUNTIME . '\diff"'
        let eq='"'
      else
        let cmd=substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
      endif
    else
      let cmd=$VIMRUNTIME . '\diff'
    endif
    sil! exec '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
  endfun
endif

if &diff
  map <leader>1 :diffget LOCAL<CR>
  map <leader>2 :diffget BASE<CR>
  map <leader>3 :diffget REMOTE<CR>
endif
" }}}



" Format the statusline
set statusline=\ %m%r%h%w<%r%{__get_cur_dir()}%h>\%=\[%{&ft},%{&ff},%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ [%l,%v,0x%B\/%L,%p%%]
fun! __get_cur_dir()
  let p = substitute(getcwd(), fnameescape($HOME), "~", "g")
  let f = expand("%f")
  return p . "/" . f
endfun
