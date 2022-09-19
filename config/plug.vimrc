" Plug
    call plug#begin('~/.config/nvim/plugged')
            " Plug 'yianwillis/vimcdoc'
            Plug 'terryma/vim-expand-region'
            Plug 'lfv89/vim-interestingwords'
            " Plug 'mg979/vim-visual-multi', {'branch': 'master'}
            Plug 'luochen1990/rainbow'
            " Plug 'tpope/vim-dadbod'
            " Plug 'kristijanhusak/vim-dadbod-ui', { 'on': ['DBUI'] }
            Plug 'pangloss/vim-javascript', {'for': ['javascript', 'vim-plug']}
            Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm i'  }
            Plug 'neoclide/coc.nvim', {'branch': 'release'}
            " Plug 'voldikss/vim-floaterm' 
        " 翻译
            Plug 'VincentCordobes/vim-translate'

            " Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
            " Plug 'junegunn/fzf.vim'
            " Plug 'yaocccc/vim-lines'
            Plug 'yaocccc/vim-surround'
            Plug 'millionfor/vim-comment'
            " Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
            Plug 'posva/vim-vue', { 'for': ['vue' ] }
            Plug 'wincent/vim-clipper'
            Plug 'scrooloose/syntastic'
            " Plug 'tpope/vim-dadbod'
            " Plug 'kristijanhusak/vim-dadbod-ui', { 'on': ['DBUI'] }
            " Plug 'ojroques/vim-oscyank', {'branch': 'main'}
        " vim 入口封面
            Plug 'mhinz/vim-startify'
        " nvim-tree
            " Plug 'kyazdani42/nvim-web-devicons'
            " Plug 'kyazdani42/nvim-tree.lua'
            
        " NERDTree左侧树形目录
            " Plug 'scrooloose/nerdtree'
        " nerdtree字体图标
            Plug 'ryanoasis/vim-devicons'
        " nerdtree 路径复制到剪切板
            Plug 'mortonfox/nerdtree-clip'
            Plug 'yaocccc/nvim-hlchunk'
        " 注释插件
            Plug 'scrooloose/nerdcommenter'
        " typescript-vim
            " Plug 'leafgarland/typescript-vim'
           
        " jsx 支持    
            Plug 'HerringtonDarkholme/yats.vim'
            " or Plug 'leafgarland/typescript-vim'
            Plug 'maxmellon/vim-jsx-pretty'

            " Treesitter
            Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
            Plug 'nvim-treesitter/playground'
        " 压缩
            Plug 'Shadowsith/vim-minify'
        " 注释
            Plug 'tpope/vim-commentary'
            Plug 'Shougo/context_filetype.vim'
            Plug 'tyru/caw.vim'
        " post install (yarn install | npm install) then load plugin only for editing supported files
            Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }
    call plug#end()

" Plug Setting
            let g:translate#default_languages = {
                  \ 'zh-CN': 'en',
                  \ 'en': 'zh-CN'
                  \ }
            vnoremap <silent> M :TranslateVisual<CR>
            vnoremap <silent> mm :TranslateReplace<CR>
        " when running at every change you may want to disable quickfix
            let g:prettier#quickfix_enabled = 1
            " autocmd TextChanged,InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.svelte,*.yaml,*.html PrettierAsync
            let g:prettier#autoformat = 0
            let g:prettier#autoformat_require_pragma = 0

            :nnoremap <F3> :PrettierAsync <cr>

            " 字符串使用单引号
            " 尾逗号
            " 末尾使用分号
            let g:prettier#autoformat_config_files = ["~/.prettierrc"]
            let g:prettier#exec_cmd_path = "/usr/local/bin/prettier"

    " scrooloose/nerdcommenter
            "   " Create default mappings
            " let g:NERDCreateDefaultMappings = 1

            " " Add spaces after comment delimiters by default
            " let g:NERDSpaceDelims = 1

            " " Use compact syntax for prettified multi-line comments
            " let g:NERDCompactSexyComs = 1

            " " Align line-wise comment delimiters flush left instead of following code indentation
            " let g:NERDDefaultAlign = 'left'

            " " Set a language to use its alternate delimiters by default
            " let g:NERDAltDelims_java = 1

            " " Add your own custom formats or override the defaults
            " let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

            " " Allow commenting and inverting empty lines (useful when commenting a region)
            " let g:NERDCommentEmptyLines = 1

            " " Enable trimming of trailing whitespace when uncommenting
            " let g:NERDTrimTrailingWhitespace = 1

            " " Enable NERDCommenterToggle to check all selected lines is commented or not 
            " let g:NERDToggleCheckAllLines = 1

            " vnoremap <leader>c :OSCYank<CR>
            " let g:oscyank_max_length = 1000000
            " autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | OSCYankReg " | endif
            " autocmd TextYankPost * if v:event.operator is 'p' && v:event.regname is '+' | OSCYankReg + | endif

            autocmd FileType vue syntax sync fromstart
            " autocmd BufRead,BufNewFile *.vue setlocal filetype=vue.html.javascript.css
            let g:vue_pre_processors = 'detect_on_enter'

            au VimEnter * hi IndentLineSign ctermfg=248

          " 支持哪些文件 默认为 '*.ts,*.js,*.json,*.go,*.c'
            let g:hlchunk_files = '*.ts,*.js,*.json,*.go,*.c,*.vue,*.html'
          " 缩进线的高亮
            au VimEnter * hi HLIndentLine ctermfg=244
          " 延时 默认为50
            let g:hlchunk_time_delay = 50
          " 高亮线符号(逆时针) 默认为 ['─', '─', '╭', '│', '╰', '─', '>']
            let g:hlchunk_chars=['─', '─', '╭', '│', '╰', '─', '>']
          " 最大支持行数 默认3000(超过5000行的文件不使用hlchunk)
            let g:hlchunk_line_limit = 5000
          " 最大支持列数 默认100(超过500列的文件不使用hlchunk)
            let g:hlchunk_col_limit = 500

    " 自定义按键
            nmap     <silent>       E         :call Tests("doHover")<cr>

            func Tests()
              call setline(1,"2222") 
            endfunc
    "  " T快速向下打开一个终端
           " nnoremap F :below 10sp +term<cr>a
    " defx-icons 配置
            set encoding=UTF-8
    " scrooloose/nerdtree 设置目录树
            " "NERDTree快捷键
            " :nnoremap <F1> :NERDTree <cr>
            " " 按<F1>打开或关闭文件目录树
            " :nnoremap <F1> :NERDTreeToggle<cr>

            " " 鼠标操作点击打开隐藏文件夹
            " let NERDTreeMouseMode = 2
            " " 显示隐藏文件 
            " let NERDTreeShowHidden = 2
            " " 开启NERDTree后进入vim如何默认光标在右侧文件编辑区
            "   autocmd VimEnter *
            "   \   if !argc()
            "   \ |   Startify
            "   \ |   NERDTree
            "   \ |   wincmd w
            "   \ | endif

            " autocmd StdinReadPre * let s:std_in=1
            " autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif
            " " 只有一个文件 自动退出NERDTree
            " autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif


    " vim-startify 封面设置
            "设置书签
            " let g:startify_bookmarks            = [
            " \ '~/Project/test.cpp',
            " \]
            "起始页显示的列表长度
            let g:startify_files_number = 14
            "自动加载session
            let g:startify_session_autoload = 1
            "过滤列表，支持正则表达式
            let g:startify_skiplist = [
            \ '^/tmp',
            \ ]
            "自定义Header和Footer
            let g:startify_custom_header = [
            \'                                                                               ____                     ____                      _____ _____  ______           ', 
            \'                                                           █████              / __ \                   / __ \                    |_   _|  __ \|  ____|   /\     ', 
            \'                                                         ▒██▓  ██▒           | |  | |_   _  __ _ _ __ | |  | |_   _  __ _ _ __     | | | |  | | |__     /  \    ', 
            \'                                                         ▒██▒  ██░           | |  | | | | |/ _  |  _ \| |  | | | | |/ _  |  _ \    | | | |  | |  __|   / /\ \   ',
            \'                                                         ░██  █▀ ░           | |__| | |_| | (_| | | | | |__| | |_| | (_| | | | |  _| |_| |__| | |____ / ____ \  ',
            \'                                                         ░▒███▒█▄             \___\_\\__,_|\__,_|_| |_|\___\_\\__,_|\__,_|_| |_| |_____|_____/|______/_/    \_\ ',
            \'                                                         ░░ ▒▒░ ▒ ',
            \'                                                          ░ ▒░  ░            +---------------------------------------------------------------------------------+',
            \'                                                            ░   ░            |          圈圈(@millionfor) <millionfor@apache.org> wwww.quanquansy.com          |',
            \'                                                             ░               +---------------------------------------------------------------------------------+',
            \]

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
            nnoremap <silent>       tt        :CocCommand explorer --preset floating --position left<cr>
            :nnoremap <F1> :CocCommand explorer --preset floating --position left<cr>
            au User CocExplorerOpenPre  hi Pmenu ctermbg=NONE
            au User CocExplorerQuitPost hi Pmenu ctermbg=238
            au User CocExplorerQuitPost echo

    " vim-expand-region 快速选择
        " v扩大选择 V缩小选择
            vmap     <silent>       v         <Plug>(expand_region_expand)
            vmap     <silent>       V         <Plug>(expand_region_shrink)

    " rainbow
            let g:rainbow_active = 1
            let g:rainbow_conf = {'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta', 'blue', 'yellow', 'cyan', 'magenta']}

    " vim-javascript
            let g:javascript_plugin_jsdoc = 1
            let g:javascript_plugin_ngdoc = 1
            let g:javascript_plugin_flow = 1

    " 快速跳转 vim-interestingwords
        " 设置不同匹配词颜色不同
            let g:interestingWordsRandomiseColors = 1
            nnoremap <silent>       ff        :call InterestingWords('n')<cr>
            nnoremap <silent>       FF        :call UncolorAllWords()<cr>
            nnoremap <silent>       n         :call WordNavigation('forward')<cr>
            nnoremap <silent>       N         :call WordNavigation('backward')<cr>

    " floaterm
            " au BufEnter * if &buftype == 'terminal' | :call timer_start(50, { -> execute('startinsert!') }, { 'repeat': 5 }) | endif
            " let g:floaterm_title = ''
            " let g:floaterm_width = 0.8
            " let g:floaterm_height = 0.8
            " let g:floaterm_autoclose = 1
            " let g:floaterm_opener = 'edit'
            " hi! link FloatermBorder NONE
        " floaterm toggle by name and cmd
            " func FTToggle(name, cmd, pre_cmd) abort
            "     if floaterm#terminal#get_bufnr(a:name) != -1
            "         exec 'FloatermToggle ' . a:name
            "     else
            "         exec a:pre_cmd
            "         exec printf('FloatermNew --name=%s %s', a:name, a:cmd)
            "     endif
            "     echo $PWD
            " endf
            " nnoremap <silent>   <c-t> :call FTToggle('TERM', '', "try \| call system('~/scripts/edit-profile.sh VIM_TEM_DIR " . $PWD . "') \| endtry")<cr>
            " nnoremap <silent>   <c-b> :call FTToggle('DBUI', 'nvim +CALLDB', '')<cr>
            " nnoremap <silent>   F     :call FTToggle('RANGER', 'ranger', '')<cr>
            " nnoremap <silent>   L     :call FTToggle('LAZYGIT', 'lazygit', '')<cr>
            " tmap <silent><expr> <c-t> &ft == "floaterm" ? printf('<c-\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('TERM') == bufnr('%') ? '' : '<c-t>') : "<c-t>"
            " tmap <silent><expr> <c-b> &ft == "floaterm" ? printf('<c-\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('DBUI') == bufnr('%') ? '' : '<c-b>') : "<c-b>"
            " tmap <silent><expr> F     &ft == "floaterm" ? printf('<c-\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('RANGER') == bufnr('%') ? '' : 'F') : "F"
            " tmap <silent><expr> L     &ft == "floaterm" ? printf('<c-\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('LAZYGIT') == bufnr('%') ? '' : 'L') : "L"

    " fzf
        " maps
            " let g:fzf_preview_window = ['right:45%', 'ctrl-/']
            " let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
            " let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7 } }
            " com! -bar -bang Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter=: --nth=4..'}, 'right:45%', 'ctrl-/'), <bang>0)
            " nnoremap <silent>       <c-a>     :Ag<cr>
            " nnoremap <silent>       <c-f>     :Files $PWD<cr>
            " nnoremap <silent>       <c-h>     :History<cr>
            " nnoremap <silent>       <c-l>     :BLines<cr>
            " nnoremap <silent>       <c-g>     :GFiles?<cr>


        " vim-dadbod
            " ctrl b 打开或者关闭数据库
            " let g:dbs = [{ 'name': 'connection_name', 'url': 'mysql://user:password@host:port' }]
            " let g:db_ui_save_location = '~/.config/zsh/cache'
            " let g:db_ui_use_nerd_fonts = 1
            " let g:db_ui_force_echo_notifications = 1
            " let g:db_ui_table_helpers = {
            "       \   'mysql': {
            "       \     'List': 'SELECT * from `{schema}`.`{table}` order by id desc LIMIT 100;',
            "       \     'Indexes': 'SHOW INDEXES FROM `{schema}`.`{table}`;',
            "       \     'Table Fields': 'DESCRIBE `{schema}`.`{table}`;',
            "       \     'Alter Table': 'ALTER TABLE `{schema}`.`{table}` ADD '
            "       \   }
            "       \ }
            " let g:db_ui_locked = 0
            " com! CALLDB call DBUI()
            " func DBUI()
            "   let g:db_ui_locked = 1
            "   set laststatus=0 showtabline=0 nonu signcolumn=no nofoldenable
            "   exec 'DBUI'
            " endf
            " func DBUIToggle()
            "   if floaterm#terminal#get_bufnr('DBUI') < 0
            "     exec 'FloatermNew --height=0.76 --position=bottom --name=DBUI --wintype=float nvim +CALLDB'
            "   else
            "     exec 'FloatermToggle DBUI'
            "   endif
            " endf
            " nnoremap <silent><expr> <c-b> g:db_ui_locked ? "" : ":call DBUIToggle()<CR>"
            " tnoremap <silent><expr> <c-b> &ft == "floaterm" ? "<c-\><c-n>:call DBUIToggle()<CR>" : "<c-b>"

    " vim-dadbod
        " let g:dbs = [{ 'name': 'connection_name', 'url': 'mysql://user:password@host:port' }]
        let g:db_ui_save_location = '~/.config/zsh/cache'
        let g:db_ui_use_nerd_fonts = 1
        let g:db_ui_table_helpers = {
        \   'mysql': {
        \     'List': 'SELECT * from `{schema}`.`{table}` order by id desc LIMIT 100;',
        \     'Indexes': 'SHOW INDEXES FROM `{schema}`.`{table}`;',
        \     'Foreign Keys': "SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{table}' AND CONSTRAINT_TYPE = 'FOREIGN KEY';",
        \     'Primary Keys': "SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = '{schema}' AND TABLE_NAME = '{table}' AND CONSTRAINT_TYPE = 'PRIMARY KEY';",
        \     'Table Fields': 'DESCRIBE `{schema}`.`{table}`;'
        \   }
        \ }

    " yaocccc
        " line
            let g:vim_line_comments = { 'vim': '"', 'vimrc': '"',
                                     \  'js': '//', 'ts': '//', 'vue': '//',
                                     \  'java': '//', 'class': '//',
                                     \  'c': '//', 'h': '//',
                                     \  'go': '//' }

            let g:line_statusline_getters = ['CocErrCount', 'GitInfo']            
            func! CocErrCount()                
              return printf(' E%d ', get(get(b:, 'coc_diagnostic_info', {}), 'error', 0))            
            endf            
            func! GitInfo()                
              let info = ''                
              let branch = get(g:, 'coc_git_status', '')                
              let diff = get(b:, 'coc_git_status', '')                
              let info .= len(branch) ? printf(' %s ', branch) : ' none '                
              let info .= len(diff) ? printf('%s ', trim(diff)) : ''                
              return info            
            endf
        " comment
            nnoremap <silent> ??           :NToggleComment<cr>
            vnoremap <silent> /       :<c-u>VToggleComment<cr>
            vnoremap <silent> ?       :<c-u>CToggleComment<cr>

autocmd FileType apache setlocal commentstring=#\ %s

" some hook
" cd ~/.config/coc/extensions/node_modules/coc-ccls
" ln -s node_modules/ws/lib lib
" sudo pacman -S the_silver_searcher fd bat
" npm i js-beautify -g

