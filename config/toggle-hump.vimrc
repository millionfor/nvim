
" def CamelToSneak(name: string): string
"   var l = []
"   var start = true
"   for ch in split(name, '\zs')
"     if ch =~# '\u'
"       l->add('_')
"     endif
"     l->add(tolower(ch))
"   endfor
"   var i = 0
"   while l[i] == '_'
"     i += 1
"   endw
"   return join(l[i :], '')
" enddef

" def SneakToCamel(name: string): string
"   var ret = ''
"   var pre_underscore = true
"   for ch in split(name, '\zs')
"     if ch == '_'
"       pre_underscore = true
"       continue
"     endif
"     if pre_underscore
"       ret ..= toupper(ch)
"       pre_underscore = false
"     else
"       ret ..= ch
"     endif
"   endfor
"   return ret
" enddef

" def Convert(name: string): string
"   return stridx(name, "_") == -1 ? CamelToSneak(name) : SneakToCamel(name)
" enddef

" def ConvertCword(all: bool=false)
"   var cword = expand("<cword>")
"   var pos = getcurpos()
"   if all
"     exec printf('g/\<%s\>/s/\<%s\>/%s/g', cword, cword, Convert(cword))
"   else
"     if has('clipboard')
"       var __save1 = getreg('+')
"       var __save2 = getreg('*')
"     endif
"     var __save3 = getreg('0')
"     setreg('0', Convert(cword))
"     norm! viw"0p
"     if has('clipboard')
"       setreg('+', __save1)
"       setreg('*', __save2)
"     endif
"     setreg('0', __save3)
"   endif
"   setpos('.', pos)
" enddef

" map w <cmd>call <sid>ConvertCword(1)<cr>
" map e <cmd>call <sid>ConvertCword()<cr>
