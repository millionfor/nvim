local G = require('G')
local packer_bootstrap = false
local install_path = G.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if G.fn.empty(G.fn.glob(install_path)) > 0 then
    print('Installing packer.nvim...')
    G.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    G.cmd [[packadd packer.nvim]]
    packer_bootstrap = true
end

require('packer').startup({function(use)
  use { 'wbthomason/packer.nvim' }
  use { 'mg979/vim-visual-multi' }
  use { 'yaocccc/vim-surround' }
  use { 'terryma/vim-expand-region' }
  use { 'neoclide/coc.nvim', branch = 'release' }
  use { 'yaegassy/coc-volar', 'yaegassy/coc-volar-tools' }
  use { 'kyazdani42/nvim-web-devicons', 'kyazdani42/nvim-tree.lua' }
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate', 'nvim-treesitter/playground' }
  use { 
    'yaocccc/nvim-lines.lua',
    'yaocccc/nvim-hlchunk',
    'yaocccc/vim-echo'
  }
  use { 'voldikss/vim-floaterm' }
  use { 'lfv89/vim-interestingwords' }
  use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview', 'mzlogin/vim-markdown-toc' }
  use { 'junegunn/fzf', run = 'cd ~/.fzf && ./install --all', 'junegunn/fzf.vim' }

  --自用
  use { 'goolord/alpha-nvim', 'kyazdani42/nvim-web-devicons' }
  use { 'VincentCordobes/vim-translate' }
  use { 'prettier/vim-prettier', run = 'yarn install --frozen-lockfile --production' }
  use { 'millionfor/onedark.nvim' }
  use { 'numToStr/Comment.nvim' }
  use { 'akinsho/toggleterm.nvim' }
  use { 'puremourning/vimspector' }
  use { 'millionfor/nvim-template' }
  use { 'heavenshell/vim-jsdoc', run = 'make install' }


  if packer_bootstrap then
      require('packer').sync()
  else
      require('pack/vim-visual-multi')
      require('pack/vim-floaterm')
      require('pack/fzf')
      require('pack/coc')
      require('pack/nvim-tree')
      require('pack/vim-expand-region')
      require('pack/vim-interestingwords')
      require('pack/markdown')
      -- require('pack/vim-comment')
      require('pack/tree-sitter')
      require('pack/vim-hlchunk')
      require('pack/nvim-lines')

      --自用
      require('pack/alpha-nvim')
      require('pack/vim-translate')
      require('pack/vim-prettier')
      require('pack/onedark')
      require('pack/Comment')
      require('pack/toggleterm')
      require('pack/vimspector')
      require('pack/vim-jsdoc')
      require('pack/vim-echo')
  end
end, config = {
    git = { clone_timeout = 120 },
    display = {
        working_sym = '[ ]', error_sym = '[✗]', done_sym = '[✓]', removed_sym = ' - ', moved_sym = ' → ', header_sym = '─',
        open_fn = function() return require("packer.util").float({ border = "rounded" }) end
    }
}})
