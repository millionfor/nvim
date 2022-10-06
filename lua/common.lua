local G = require('G')

G.cmd("let mapleader=','")
G.cmd("let g:python3_host_prog = $PYTHON")

G.cmd([[
  " Plug
  call plug#begin('~/.config/nvim/plugged')
  call plug#end()

  packadd! vimspector
]])
