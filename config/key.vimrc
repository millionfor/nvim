" common
    " 设置s t 无效 ;=: ,重复上一次宏操作
        map      s <nop>
        map      ; :
        map      ! :!
        nnoremap + <c-a>
        nnoremap _ <c-x>
        nnoremap , @@
        
    " cmap
        cnoremap <c-a> <home>
        cnoremap <c-e> <end>
        
    " c-s = :%s/
        nnoremap <c-s>    :<c-u>%s/\v//gc<left><left><left><left>
        xnoremap <c-s>          :s/\v//gc<left><left><left><left>
        snoremap <c-s>     <c-g>:s/\v//gc<left><left><left><left>

    " only change text
        snoremap          y     <c-g>y
        xnoremap          <BS>       "_d
        snoremap          <BS>  <c-g>"_d
        nnoremap          x          "_x
        xnoremap          x          "_x
        snoremap          x     <c-g>"_x
        nnoremap          Y           y$
        xnoremap          c          "_c
        snoremap <silent> c     <c-g>"_c
        xnoremap <silent> p          :<c-u>exe col("'>") == col("$") && !<SID>isSelectLines() ? 'norm! gv"_dp' : 'norm! gv"_dP'<cr>
        snoremap <silent> p     <c-g>:<c-u>exe col("'>") == col("$") && !<SID>isSelectLines() ? 'norm! gv"_dp' : 'norm! gv"_dP'<cr>
        xnoremap <silent> P          "_dP
        snoremap <silent> P     <c-g>"_dP
        
        func! s:isSelectLines()
            return col("'<") == 1 && col("'>") == len(getline(line("'>"))) + 1
        endf

    " S保存 Q退出 R重载vim配置 jj=esc
        command! W w !sudo tee > /dev/null %
        nnoremap <silent> S     :w<CR>
        nnoremap <silent> Q     :q!<CR>
        nnoremap <silent> R     :source ~/.config/nvim/init.vim<CR>:echo 'reloaded'<CR>
        inoremap          jj    <Esc>l

    " 重写Shift + 左右
        xnoremap <s-right>      e
        inoremap <s-right> <esc>ea

    " VISUAL SELECT模式 s-tab tab左右缩进
        xnoremap <            <gv
        xnoremap >            >gv
        snoremap <       <c-g><gv
        snoremap >       <c-g>>gv
        xnoremap <s-tab>      <gv
        xnoremap <tab>        >gv
        snoremap <s-tab> <c-g><gv
        snoremap <tab>   <c-g>>gv

    " SHIFT + 方向 选择文本
        inoremap <s-up>    <esc>vk
        inoremap <s-down>  <esc>vj
        nnoremap <s-up>         Vk
        nnoremap <s-down>       Vj
        xnoremap <s-up>         k
        xnoremap <s-down>       j
        snoremap <s-up>    <esc>Vk
        snoremap <s-down>  <esc>Vj
        nnoremap <s-left>       vh
        nnoremap <s-right>      vl

    " CTRL SHIFT + 方向 快速跳转
        inoremap <silent> <c-s-up>    <up><up><up><up><up><up><up><up><up><up>
        inoremap <silent> <c-s-down>  <down><down><down><down><down><down><down><down><down><down>
        inoremap <silent> <c-s-left>  <home>
        inoremap <silent> <c-s-right> <end>
        nnoremap          <c-s-up>    10k
        nnoremap          <c-s-down>  10j
        nnoremap          <c-s-left>  ^
        nnoremap          <c-s-right> $
        vnoremap          <c-s-up>    10k
        vnoremap          <c-s-down>  10j
        vnoremap          <c-s-left>  ^
        vnoremap          <c-s-right> $

    " 选中全文
        nnoremap <m-a>     ggVG
        nnoremap <leader>y :%yank<CR>

    " ctrl u 清空一行
        nnoremap <c-u> cc<Esc>
        inoremap <c-u> <Esc>cc

    " alt kj 上下移动行
        nnoremap <silent> <m-j> :m .+1<CR>
        nnoremap <silent> <m-k> :m .-2<CR>
        inoremap <silent> <m-j> <Esc>:m .+1<CR>i
        inoremap <silent> <m-k> <Esc>:m .-2<CR>i
        xnoremap <silent> <m-j> :m '>+1<CR>gv
        xnoremap <silent> <m-k> :m '<-2<CR>gv
        snoremap <silent> <m-j> <c-g>:m '>+1<CR>gv
        snoremap <silent> <m-k> <c-g>:m '<-2<CR>gv

    " alt + key 操作
        inoremap <m-d> <Esc>"_ciw
        inoremap <m-r> <Esc>"_ciw
        inoremap <m-o> <Esc>o
        inoremap <m-O> <Esc>O
        nnoremap <m-d>      "_diw
        nnoremap <m-r>      "_ciw

" windows
    " su 新左右窗口 sc关闭当前 so关闭其他 s方向切换
        nnoremap su       :vsp<CR>
        nnoremap sc       :close<CR>
        nnoremap so       :only<CR>
        nnoremap s<Left>  <c-w>h
        nnoremap s<Right> <c-w>l
        nnoremap s=       <c-w>=
        nnoremap s.       <c-w>10>
        nnoremap s,       <c-w>10<

" buffers
        nnoremap <silent> ss        :bn<CR>
        nnoremap <silent> sp        :bp<CR>
        nnoremap <silent> <c-left>  :bp<CR>
        nnoremap <silent> <c-right> :bn<CR>
        nnoremap <silent><expr> W   ":bd \|call SetTabline()<CR>"

" 一键运行文件
    command! Run  call <SID>runFile()
    noremap  <F5> :Run<CR>
    inoremap <F5> <ESC>:Run<CR>
    func! s:runFile()
        exec "w"
        if &filetype == 'javascript' | exec 'w !node %'
        elseif &filetype == 'typescript' | exec 'w !ts-node %'
        elseif &filetype == 'python' | exec 'w !python %'
        elseif &filetype == 'go' | exec 'w !go run %'
        elseif &filetype == 'java' | exec 'w !javac %' | exec 'w !java %<'
        elseif &filetype == 'markdown' | exec 'MarkdownPreview'
        endif
    endf

" 重设tab长度
    command! -nargs=* SetTab call <SID>switchTab(<q-args>)
    func! s:switchTab(tab_len)
        if !empty(a:tab_len)
            let [&shiftwidth, &softtabstop, &tabstop] = [a:tab_len, a:tab_len, a:tab_len]
        else
            let l:tab_len = input('input shiftwidth: ')
            if !empty(l:tab_len)
                let [&shiftwidth, &softtabstop, &tabstop] = [l:tab_len, l:tab_len, l:tab_len]
            endif
        endif
        redraw!
        echo printf('shiftwidth: %d', &shiftwidth)
    endf

" 折叠
    nnoremap <silent><expr> -- foldclosed(line('.')) == -1 ? ':call <SID>fold()<cr>' : 'za'
    xnoremap - zf
    snoremap - <c-g>zf
    func! s:fold()
        let l:line = trim(getline('.'))
        if l:line == '' | return | endif
        let [l:up, l:down] = [0, 0]
        if l:line[0] == '}'
            exe 'norm! ^%'
            let l:up = line('.')
            exe 'norm! %'
        endif
        if l:line[len(l:line) - 1] == '{'
            exe 'norm! $%'
            let l:down = line('.')
            exe 'norm! %'
        endif
        try
            if l:up != 0 && l:down != 0
                exe 'norm! ' . l:up . 'GV' . l:down . 'Gzf'
            elseif l:up != 0
                exe 'norm! V' . l:up . 'Gzf'
            elseif l:down != 0
                exe 'norm! V' . l:down . 'Gzf'
            else
                exe 'norm! za'
            endif
        catch
            redraw!
        endtry
    endf

" tab 行首行尾切换
    nnoremap <silent> <tab> :call <SID>move()<cr>
    nnoremap 0 %
    vnoremap 0 %

    func! s:move()
        let [l:first, l:head] = [1, len(getline('.')) - len(substitute(getline('.'), '^\s*', '', 'g')) + 1]
        let l:before = col('.')
        exe l:before == l:first && l:first != l:head ? 'norm! ^' : 'norm! $'
        let l:after = col('.')
        if l:before == l:after
            exe 'norm! 0'
        endif
    endf

" format
    vnoremap <silent><expr> = index(['js', 'ts', 'json'], expand('%:e')) == -1 ? '=' : ':!js-beautify<CR>'
    nnoremap <silent><expr> = index(['js', 'ts', 'json'], expand('%:e')) == -1 ? '=' : ':.!js-beautify<CR>'
