local G = require('G')

-- 设置python3对应的目录，你可以手动 export PYTHON=$(which python3) 到你的终端配置中
G.cmd([[
    let g:python3_host_prog = $PYTHON
]])

-- 设置命令提示 唯一标识 共享剪贴板
G.cmd([[
    set showcmd
    set encoding=utf-8
    set wildmenu
    set pumheight=10
    set conceallevel=0
    set clipboard=unnamed
    set clipboard+=unnamedplus
]])

-- 搜索高亮 空格+回车 去除匹配高亮 延迟
G.cmd([[
    set hlsearch
    set showmatch
    noremap \ :nohlsearch<CR>
    set incsearch
    set inccommand=
    set ignorecase
    set smartcase
    set timeoutlen=400
]])

-- 设置正常删除 光标穿越行
G.cmd([[
    set backspace=indent,eol,start
    set whichwrap+=<,>,h,
]])

-- 设置鼠标移动
G.cmd([[
    set mouse=a
]])

-- 错误无提示音 去除屏幕闪烁
G.cmd([[
    set vb
    set t_vb=""
    set t_ut=""
    set hidden
]])

-- 缩进对齐
G.cmd([[
    set autoindent
    set smartindent
    set tabstop=2
    set softtabstop=2
    set shiftwidth=2
    set smarttab
    set expandtab
]])

-- 不自动备份 不换行
G.cmd([[
    set nobackup
    set noswapfile
    set nowrap
]])

-- 持久化撤销
G.cmd([[
    set undofile
    set undodir=~/.config/nvim/cache/undodir
]])
-- vim保存1000条文件记录
G.cmd([[ set viminfo=!,'10000,<50,s10,h ]])



-- 折叠
G.opt.foldenable = true
G.opt.foldmethod = 'manual'
G.opt.viewdir = os.getenv('HOME') .. '/.config/nvim/cache/viewdir'
G.opt.foldtext = 'v:lua.MagicFoldText()'

function MagicFoldText()
    local line = G.fn.getline(G.v.foldstart)
    local folded = G.v.foldend - G.v.foldstart + 1
    local empty = line:find('%S') - 1
    local funcs = {
        [0] = function(_) return '' .. line end,
        [1] = function(_) return '+' .. line:sub(2) end,
        [2] = function(_) return '+ ' .. line:sub(3) end,
        [-1] = function(c)
            local result = ' ' .. line:sub(c + 1)
            local foldednumlen = #tostring(folded)
            for _ = 1, c - 2 - foldednumlen do result = '-' .. result end
            return '+' .. folded .. result
        end,
    }
    return funcs[empty <= 2 and empty or -1](empty) .. ' folded ' .. folded .. ' lines '
end


-- show
  --  colorscheme solarized8_high
G.cmd([[
    hi Normal ctermfg=7 ctermbg=NONE cterm=NONE \"添加默认颜色 避免加载抱错
    set cmdheight=1
    set updatetime=300
    set shortmess+=cI
    set scrolloff=5
    set noshowmode
    set nu
    set numberwidth=2
    set cul
    set signcolumn=yes
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    set fillchars=stlnc:#
]])

