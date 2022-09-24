" Plug
    call plug#begin('~/.config/nvim/plugged')
            " Plug 'yianwillis/vimcdoc'
            " Plug 'terryma/vim-expand-region'
            " Plug 'lfv89/vim-interestingwords'
            " Plug 'mg979/vim-visual-multi', {'branch': 'master'}
            " Plug 'luochen1990/rainbow'
            " Plug 'tpope/vim-dadbod'
            " Plug 'kristijanhusak/vim-dadbod-ui', { 'on': ['DBUI'] }
            " Plug 'pangloss/vim-javascript', {'for': ['javascript', 'vim-plug']}
            " Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm i'  }
            Plug 'neoclide/coc.nvim', {'branch': 'release'}
            " Plug 'voldikss/vim-floaterm' 
        " 翻译
            " Plug 'VincentCordobes/vim-translate'

            " Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
            " Plug 'junegunn/fzf.vim'
            " Plug 'yaocccc/vim-lines'
            " Plug 'yaocccc/vim-surround'
            " Plug 'millionfor/vim-comment'
            " Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
            " Plug 'posva/vim-vue', { 'for': ['vue' ] }
            " Plug 'wincent/vim-clipper'
            " Plug 'scrooloose/syntastic'
            " Plug 'tpope/vim-dadbod'
            " Plug 'kristijanhusak/vim-dadbod-ui', { 'on': ['DBUI'] }
            " Plug 'ojroques/vim-oscyank', {'branch': 'main'}
        " vim 入口封面
            " Plug 'mhinz/vim-startify'
        " 注释插件
            " Plug 'scrooloose/nerdcommenter'
        " typescript-vim
            " Plug 'leafgarland/typescript-vim'
           
        " jsx 支持    
            " Plug 'HerringtonDarkholme/yats.vim'
            " or Plug 'leafgarland/typescript-vim'
            " Plug 'maxmellon/vim-jsx-pretty'

            " Treesitter
            " Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
            " Plug 'nvim-treesitter/playground'
        " 压缩
            " Plug 'Shadowsith/vim-minify'
        " 注释
            " Plug 'tpope/vim-commentary'
            " Plug 'Shougo/context_filetype.vim'
            " Plug 'tyru/caw.vim'
        " post install (yarn install | npm install) then load plugin only for editing supported files
            " Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
    call plug#end()

" Plug Setting
        "     let g:translate#default_languages = {
        "           \ 'zh-CN': 'en',
        "           \ 'en': 'zh-CN'
        "           \ }
        "     vnoremap <silent> M :TranslateVisual<CR>
        "     vnoremap <silent> mm :TranslateReplace<CR>
        " " when running at every change you may want to disable quickfix
        "     let g:prettier#quickfix_enabled = 1
        "     " autocmd TextChanged,InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.svelte,*.yaml,*.html PrettierAsync
        "     let g:prettier#autoformat = 0
        "     let g:prettier#autoformat_require_pragma = 0

        "     :nnoremap <F3> :PrettierAsync <cr>

        "     " 字符串使用单引号
        "     " 尾逗号
        "     " 末尾使用分号
        "     let g:prettier#autoformat_config_files = ["~/.prettierrc"]
        "     let g:prettier#exec_cmd_path = "/usr/local/bin/prettier"


    " defx-icons 配置
            " set encoding=UTF-8


    " vim-startify 封面设置
            "设置书签
            " let g:startify_bookmarks            = [
            " \ '~/Project/test.cpp',
            " \]
            "起始页显示的列表长度
            " let g:startify_files_number = 14
            " "自动加载session
            " let g:startify_session_autoload = 1
            " "过滤列表，支持正则表达式
            " let g:startify_skiplist = [
            " \ '^/tmp',
            " \ ]
            " "自定义Header和Footer
            " let g:startify_custom_header = [
            " \'                                                                               ____                     ____                      _____ _____  ______           ', 
            " \'                                                           █████              / __ \                   / __ \                    |_   _|  __ \|  ____|   /\     ', 
            " \'                                                         ▒██▓  ██▒           | |  | |_   _  __ _ _ __ | |  | |_   _  __ _ _ __     | | | |  | | |__     /  \    ', 
            " \'                                                         ▒██▒  ██░           | |  | | | | |/ _  |  _ \| |  | | | | |/ _  |  _ \    | | | |  | |  __|   / /\ \   ',
            " \'                                                         ░██  █▀ ░           | |__| | |_| | (_| | | | | |__| | |_| | (_| | | | |  _| |_| |__| | |____ / ____ \  ',
            " \'                                                         ░▒███▒█▄             \___\_\\__,_|\__,_|_| |_|\___\_\\__,_|\__,_|_| |_| |_____|_____/|______/_/    \_\ ',
            " \'                                                         ░░ ▒▒░ ▒ ',
            " \'                                                          ░ ▒░  ░            +---------------------------------------------------------------------------------+',
            " \'                                                            ░   ░            |          圈圈(@millionfor) <millionfor@apache.org> wwww.quanquansy.com          |',
            " \'                                                             ░               +---------------------------------------------------------------------------------+',
            " \]

            " let g:startify_list_order = [
            " \ ['   These are my bookmarks:'],
            " \ 'bookmarks',
            " \ ['   My most recently used files'],
            " \ 'files',
            " \ ['   My most recently used files in the current directory:'],
            " \ 'dir',
            " \ ['   These are my session和s:'],
            " \ 'sessions',
            " \]

    " coc-vim
        " 插件列表
            let g:coc_global_extensions=[
                \ 'coc-tsserver',
                \ 'coc-html', 'coc-css',
                \ 'coc-ccls', 'coc-clangd',
                \ 'coc-go',
                \ 'coc-vimlsp',
                \ 'coc-sh',
                \ 'coc-java',
                \ 'coc-json',
                \ 'coc-db',
                \ 'coc-pairs', 'coc-snippets', 'coc-tabnine',
                \ 'coc-word',  'coc-markdownlint',
                \ 'coc-explorer', 'coc-git'
                \ ]
        " maps
            " gist list
            nmap     <silent>       gl     :<c-u>CocList gist<cr>
            " gist.create
            nmap     <silent>       gc     :<c-u>CocCommand gist.create<cr>
            " gist.update
            nmap     <silent>       gu     :<c-u>CocCommand gist.update<cr>
" maps
            nmap     <silent>       <F2>      <Plug>(coc-rename)
            nmap     <silent>       gd        <Plug>(coc-definition)
            nmap     <silent>       gy        <Plug>(coc-type-definition)
            nmap     <silent>       gi        <Plug>(coc-implementation)
            nmap     <silent>       gr        <Plug>(coc-references)
            nmap     <silent>       K         :call CocAction("doHover")<cr>
            nmap     <silent>       <c-e>     :<c-u>CocList diagnostics<cr>
            " gist list
            nmap     <silent>       gl     :<c-u>CocList gist<cr>
            " gist.create
            nmap     <silent>       gc     :<c-u>CocCommand gist.create<cr>
            " gist.update
            nmap     <silent>       gu     :<c-u>CocCommand gist.update<cr>

            nnoremap <silent>       <F9>      :CocCommand snippets.editSnippets<cr>
            " nnoremap <silent>       <F3>      :silent CocRestart<cr>
            " nnoremap <silent><expr> <F4>      get(g:, 'coc_enabled', 0) == 1 ? ':CocDisable<cr>' : ':CocEnable<cr>'
 
            inoremap <silent><expr> <TAB>     coc#pum#visible() ? coc#pum#next(1) : col('.') == 1 \|\| getline('.')[col('.') - 2] =~# '\s' ? "\<TAB>" : coc#refresh()
            inoremap <silent><expr> <s-tab>   coc#pum#visible() ? coc#pum#prev(1) : "\<s-tab>"
            inoremap <silent><expr> <cr>      coc#pum#visible() ? coc#_select_confirm() : "\<c-g>u\<cr>"

        " coc-translator
            " nmap     <silent>       M        <Plug>(coc-translator-p)
            " vmap     <silent>       M        <Plug>(coc-translator-pv)
        " coc-git
            nmap     <silent>       (         <Plug>(coc-git-prevchunk)
            nmap     <silent>       )         <Plug>(coc-git-nextchunk)
            vmap     <silent>       ig        <Plug>(coc-git-chunk-inner)
            vmap     <silent>       ag        <Plug>(coc-git-chunk-outer)
            nmap     <silent><expr> C         get(b:, 'coc_git_blame', '') ==# 'Not committed yet' ? "<Plug>(coc-git-chunkinfo)" : "<Plug>(coc-git-commit)"
            nmap     <silent>       <leader>g :call coc#config('git.addGBlameToVirtualText',  !get(g:coc_user_config, 'git.addGBlameToVirtualText', 0))<cr>
        " coc-explorer
            nnoremap <silent>       tt        :CocCommand explorer --preset floating<cr>
            au User CocExplorerOpenPre  hi Pmenu ctermbg=NONE
            au User CocExplorerQuitPost hi Pmenu ctermbg=238
            au User CocExplorerQuitPost echo

    " vim-expand-region 快速选择
        " v扩大选择 V缩小选择
            " vmap     <silent>       v         <Plug>(expand_region_expand)
            " vmap     <silent>       V         <Plug>(expand_region_shrink)

    " rainbow
            " let g:rainbow_active = 1
            " let g:rainbow_conf = {'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta', 'blue', 'yellow', 'cyan', 'magenta']}


" some hook
" cd ~/.config/coc/extensions/node_modules/coc-ccls
" ln -s node_modules/ws/lib lib
" sudo pacman -S the_silver_searcher fd bat
" npm i js-beautify -g

