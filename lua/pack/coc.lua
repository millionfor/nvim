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

    function! s:GistRenderHeaderTemplate(id) abort
      " 用户可在 vim.g.gist_comment_templates 自定义不同 filetype 的注释模板：
      " - key: &filetype（为空则按 sh）
      " - value: List[string]，其中可包含 %Gist_ID% 动态变量
      "
      " 重要：这里不再提供任何默认模板；没有配置就返回空，表示“不插入任何注释”
      let ft = &filetype
      if empty(ft)
        let ft = 'sh'
      endif
      let templates = get(g:, 'gist_comment_templates', {})
      let tpl = get(templates, ft, v:null)
      if type(tpl) != type([])
        return []
      endif

      let out = []
      for l in tpl
        call add(out, substitute(l, '%Gist_ID%', a:id, 'g'))
      endfor
      return out
    endfunction

    function! s:GistEnsureHeader(id) abort
      " 规则 A：只要文件任何位置存在 %Gist_ID% 占位符，则只替换占位符，不新增任何注释块
      let max_scan = line('$')
      let replaced = 0
      for lnum in range(1, max_scan)
        let l = getline(lnum)
        if l =~# '%Gist_ID%'
          call setline(lnum, substitute(l, '%Gist_ID%', a:id, 'g'))
          let replaced = 1
        endif
      endfor
      if replaced
        return 1
      endif

      " 规则 B：若没有占位符，则仅在用户配置了对应 filetype 的模板时才插入；没有模板则什么都不做
      let rendered = s:GistRenderHeaderTemplate(a:id)
      if empty(rendered)
        return 0
      endif

      " 插入：若有 shebang，插在第 1 行之后，否则插在文件头
      let insert_at = 0
      if getline(1) =~# '^#!'
        let insert_at = 1
      endif
      call append(insert_at, rendered)
      return 1
    endfunction

    function! s:GistPatch(token, id, filename, content) abort
      let payload = {'files': {a:filename: {'content': a:content}}}
      let cmd = 'curl -sS -X PATCH'
      let cmd .= ' -H ' . shellescape('Authorization: token ' . a:token)
      let cmd .= ' -H ' . shellescape('Content-Type: application/json')
      let cmd .= ' -d ' . shellescape(json_encode(payload))
      let cmd .= ' ' . shellescape('https://api.github.com/gists/' . a:id)
      let cmd .= ' -w ' . shellescape("\n%{http_code}")
      let raw = system(cmd)
      let parts = split(raw, "\n")
      let http = str2nr(remove(parts, -1))
      let resp = join(parts, "\n")
      return [http, resp]
    endfunction

    function! s:GistSaveAndSync(token, id, filename) abort
      " 先保存文件到本地（确保磁盘内容和 buffer 一致）
      if &modified
        silent! write
      endif

      " 再把最终内容同步到远程 gist（把刚替换的 GistID/模板也推上去）
      let content = join(getline(1, '$'), "\n")
      let res = s:GistPatch(a:token, a:id, a:filename, content)
      let http = res[0]
      let resp = res[1]
      if http < 200 || http > 299
        echo 'Gist sync failed HTTP ' . http . ': ' . resp
        return 0
      endif
      return 1
    endfunction

    function! s:GistHasPlaceholder() abort
      " 文件内任意位置出现 %Gist_ID% => 按你定义：这是“新建”标记
      return search('%Gist_ID%', 'nw') > 0
    endfunction

    function! s:GistIdFromHeader32() abort
      " 按你定义：`GistID:` + 32 位 hex 才算“更新”标记
      for lnum in range(1, min([120, line('$')]))
        let l = getline(lnum)
        if l =~# 'GistID'
          let id = matchstr(l, 'GistID\D*\zs[0-9A-Fa-f]\{32}\ze')
          if !empty(id)
            return tolower(id)
          endif
        endif
      endfor
      return ''
    endfunction

    function! GistDebug() abort
      let token = s:GistToken()
      let filename = fnamemodify(expand('%:p'), ':t')
      let id = s:GistIdFromHeader32()
      echo 'filename=' . filename
      echo 'token=' . (empty(token) ? '<empty>' : '<set>')
      echo 'has_placeholder(%Gist_ID%)=' . (s:GistHasPlaceholder() ? 'yes' : 'no')
      echo 'gist_id(from header 32hex)=' . (empty(id) ? '<empty>' : id)
      if empty(token) || empty(id)
        return
      endif
      let cmd = 'curl -sS -X GET'
      let cmd .= ' -H ' . shellescape('Authorization: token ' . token)
      let cmd .= ' ' . shellescape('https://api.github.com/gists/' . id)
      let cmd .= ' -w ' . shellescape("\n%{http_code}")
      let raw = system(cmd)
      let parts = split(raw, "\n")
      let http = str2nr(remove(parts, -1))
      echo 'GET /gists/' . id . ' => HTTP ' . http
    endfunction

    function! GistUpdateByFilename() abort
      let token = s:GistToken()
      if empty(token)
        echo 'Gist update requires $GITHUB_TOKEN (or $GH_TOKEN).'
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

      " 规则：文件内有 %Gist_ID% => 这是“新建”标记，gu 不负责新建
      if s:GistHasPlaceholder()
        echo 'This file contains %Gist_ID% placeholder => treat as CREATE.'
        echo 'Use gc to create first, then gu will update by the inserted GistID.'
        return
      endif

      " strict update: 必须有 32 位 GistID
      let id = s:GistIdFromHeader32()
      if empty(id)
        echo 'No existing gist found for "' . filename . '" (no GistID and no remote match).'
        echo 'Use gc to create/upsert first.'
        return
      endif

      let payload = {'files': {filename: {'content': content}}}
      let cmd = 'curl -sS -X PATCH'
      let cmd .= ' -H ' . shellescape('Authorization: token ' . token)
      let cmd .= ' -H ' . shellescape('Content-Type: application/json')
      let cmd .= ' -d ' . shellescape(json_encode(payload))
      let cmd .= ' ' . shellescape('https://api.github.com/gists/' . id)
      let cmd .= ' -w ' . shellescape("\n%{http_code}")
      let raw = system(cmd)
      let parts = split(raw, "\n")
      let http = str2nr(remove(parts, -1))
      let resp = join(parts, "\n")

      if v:shell_error != 0
        echo 'Gist update request failed.'
        return
      endif

      if http < 200 || http > 299
        echo 'Gist update failed HTTP ' . http . ': ' . resp
        echo 'Not creating new gist (gu is update-only). Check token scopes: classic PAT needs "gist".'
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
      let changed = s:GistEnsureHeader(new_id)
      if changed
        call s:GistSaveAndSync(token, new_id, filename)
      endif
      echo 'Gist update OK: ' . new_id
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

      " 你的规则：
      " - 如果文件内有 %Gist_ID% => 强制 CREATE（新建），并在创建后替换占位符
      " - 如果文件头有 GistID + 32位hex => UPDATE
      " - 否则：没有标记，默认 CREATE（但是否插入注释由模板决定；没模板就不插入）
      let force_create = s:GistHasPlaceholder()
      let id = force_create ? '' : s:GistIdFromHeader32()

      if empty(id)
        " create
        let payload = {'description': '', 'public': v:false, 'files': {filename: {'content': content}}}
        let cmd = 'curl -sS -X POST'
        let cmd .= ' -H ' . shellescape('Authorization: token ' . token)
        let cmd .= ' -H ' . shellescape('Content-Type: application/json')
        let cmd .= ' -d ' . shellescape(json_encode(payload))
        let cmd .= ' ' . shellescape('https://api.github.com/gists')
        let cmd .= ' -w ' . shellescape("\n%{http_code}")
        let raw = system(cmd)
        let parts = split(raw, "\n")
        let http = str2nr(remove(parts, -1))
        let resp = join(parts, "\n")
      else
        " update (覆盖同名文件内容)
        let payload = {'files': {filename: {'content': content}}}
        let cmd = 'curl -sS -X PATCH'
        let cmd .= ' -H ' . shellescape('Authorization: token ' . token)
        let cmd .= ' -H ' . shellescape('Content-Type: application/json')
        let cmd .= ' -d ' . shellescape(json_encode(payload))
        let cmd .= ' ' . shellescape('https://api.github.com/gists/' . id)
        let cmd .= ' -w ' . shellescape("\n%{http_code}")
        let raw = system(cmd)
        let parts = split(raw, "\n")
        let http = str2nr(remove(parts, -1))
        let resp = join(parts, "\n")
      endif

      if v:shell_error != 0
        echo 'Gist request failed.'
        return
      endif

      " 常见原因：token 没有 gist 权限，GitHub 会返回 404/403
      if http < 200 || http > 299
        echo 'Gist API HTTP ' . http . ': ' . resp
        echo 'Check token scopes: classic PAT needs "gist"; fine-grained PAT needs Gists read/write.'
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
      let changed = s:GistEnsureHeader(new_id)
      if changed
        call s:GistSaveAndSync(token, new_id, filename)
      endif
      echo (empty(id) ? 'Gist create OK: ' : 'Gist update OK: ') . new_id
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
        { 'n', 'gu', ":call GistUpdateByFilename()<cr>", {silent = true, noremap = true} },
        { 'n', '<leader>zs', ":CocCommand docthis.documentThis<cr>", {silent = true, noremap = true} },
    })
end

function M.setup()
    -- do nothing
end

return M





