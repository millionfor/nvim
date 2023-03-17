autocmd BufNewFile *.sh,*.py call SetScriptTitle()
autocmd BufWritePre *.sh,*.py call SetScriptLastModified()

let s:getModifiedTimeStr = {->printf('# Last Modified    %s', strftime("%a, %b %d, %Y %R"))}

func s:getScriptTemplete(type)
    let templates = {
        \'sh': [
        \    "#!/bin/bash",
        \    "# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:",
        \    "",
        \    "# =======================================================",
        \    "# Description:     ",
        \    "# Author           QuanQuan <millionfor@apache.org>",
        \    s:getModifiedTimeStr(),
        \    "# GistID           %Gist_ID%",
        \    "# GistURL          https://gist.github.com/millionfor/%Gist_ID%",
        \    "# =======================================================",
        \    "",
        \    "set -eu",
        \    "",
        \],
        \'python': [
        \    "#!/usr/bin/env python",
        \    "# -*- coding: utf-8 -*-",
        \    "",
        \    "# ",
        \    "# ",
        \    "# ",
        \    "# ",
        \    "# Author: QuanQuan <https://quanquansy.com/> (millionfor@apache.org)",
        \    "# ", 
        \    "# MIT Licensed",
        \    "# ",
        \    s:getModifiedTimeStr(),
        \    "# @GistID           %Gist_ID%",
        \    "# @GistURL          https://gist.github.com/millionfor/%Gist_ID%",
        \    "",
        \],
        \'default': [
        \    "#!/bin/bash py",
        \    "# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:",
        \    "",
        \    "# =======================================================",
        \    "# Description:     ",
        \    "# Author           QuanQuan <millionfor@apache.org>",
        \    s:getModifiedTimeStr(),
        \    "# GistID           %Gist_ID%",
        \    "# GistURL          https://gist.github.com/millionfor/%Gist_ID%",
        \    "# =======================================================",
        \    "",
        \    "set -eu",
        \    "",
        \],
        \}
    return get(templates, a:type, templates['default'])
endf

func SetScriptTitle()
    let template = s:getScriptTemplete(&filetype)
    call append(0, template)
    exec 'normal G'
endf

func SetScriptLastModified()
    for n in range(10)
        if getline(n) =~ '^\s*\#\s*Last Modified\s*\S*.*$'
            call setline(n, s:getModifiedTimeStr())
            return
        endif
    endfor
endf


