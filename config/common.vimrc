" common
set langmenu=en_US.UTF-8

    " 设置leader为\
    " 设置python3对应的目录，你可以手动 export PYTHON=$(which python3) 到你的终端配置中
        let mapleader=","
        let g:python3_host_prog = $PYTHON
    " 自定义模板
        " function! NewFile()
        "     silent! 0r ~/.config/nvim/template/%:e.vim_template
        "     s/vue/\=expand("%:t:r")
        " endfunction
        " autocmd BufNewFile * call NewFile()
        autocmd BufNewFile * silent! 0r ~/.config/nvim/template/vue/%:e.vim_template
" setting
    " 搜索完按esc去掉高亮
        nnoremap <esc><esc> :nohl<cr>
        " nnoremap <esc> :nohl<cr>
    " 模式行
        set modeline
    " 设置命令提示 唯一标识 共享剪贴板
        set showcmd
        set encoding=utf-8
        set wildmenu
        set conceallevel=0
        set clipboard=unnamed
        set clipboard+=unnamedplus
    " 搜索高亮 空格+回车 去除匹配高亮
        set hlsearch
        set showmatch
        noremap <leader> :nohlsearch<CR>
        set incsearch
        set ignorecase
        set smartcase
    " 延迟
        set timeoutlen=400
    " 设置正常删除 光标穿越行
        set backspace=indent,eol,start
        set whichwrap+=<,>,h,
    " 设置鼠标移动
        set mouse=a
        set selection=exclusive
    " 错误无提示音 去除屏幕闪烁
        set vb
        set t_vb=""
        set t_ut=""
        set hidden
    " 不换行
        set nowrap
    " 缩进对齐
        "set cinkeys=0{,0},:,0#,!<Tab>,!^F " emacs 风格的缩进模式并不是每次输入 <Enter> 都缩进，而是只在输入 <Tab> 时才缩进。对此，我建议使用: >
        set autoindent
        set smartindent
        set tabstop=2
        set softtabstop=2
        set shiftwidth=2
        set smarttab
        set expandtab
    " 不自动备份
        set nobackup
        set noswapfile
    " 光标回到上次位置
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    " 持久化撤销
        set undofile
        set undodir=~/.config/nvim/file_logs
    " 折叠
        " set foldenable
        " set foldmethod=manual
        " set foldmethod=indent
        " set foldmethod=marker

        " au BufWinLeave .vimrc silent try | mkview   | endtry
        " au BufWinEnter .vimrc silent try | loadview | endtry
" show
    " 开启256颜色 暗色背景
        set background=dark
        let g:solarized_termcolors = 256
        let g:solarized_termtrans = 1
        colorscheme solarized8_high
    " 命令行高度始终为1 屏幕刷新间隔300
        set cmdheight=1
        set updatetime=300
        set shortmess+=cI
    " 屏幕顶部底部总是保留5行
        set scrolloff=5
    " 不显示模式
        set noshowmode
    " 行号 行高亮 始终显示标记列
        set nu
        set cul
        set signcolumn=yes
    " 设置插入模式时光标变成竖线
        let &t_SI.="\e[5 q"
        let &t_EI.="\e[1 q"
    " 修改分隔符样式
        set fillchars=vert:\|
        set fillchars=stl:\|
        set fillchars=stlnc:\|
    " 总是开启 statusline & tabline
        set laststatus=2
        set showtabline=2
        set textwidth=1000
        set nowrap

" 文件格式默认        
        " au BufNewFile,BufRead *.html,*.js,*.vue,*.ts set tabstop=2
        " au BufNewFile,BufRead *.html,*.js,*.vue,*.ts set softtabstop=2
        " au BufNewFile,BufRead *.html,*.js,*.vue,*.ts set shiftwidth=2
        " au BufNewFile,BufRead *.html,*.js,*.vue,*.ts set expandtab
        " au BufNewFile,BufRead *.html,*.js,*.vue,*.ts set autoindent
        " au BufNewFile,BufRead *.html,*.js,*.vue,*.ts set fileformat=unix

        autocmd FileType typescript setlocal et sta sw=2 sts=2
        autocmd FileType javascriptreact setlocal et sta sw=2 sts=2
        autocmd FileType vue syntax sync fromstart

        let g:syntastic_javascript_checkers = ['eslint']

        vmap "+y :w !pbcopy<CR><CR>
        nmap "+p :r !pbpaste<CR><CR>
