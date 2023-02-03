local G = require('G')
local packer_bootstrap = false
local install_path = G.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
local compiled_path = G.fn.stdpath('config')..'/plugin/packer_compiled.lua'
if G.fn.empty(G.fn.glob(install_path)) > 0 then
    print('Installing packer.nvim...')
    G.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    G.fn.system({'rm', '-rf', compiled_path})
    G.cmd [[packadd packer.nvim]]
    packer_bootstrap = true
end

-- 所有插件配置分 config 和 setup 部分
-- config 发生在插件载入前 一般为 let g:xxx = xxx 或者 hi xxx xxx 或者 map x xxx 之类的 配置
-- setup  发生在插件载入后 一般为 require('xxx').setup() 之类的配置
require('packer').startup({
    function(use)
        -- packer 管理自己的版本
        use { 'wbthomason/packer.nvim' }
  
        -- vv 快速选中内容插件
        require('pack/vim-expand-region').config()
        use { 'terryma/vim-expand-region', config = "require('pack/vim-expand-region').setup()", event = 'CursorHold' }

        -- ff 高亮光标下的word
        require('pack/vim-interestingwords').config()
        use { 'lfv89/vim-interestingwords', config = "require('pack/vim-interestingwords').setup()", event = 'CursorHold' }

        -- 多光标插件
        require('pack/vim-visual-multi').config()
        use { 'mg979/vim-visual-multi', config = "require('pack/vim-visual-multi').setup()", event = 'CursorHold' }

        -- coc-nvim
        require('pack/coc').config()
        use { 'neoclide/coc.nvim', config = "require('pack/coc').setup()", branch = 'release' }

        -- github copilot
        require('pack/copilot').config()
        use { 'github/copilot.vim', config = "require('pack/copilot').setup()", event = 'InsertEnter' }

        -- 浮动终端
        require('pack/vim-floaterm').config()
        use { 'voldikss/vim-floaterm', config = "require('pack/vim-floaterm').setup()" }

        -- fzf
        require('pack/fzf').config()
        use { 'junegunn/fzf' }
        use { 'junegunn/fzf.vim', config = "require('pack/fzf').setup()", run = 'cd ~/.fzf && ./install --all', after = "fzf" }

        -- tree-sitter
        require('pack/tree-sitter').config()
        use { 'nvim-treesitter/nvim-treesitter', config = "require('pack/tree-sitter').setup()", run = ':TSUpdate', event = 'BufRead' }
        use { 'nvim-treesitter/playground', after = 'nvim-treesitter' }

        -- markdown预览插件 导航生成插件
        require('pack/markdown').config()
        use { 'mzlogin/vim-markdown-toc', ft = 'markdown' }
        use { 'iamcco/markdown-preview.nvim', config = "require('pack/markdown').setup()", run = 'cd app && yarn install', cmd = 'MarkdownPreview', ft = 'markdown' }

        -- 文件管理器
        require('pack/nvim-tree').config()
        use { 'kyazdani42/nvim-tree.lua', config = "require('pack/nvim-tree').setup()", cmd = { 'NvimTreeToggle', 'NvimTreeFindFileToggle' } }

        -- 状态栏 & 标题栏
        require('pack/nvim-lines').config()
        use { 'yaocccc/nvim-lines.lua', config = "require('pack/nvim-lines').setup()" }
        
        -- prettier格式化
        -- require('pack/vim-prettier').config()
        -- use { 'prettier/vim-prettier', run = 'yarn install --frozen-lockfile --production', config = "require('pack/vim-prettier').setup()" }

        -- 翻译
        -- require('pack/vim-translate').config()
        -- use { 'VincentCordobes/vim-translate', config = "require('pack/vim-translate').setup()" }
        
        -- 断点调试
        -- require('pack/vimspector').config()
        -- use { 'puremourning/vimspector', config = "require('pack/vimspector').setup()" }
        
        -- 高亮范围
        -- require('pack/nvim-hlchunk').config()
        -- use { 'yaocccc/nvim-hlchunk', config = "require('pack/nvim-hlchunk').setup()" }
        
        -- 快速打印
        -- require('pack/vim-echo').config()
        -- use { 'yaocccc/vim-echo', cmd = "VECHO",  config = "require('pack/vim-echo').setup()" }
        
        -- 快速注释
        -- require('pack/Comment').config()
        -- use { 'numToStr/Comment.nvim', config = "require('pack/Comment').setup()" }

        -- 启动页
        -- require('pack/alpha-nvim').config()
        -- use { 'goolord/alpha-nvim', config = "require('pack/alpha-nvim').setup()", requires = { 'nvim-tree/nvim-web-devicons' }}

        -- 样式
        -- require('pack/onedark').config()
        -- use { 'millionfor/onedark.nvim', config = "require('pack/onedark').setup()"}

        -- 部分个人自写插件
        -- require('pack/quanquan').config()                                               -- yaocccc/* 共用一个config

        use { 'yaocccc/vim-comment' }                                                  -- 注释插件
        use { 'yaocccc/vim-surround' }                                                 -- 操作成对的 ""  {}  [] 等的插件
    end,
    config = {
        git = { clone_timeout = 120, depth = 1 },
        display = {
            working_sym = '[ ]', error_sym = '[✗]', done_sym = '[✓]', removed_sym = ' - ', moved_sym = ' → ', header_sym = '─',
            open_fn = function() return require("packer.util").float({ border = "rounded" }) end
        }
    }
})

if packer_bootstrap then
    require('packer').sync()
end

