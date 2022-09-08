func! ShowMarks(...)
    let bufnr = bufnr()
    if !buflisted(bufnr) | return | endif
    redir => cout
    silent marks
    redir END
    call sign_unplace('*', {'id': s:mark_ns_id})
    let list = sort(filter(split(cout, "\n")[1:], 'v:val[1] =~# "[a-zA-Z]"'))
    let marksByLnum = {}
    for line in list
        let [text, lnum] = filter(split(line, " "), 'v:val != ""')[0:1]
        let marksOflnum = get(marksByLnum, lnum, [])
        let marksOflnum = marksOflnum + [text]
        let marksByLnum[lnum] = marksOflnum
    endfor
    for lnum in keys(marksByLnum)
        let text = join(marksByLnum[lnum], '')
        if len(text) > 2 | let text = marksByLnum[lnum][0] . '…' | endif
        call sign_define('mark_' . text, {'text': text, 'texthl': 'Marks'})
        call sign_place(s:mark_ns_id, '', 'mark_' . text, bufnr, {'lnum': lnum, 'priority': 999})
    endfor
endf

hi Marks ctermfg=80
let s:mark_ns_id = 9898
noremap <unique> <script> \sm m
noremap <silent> m :exe 'norm \sm'.nr2char(getchar())<bar>call ShowMarks()<CR>
au WinEnter,BufWinEnter,CursorHold * call ShowMarks()
