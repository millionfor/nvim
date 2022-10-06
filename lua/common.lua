local G = require('G')

G.cmd("let mapleader=','")

G.cmd([[
  " Plug
  call plug#begin('~/.config/nvim/plugged')
  call plug#end()

  packadd! vimspector
 
  
]])





