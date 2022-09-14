require('packer').startup({function(use)
    use { 'mg979/vim-visual-multi' }; require('pack/vim-visual-multi')
    use { 'kyazdani42/nvim-web-devicons', 'kyazdani42/nvim-tree.lua' }; require('pack/nvim-tree')
    use { 'yaocccc/nvim-lines.lua' }; require('pack/nvim-lines')
end, config = { git = { clone_timeout = 120 } }})
