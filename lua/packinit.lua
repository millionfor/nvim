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

        -- 启动时间分析
        use { "dstein64/vim-startuptime", cmd = "StartupTime" }
        
        -- 鼠标跳转
        -- require('pack/smear-cursor').config()
        -- use { 'sphamba/smear-cursor.nvim', config = "require('pack/smear-cursor').setup()" }

        -- wilder 弹出式命令行
        use { 'gelguy/wilder.nvim', event = 'CmdlineEnter', run = 'UpdateRemotePlugins', config = 'require("pack/wilder").setup()' }
  
        -- vv 快速选中内容插件
        require('pack/vim-expand-region').config()
        use { 'terryma/vim-expand-region', config = "require('pack/vim-expand-region').setup()", event = 'CursorHold' }

        -- ff 高亮光标下的word
        require('pack/vim-interestingwords').config()
        use { 'lfv89/vim-interestingwords', config = "require('pack/vim-interestingwords').setup()", event = 'CursorHold' }

        -- 多光标插件
        require('pack/vim-visual-multi').config()
        use { 'mg979/vim-visual-multi', config = "require('pack/vim-visual-multi').setup()", event = 'CursorHold' }
        
        -- 数据库可视化UI
        -- require('pack/vim-dadbod').config()
        -- use { 'tpope/vim-dadbod', cmd = "DBUI" }
        -- use { 'kristijanhusak/vim-dadbod-ui', config = "require('pack/vim-dadbod').setup()", after = 'vim-dadbod' }

        -- coc-nvim
        require('pack/coc').config()
        use { 'neoclide/coc.nvim', config = "require('pack/coc').setup()", branch = 'release' }

        -- github copilot
        require('pack/copilot').config()
        use { 'github/copilot.vim', tag = 'v1.25.0', config = "require('pack/copilot').setup()" }
        
        -- require('pack/codeium').config()
        -- use { 'Exafunction/codeium.vim', config = "require('pack/codeium').setup()" }

        -- 浮动终端
        require('pack/vim-floaterm').config()
        use { 'voldikss/vim-floaterm', config = "require('pack/vim-floaterm').setup()" }
        
        -- 输入法
        -- require('pack/im-select').config()
        -- use { 'keaising/im-select.nvim', config = "require('pack/im-select').setup()" }
        
        -- 输入法
        -- require('pack/vim-im-select').config()
        -- use { 'brglng/vim-im-select', config = "require('pack/vim-im-select').setup()" }

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
        require('pack/vim-prettier').config()
        use { 'prettier/vim-prettier', run = 'yarn install --frozen-lockfile --production', config = "require('pack/vim-prettier').setup()" }

        -- 翻译
        require('pack/vim-translate').config()
        use { 'VincentCordobes/vim-translate', config = "require('pack/vim-translate').setup()" }
        
        -- 断点调试
        -- require('pack/vimspector').config()
        -- use { 'puremourning/vimspector', config = "require('pack/vimspector').setup()" }
        
        -- 高亮范围
        require('pack/nvim-hlchunk').config()
        use { 'yaocccc/nvim-hlchunk', config = "require('pack/nvim-hlchunk').setup()" }
        
        -- 快速打印
        require('pack/vim-echo').config()
        use { 'yaocccc/vim-echo', cmd = "VECHO",  config = "require('pack/vim-echo').setup()" }
        
        -- 注解
        require('pack/vim-jsdoc').config()
        use { 'heavenshell/vim-jsdoc', run = 'make install',  config = "require('pack/vim-jsdoc').setup()" }

        
        -- 快速注释
        -- require('pack/comment-nvim').config()
        -- use { 'numToStr/Comment.nvim', config = "require('pack/comment-nvim').setup()" }

        -- 启动页
        require('pack/alpha-nvim').config()
        use { 'goolord/alpha-nvim', config = "require('pack/alpha-nvim').setup()", requires = { 'nvim-tree/nvim-web-devicons' }}

        -- nodejs debugger
        -- require('pack/nvim-dap-ui').config()
        -- use { "rcarriga/nvim-dap-ui", config = "require('pack/nvim-dap-ui').setup()", requires = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } }
        
        -- signcolumn显示折叠信息
        use { 'yaocccc/nvim-foldsign', event = 'CursorHold', config = 'require("nvim-foldsign").setup()' }

        require('pack/onedark').config()
        use { 'millionfor/onedark.nvim', config = "require('pack/onedark').setup()" }
        
        -- vscode debugger
        use { 'mxsdev/nvim-dap-vscode-js' }
        use { 'theHamsta/nvim-dap-virtual-text' }
        use {
          "microsoft/vscode-js-debug",
          opt = true,
          run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out" 
        }

        use { 'ojroques/vim-oscyank', config = "require('pack/vim-oscyank').setup()" }
        -- 格式化排列
        use { 'Vonr/align.nvim', config = "require('pack/align-nvim').setup()", branch = "v2" }

        -- 注释插件
        use { 'yaocccc/vim-comment' }

        -- 操作成对的 ""  {}  [] 等的插件
        use { 'yaocccc/vim-surround' }
        use { 'yaocccc/nvim-hl-mdcodeblock.lua', after = 'nvim-treesitter', config = "require('pack/markdown').setup_hlcodeblock()" }
        
        -- Required plugins
        use 'nvim-treesitter/nvim-treesitter'
        use 'stevearc/dressing.nvim'
        use 'nvim-lua/plenary.nvim'
        use 'MunifTanjim/nui.nvim'
        use 'MeanderingProgrammer/render-markdown.nvim'

        -- Optional dependencies
        use 'hrsh7th/nvim-cmp'
        use 'nvim-tree/nvim-web-devicons' -- or use 'echasnovski/mini.icons'
        use 'HakonHarnes/img-clip.nvim'
        use 'zbirenbaum/copilot.lua'

        -- Avante.nvim with build process
        use {
          'yetone/avante.nvim',
          branch = 'main',
          run = 'make',
          -- config = "require('pack/avante').setup()"
          config = function()
            require('avante').setup()
          end
        }

        -- quanquan
        require('pack/quanquan').config()

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


