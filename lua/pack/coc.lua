local G = require('G')
local M = {}

function M.config()
    G.g.coc_global_extensions = {
        'coc-marketplace',
        'coc-json',
        'coc-html', 'coc-css',
        'coc-clangd',
        'coc-python',
        'coc-go',
        'coc-sumneko-lua',
        'coc-vimlsp',
        'coc-sh', 'coc-db',
        'coc-pyright',
        'coc-toml', 'coc-solidity',
        'coc-prettier',
        'coc-snippets', 'coc-pairs', 'coc-word',
        'coc-translator',
        'coc-git',
        'coc-gist',
        'coc-tsserver',
        '@yaegassy/coc-volar',
        'coc-docthis'
    }
    G.cmd("command! -nargs=? Fold :call CocAction('fold', <f-args>)")
    G.cmd("hi! link CocPum Pmenu")
    G.cmd("hi! link CocMenuSel PmenuSel")
    -- Gist upsert：按“文件名”判断是否已存在 gist，存在则 update 覆盖，否则 create
    -- 依赖环境变量 token：优先 $GITHUB_TOKEN，其次 $GH_TOKEN
    G.cmd([[
    function! s:GistToken() abort
      let token = getenv('GITHUB_TOKEN')
      if empty(token)
        let token = getenv('GH_TOKEN')
      endif
      return token
    endfunction

    function! s:GistLineCommentPrefix() abort
      let ft = &filetype
      if empty(ft)
        let ft = 'sh'
      endif
      let tbl = get(g:, 'vim_line_comments', {})
      let p = get(tbl, ft, '')
      if empty(p)
        if ft =~# '^\%(lua\|vim\|sql\)$'
          let p = '--'
        elseif ft =~# '^\%(javascript\|typescript\|java\|c\|cpp\|go\|rust\|h\|hpp\)$'
          let p = '//'
        else
          let p = '#'
        endif
      endif
      return p
    endfunction

    function! s:GistEnsureHeader(id) abort
      let prefix = s:GistLineCommentPrefix()
      let idline = prefix . ' GistID: ' . a:id
      let urlline = prefix . ' GistURL: https://gist.github.com/' . a:id

      " 优先在前 40 行内更新已有的 GistID/GistURL
      for lnum in range(1, min([40, line('$')]))
        if getline(lnum) =~# 'GistID:'
          call setline(lnum, idline)
          if lnum + 1 <= line('$') && getline(lnum + 1) =~# 'GistURL:'
            call setline(lnum + 1, urlline)
          else
            call append(lnum, urlline)
          endif
          return
        endif
      endfor

      " 没有则插入：若有 shebang，插在第 1 行之后
      let insert_at = 0
      if getline(1) =~# '^#!'
        let insert_at = 1
      endif
      call append(insert_at, [idline, urlline, ''])
    endfunction

    function! s:GistFindByFilename(token, filename) abort
      let url = 'https://api.github.com/gists?per_page=100'
      let cmd = 'curl -sS -H ' . shellescape('Authorization: token ' . a:token) . ' ' . shellescape(url)
      let out = system(cmd)
      if v:shell_error != 0
        return {}
      endif
      let arr = json_decode(out)
      if type(arr) != type([])
        return {}
      endif
      " GitHub 返回按 updated_at 倒序；命中第一个即可
      for gist in arr
        if has_key(gist, 'files')
          for [fname, _] in items(gist.files)
            if fname ==# a:filename
              return {'id': gist.id, 'filename': fname}
            endif
          endfor
        endif
      endfor
      return {}
    endfunction

    function! s:GistIdFromHeader() abort
      for lnum in range(1, min([40, line('$')]))
        let l = getline(lnum)
        if l =~# 'GistID:\s*'
          let id = matchstr(l, 'GistID:\s*\zs[0-9a-f]\+')
          if !empty(id)
            return id
          endif
        endif
      endfor
      return ''
    endfunction

    function! GistUpsertByFilename() abort
      let token = s:GistToken()
      if empty(token)
        echo 'Gist upsert requires $GITHUB_TOKEN (or $GH_TOKEN).'
        return
      endif

      let fullpath = expand('%:p')
      if empty(fullpath)
        echo 'No file to gist.'
        return
      endif

      let filename = fnamemodify(fullpath, ':t')
      if empty(filename)
        let filename = 'untitled'
      endif

      let content = join(getline(1, '$'), "\n")

      " 1) 优先用文件头里的 GistID（最可靠）
      let id = s:GistIdFromHeader()

      " 2) 没有则按文件名查找现有 gist
      if empty(id)
        let found = s:GistFindByFilename(token, filename)
        if !empty(found)
          let id = found.id
        endif
      endif

      if empty(id)
        " create
        let payload = {'description': '', 'public': v:false, 'files': {filename: {'content': content}}}
        let cmd = 'curl -sS -X POST'
        let cmd .= ' -H ' . shellescape('Authorization: token ' . token)
        let cmd .= ' -H ' . shellescape('Content-Type: application/json')
        let cmd .= ' -d ' . shellescape(json_encode(payload))
        let cmd .= ' ' . shellescape('https://api.github.com/gists')
        let resp = system(cmd)
      else
        " update (覆盖同名文件内容)
        let payload = {'files': {filename: {'content': content}}}
        let cmd = 'curl -sS -X PATCH'
        let cmd .= ' -H ' . shellescape('Authorization: token ' . token)
        let cmd .= ' -H ' . shellescape('Content-Type: application/json')
        let cmd .= ' -d ' . shellescape(json_encode(payload))
        let cmd .= ' ' . shellescape('https://api.github.com/gists/' . id)
        let resp = system(cmd)
      endif

      if v:shell_error != 0
        echo 'Gist request failed.'
        return
      endif

      let obj = json_decode(resp)
      if type(obj) != type({}) || !has_key(obj, 'id')
        echo 'Gist API error: ' . resp
        return
      endif

      let new_id = obj.id
      let b:coc_gist_id = new_id
      let b:coc_gist_filename = filename
      call s:GistEnsureHeader(new_id)
      echo 'Gist upsert OK: ' . new_id
    endfunction
    ]])
    G.map({
        { 'n', '<F2>', '<Plug>(coc-rename)', {silent = true} },
        { 'n', 'gd', '<Plug>(coc-definition)', {silent = true} },
        { 'n', 'gy', '<Plug>(coc-type-definition)', {silent = true} },
        { 'n', 'gi', '<Plug>(coc-implementation)', {silent = true} },
        { 'n', 'gr', '<Plug>(coc-references)', {silent = true} },
        { 'x', 'if', '<Plug>(coc-funcobj-i)', {silent = true} },
        { 'o', 'if', '<Plug>(coc-funcobj-i)', {silent = true} },
        { 'x', 'af', '<Plug>(coc-funcobj-a)', {silent = true} },
        { 'o', 'af', '<Plug>(coc-funcobj-a)', {silent = true} },
        { 'x', 'ic', '<Plug>(coc-classobj-i)', {silent = true} },
        { 'o', 'ic', '<Plug>(coc-classobj-i)', {silent = true} },
        { 'x', 'ac', '<Plug>(coc-classobj-a)', {silent = true} },
        { 'o', 'ac', '<Plug>(coc-classobj-a)', {silent = true} },
        { 'n', 'K', ':call CocAction("doHover")<cr>', {silent = true} },
        { 'i', '<c-f>', "coc#pum#visible() ? '<c-y>' : '<c-f>'", {silent = true, expr = true} },
        { 'i', '<TAB>', "coc#pum#visible() ? coc#pum#next(1) : col('.') == 1 || getline('.')[col('.') - 2] =~# '\\s' ? \"\\<TAB>\" : coc#refresh()", {silent = true, noremap = true, expr = true} },
        { 'i', '<s-tab>', "coc#pum#visible() ? coc#pum#prev(1) : \"\\<s-tab>\"", {silent = true, noremap = true, expr = true} },
        { 'i', '<cr>', "coc#pum#visible() ? coc#pum#confirm() : \"\\<c-g>u\\<cr>\\<c-r>=coc#on_enter()\\<cr>\"", {silent = true, noremap = true, expr = true} },
        { 'i', '<c-y>', "coc#pum#visible() ? coc#pum#confirm() : '<c-y>'", {silent = true, noremap = true, expr = true} },
        { 'n', '<F3>', ":silent CocRestart<cr>", {silent = true, noremap = true} },
        { 'n', '<F4>', "get(g:, 'coc_enabled', 0) == 1 ? ':CocDisable<cr>' : ':CocEnable<cr>'", {silent = true, noremap = true, expr = true} },
        { 'n', '<F9>', ":CocCommand snippets.editSnippets<cr>", {silent = true, noremap = true} },
        { 'n', '<c-e>', ":CocList --auto-preview diagnostics<cr>", {silent = true} },
        { 'n', 'mm', "<Plug>(coc-translator-p)", {silent = true} },
        { 'v', 'mm', "<Plug>(coc-translator-pv)", {silent = true} },
        { 'n', '(', "<Plug>(coc-git-prevchunk)", {silent = true} },
        { 'n', ')', "<Plug>(coc-git-nextchunk)", {silent = true} },
        { 'n', 'C', "get(b:, 'coc_git_blame', '') ==# 'Not committed yet' ? \"<Plug>(coc-git-chunkinfo)\" : \"<Plug>(coc-git-commit)\"", {silent = true, expr = true} },
        { 'n', '\\g', ":call coc#config('git.addGBlameToVirtualText',  !get(g:coc_user_config, 'git.addGBlameToVirtualText', 0)) | call nvim_buf_clear_namespace(bufnr(), -1, line('.') - 1, line('.'))<cr>", {silent = true} },
        { 'x', '=', 'CocHasProvider("formatRange") ? "<Plug>(coc-format-selected)" : "="', {silent = true, noremap = true, expr = true}},
        { 'n', '=', 'CocHasProvider("formatRange") ? "<Plug>(coc-format-selected)" : "="', {silent = true, noremap = true, expr = true}},
        { 'n', 'gl', ":CocList gist<cr>", {silent = true, noremap = true} },
        { 'n', 'gc', ":call GistUpsertByFilename()<cr>", {silent = true, noremap = true} },
        { 'n', 'gu', ":call GistUpsertByFilename()<cr>", {silent = true, noremap = true} },
        { 'n', '<leader>zs', ":CocCommand docthis.documentThis<cr>", {silent = true, noremap = true} },
    })
end

function M.setup()
    -- do nothing
end

return M





