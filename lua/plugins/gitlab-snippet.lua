

local M = {}

local function getenv(name)
  local v = vim.fn.getenv(name)
  if v == vim.NIL or v == nil or v == "" then
    return nil
  end
  return v
end

local function get_cfg()
  local base_url = vim.g.gitlab_snippet_base_url
  if base_url == nil or base_url == "" then
    base_url = getenv("GITLAB_BASE_URL") or getenv("GITLAB_URL") or getenv("CI_SERVER_URL")
  end
  if base_url ~= nil then
    base_url = vim.trim(base_url)
  end

  local token = vim.g.gitlab_snippet_token
  if token == nil or token == "" then
    token = getenv("GITLAB_TOKEN") or getenv("GITLAB_PRIVATE_TOKEN") or getenv("PRIVATE_TOKEN")
  end
  if token ~= nil then
    token = vim.trim(token)
  end

  local visibility = vim.g.gitlab_snippet_visibility
  if visibility == nil or visibility == "" then
    visibility = "private"
  end

  local project_id = vim.g.gitlab_snippet_project_id
  if project_id == "" then
    project_id = nil
  end

  local title = vim.g.gitlab_snippet_title
  if title == "" then
    title = nil
  end

  local description = vim.g.gitlab_snippet_description
  if description == "" then
    description = nil
  end

  return {
    base_url = base_url,
    token = token,
    visibility = visibility,
    project_id = project_id,
    title = title,
    description = description,
  }
end

local function trim_trailing_slash(s)
  return (s:gsub("/+$", ""))
end

local function split_lines(s)
  local t = {}
  for line in (s .. "\n"):gmatch("(.-)\n") do
    table.insert(t, line)
  end
  return t
end

local function comment_prefix()
  local ft = vim.bo.filetype
  if not ft or ft == "" then
    ft = "sh"
  end
  local tbl = vim.g.vim_line_comments or {}
  local p = tbl[ft]
  if p == nil or p == "" then
    if ft == "lua" or ft == "vim" or ft == "sql" then
      p = "--"
    elseif ft == "javascript"
      or ft == "typescript"
      or ft == "java"
      or ft == "c"
      or ft == "cpp"
      or ft == "go"
      or ft == "rust"
      or ft == "h"
      or ft == "hpp" then
      p = "//"
    else
      p = "#"
    end
  end
  return p
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function ui_input(prompt, default, cb)
  vim.ui.input({ prompt = prompt .. ": ", default = default or "" }, function(input)
    cb(input)
  end)
end

local function ui_select(items, prompt, default, cb)
  local defaults = {}
  if default ~= nil and default ~= "" then
    defaults = { default }
  end
  vim.ui.select(items, { prompt = prompt .. ": ", kind = "gitlab_snippet", format_item = tostring }, function(choice)
    cb(choice)
  end)
end

local function buf_get_lines()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function buf_set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local function buf_has_placeholder()
  for _, l in ipairs(buf_get_lines()) do
    if l:find("%%Gist_ID%%", 1, true) then
      return true
    end
  end
  return false
end

local function buf_extract_id()
  local lines = buf_get_lines()
  local max_scan = math.min(#lines, 200)
  for i = 1, max_scan do
    local l = lines[i]
    local id = l:match("[Gg]ist[_ ]?ID%W*(%d+)")
    if id and id ~= "" then
      return id
    end
    local id2 = l:match("/snippets/(%d+)")
    if id2 and id2 ~= "" then
      return id2
    end
  end
  return nil
end

local function buf_replace_placeholders(id, url)
  local changed = false
  local lines = buf_get_lines()
  for i, l in ipairs(lines) do
    local nl = l
    if id ~= nil then
      nl = nl:gsub("%%Gist_ID%%", tostring(id))
    end
    if url ~= nil then
      nl = nl:gsub("%%Snippet_URL%%", tostring(url))
    end
    if nl ~= l then
      lines[i] = nl
      changed = true
    end
  end
  if changed then
    buf_set_lines(lines)
  end
  return changed
end

local function buf_insert_default_header_if_needed()
  if buf_has_placeholder() or buf_extract_id() ~= nil then
    return false
  end
  local enabled = vim.g.gitlab_snippet_auto_insert_header
  if enabled == nil then
    enabled = 1
  end
  if enabled == 0 or enabled == false then
    return false
  end
  local p = comment_prefix()
  local lines = buf_get_lines()
  local insert_at = 0
  if #lines >= 1 and lines[1]:match("^#!") then
    insert_at = 1
  end
  local header = {
    string.format("%s GistID: %%Gist_ID%%", p),
    string.format("%s SnippetURL: %%Snippet_URL%%", p),
    "",
  }
  -- insert header (after shebang if present)
  for idx = #header, 1, -1 do
    table.insert(lines, insert_at + 1, header[idx])
  end
  buf_set_lines(lines)
  return true
end

local function endpoint_for(cfg, action, snippet_id)
  local base = trim_trailing_slash(cfg.base_url)
  if cfg.project_id ~= nil and tostring(cfg.project_id) ~= "" then
    if action == "create" then
      return base .. "/api/v4/projects/" .. tostring(cfg.project_id) .. "/snippets"
    end
    return base .. "/api/v4/projects/" .. tostring(cfg.project_id) .. "/snippets/" .. tostring(snippet_id)
  end
  if action == "create" then
    return base .. "/api/v4/snippets"
  end
  return base .. "/api/v4/snippets/" .. tostring(snippet_id)
end

local function gitlab_request(cfg, method, endpoint, payload)
  local raw
  if payload ~= nil then
    local json = vim.fn.json_encode(payload)
    local cmd = {
      "curl",
      "-sS",
      "-X",
      method,
      "-H",
      "PRIVATE-TOKEN: " .. cfg.token,
      "-H",
      "Content-Type: application/json",
      "--data-binary",
      "@-",
      endpoint,
      "-w",
      "\n%{http_code}",
    }
    raw = vim.fn.system(cmd, json)
  else
    local cmd = {
      "curl",
      "-sS",
      "-X",
      method,
      "-H",
      "PRIVATE-TOKEN: " .. cfg.token,
      endpoint,
      "-w",
      "\n%{http_code}",
    }
    raw = vim.fn.system(cmd)
  end

  if vim.v.shell_error ~= 0 then
    return 0, nil, raw
  end

  local parts = split_lines(raw)
  local http_code = tonumber(parts[#parts]) or 0
  table.remove(parts, #parts)
  local resp = table.concat(parts, "\n")

  local ok, obj = pcall(vim.fn.json_decode, resp)
  if not ok then
    obj = nil
  end

  return http_code, obj, resp
end

function M.upload_current_buffer(opts)
  opts = opts or {}
  local cfg = get_cfg()
  if not cfg.base_url or cfg.base_url == "" then
    notify("GitLab snippet upload: missing base url. Set vim.g.gitlab_snippet_base_url or $GITLAB_BASE_URL", vim.log.levels.ERROR)
    return
  end
  if not cfg.token or cfg.token == "" then
    notify("GitLab snippet upload: missing token. Set vim.g.gitlab_snippet_token or $GITLAB_TOKEN", vim.log.levels.ERROR)
    return
  end

  local fullpath = vim.fn.expand("%:p")
  if not fullpath or fullpath == "" then
    notify("GitLab snippet upload: current buffer has no file path", vim.log.levels.ERROR)
    return
  end

  -- keep disk + buffer consistent (and ensure %:p is real)
  if vim.bo.modified then
    vim.cmd("silent! write")
  end

  local file_name = opts.file_name or vim.fn.fnamemodify(fullpath, ":t")
  if not file_name or file_name == "" then
    file_name = "untitled"
  end

  local lines = buf_get_lines()
  local content = table.concat(lines, "\n")

  local title = opts.title or cfg.title
  if title == nil or title == "" then
    title = file_name
  end

  local description = opts.description or cfg.description or ""

  local visibility = opts.visibility or cfg.visibility or "private"

  local payload = {
    title = title,
    description = description,
    file_name = file_name,
    content = content,
    visibility = visibility,
  }

  local mode = opts.mode
  if mode ~= "create" and mode ~= "update" then
    if buf_has_placeholder() then
      mode = "create"
    elseif buf_extract_id() ~= nil then
      mode = "update"
    else
      mode = "create"
    end
  end

  local snippet_id = opts.snippet_id
  if mode == "update" and (snippet_id == nil or snippet_id == "") then
    snippet_id = buf_extract_id()
  end

  if mode == "update" and (snippet_id == nil or snippet_id == "") then
    notify("GitLab snippet upload: no GistID found in file; switching to create", vim.log.levels.WARN)
    mode = "create"
  end

  local endpoint = endpoint_for(cfg, mode == "create" and "create" or "update", snippet_id)
  local method = (mode == "create") and "POST" or "PUT"

  -- update mode: optionally lock metadata (title/desc/file/visibility) to remote values
  if mode == "update" and opts.lock_metadata then
    local get_endpoint = endpoint_for(cfg, "update", snippet_id)
    local get_http, get_obj, get_resp = gitlab_request(cfg, "GET", get_endpoint, nil)
    if get_http < 200 or get_http > 299 or type(get_obj) ~= "table" then
      notify("GitLab snippet update: failed to fetch existing snippet metadata (will not proceed)", vim.log.levels.ERROR)
      notify(get_resp or "", vim.log.levels.ERROR)
      return
    end
    payload.title = get_obj.title or payload.title
    payload.description = get_obj.description or payload.description
    payload.visibility = get_obj.visibility or payload.visibility
    if get_obj.file_name and get_obj.file_name ~= "" then
      payload.file_name = get_obj.file_name
    end
  end

  local http_code, obj, resp = gitlab_request(cfg, method, endpoint, payload)
  if http_code == 0 then
    notify("GitLab snippet upload: curl failed", vim.log.levels.ERROR)
    notify(resp or "", vim.log.levels.ERROR)
    return
  end

  if http_code < 200 or http_code > 299 then
    notify("GitLab snippet upload failed HTTP " .. http_code, vim.log.levels.ERROR)
    notify(resp, vim.log.levels.ERROR)
    return
  end

  if type(obj) ~= "table" then
    notify("GitLab snippet upload: response decode failed", vim.log.levels.ERROR)
    notify(resp, vim.log.levels.ERROR)
    return
  end

  local id = obj.id
  local url = obj.web_url or obj.url
  if not url or url == "" then
    notify("GitLab snippet upload: missing web_url in response", vim.log.levels.WARN)
    notify(resp, vim.log.levels.WARN)
    return
  end

  vim.fn.setreg("+", url)
  if mode == "create" and id ~= nil then
    local changed_header = false
    -- if user didn't pre-place placeholder, we can optionally insert one-time header
    changed_header = buf_insert_default_header_if_needed() or changed_header
    changed_header = buf_replace_placeholders(id, url) or changed_header
    if changed_header then
      -- write local file, then sync remote so snippet content includes the inserted id/url
      vim.cmd("silent! write")
      local new_lines = buf_get_lines()
      local new_content = table.concat(new_lines, "\n")
      local sync_payload = {
        title = title,
        description = description,
        file_name = file_name,
        content = new_content,
        visibility = visibility,
      }
      local u_endpoint = endpoint_for(cfg, "update", id)
      gitlab_request(cfg, "PUT", u_endpoint, sync_payload)
    end
  end
  notify(string.format("GitLab snippet %s OK. URL copied: %s", mode, url))
end

function M.upload_current_buffer_interactive(opts)
  opts = opts or {}
  local cfg = get_cfg()
  local fullpath = vim.fn.expand("%:p")
  local default_file_name = (fullpath and fullpath ~= "") and vim.fn.fnamemodify(fullpath, ":t") or "untitled"

  local last = vim.g.gitlab_snippet_last or {}
  local default_visibility = last.visibility or cfg.visibility or "private"
  local default_title = last.title or cfg.title or default_file_name
  local default_desc = last.description or cfg.description or ""
  local default_name = last.file_name or default_file_name
  local auto_mode = (buf_has_placeholder() and "create") or (buf_extract_id() and "update") or "create"
  local mode = opts.mode or auto_mode

  -- 编辑模式：不允许改元数据，直接覆盖内容，不弹窗、不确认
  if mode == "update" then
    M.upload_current_buffer({
      mode = "update",
      lock_metadata = true,
    })
    return
  end

  ui_input("GitLab Snippet Title", default_title, function(title)
    if title == nil then
      return
    end
    ui_input("GitLab Snippet Description", default_desc, function(description)
      if description == nil then
        return
      end
      ui_input("GitLab Snippet File Name", default_name, function(file_name)
        if file_name == nil then
          return
        end
        ui_select({ "private", "internal", "public" }, "GitLab Snippet Visibility", default_visibility, function(visibility)
          if visibility == nil then
            return
          end
          vim.g.gitlab_snippet_last = {
            title = title,
            description = description,
            file_name = file_name,
            visibility = visibility,
          }
          M.upload_current_buffer({
            title = title,
            description = description,
            file_name = file_name,
            visibility = visibility,
            mode = "create",
          })
        end)
      end)
    end)
  end)
end

function M.update_current_buffer_quick()
  local id = buf_extract_id()
  if id == nil or id == "" then
    notify("GitLab snippet update: no GistID/snippet id found in file", vim.log.levels.ERROR)
    return
  end
  M.upload_current_buffer({
    mode = "update",
    snippet_id = id,
    lock_metadata = true,
  })
end

function M.list_snippets()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
      notify("fzf-lua not found. Please install it for better UI.", vim.log.levels.WARN)
      return
  end

  local cfg = get_cfg()
  if not cfg.base_url or not cfg.token then
      notify("GitLab missing config. Set base_url and token.", vim.log.levels.ERROR)
      return
  end

  notify("Fetching GitLab snippets...")
  -- Fetch personal snippets
  local endpoint = trim_trailing_slash(cfg.base_url) .. "/api/v4/snippets"
  local http_code, obj, resp = gitlab_request(cfg, "GET", endpoint, nil)

  if http_code >= 200 and http_code < 300 and type(obj) == "table" then
    local lines = {}
    for i, snip in ipairs(obj) do
        local id = tostring(snip.id)
        local title = snip.title or "(no title)"
        local fname = snip.file_name or "untitled"
        
        -- Format time: 2024-03-12T01:23:45.000Z -> 03-12 01:23
        local time = snip.updated_at:gsub(".*%-(%d%d%-%d%dT%d%d:%d%d).*", "%1"):gsub("T", " ")
        
        local line = string.format("%-3d │ %-7s │ %-20s │ %-40s │ %12s", i, id, fname, title, time)
        table.insert(lines, line)
    end

    if #lines == 0 then
        notify("No GitLab snippets found.")
        return
    end

    fzf.fzf_exec(lines, {
        prompt = "GitLab Snippets> ",
        winopts = {
            height = 0.6,
            width = 0.8,
            row = 0.5,
            col = 0.5,
            border = "rounded",
            title = " GitLab Snippets ",
            title_pos = "center",
        },
        actions = {
            ["default"] = function(selected)
                if not selected or #selected == 0 then return end
                local idx_str = selected[1]:match("^(%d+)")
                if not idx_str then return end
                local idx = tonumber(idx_str)
                local snip_summary = obj[idx]
                if not snip_summary then return end

                notify("Fetching Snippet content...")
                local s_endpoint = trim_trailing_slash(cfg.base_url) .. "/api/v4/snippets/" .. tostring(snip_summary.id) .. "/raw"
                -- Raw endpoint returns raw text, but gitlab_request expects json by default
                -- Let's use a simple curl for raw content
                local curl_cmd = {
                    "curl", "-sS", "-H", "PRIVATE-TOKEN: " .. cfg.token, s_endpoint
                }
                local raw_content = vim.fn.system(curl_cmd)
                
                if vim.v.shell_error == 0 then
                    local content_lines = split_lines(raw_content)
                    
                    -- Check if GistID/SnippetID already in content
                    local has_id = false
                    for _, l in ipairs(content_lines) do
                        if l:find("GistID") or l:find("SnippetID") then has_id = true break end
                    end

                    if not has_id then
                        local p = comment_prefix()
                        table.insert(content_lines, 1, string.format("%s GistID: %s", p, snip_summary.id))
                        table.insert(content_lines, 2, string.format("%s SnippetURL: %s", p, snip_summary.web_url))
                        table.insert(content_lines, 3, "")
                    end

                    buf_set_lines(content_lines)
                    notify("Snippet " .. snip_summary.id .. " loaded into buffer.")
                else
                    notify("Failed to fetch Snippet content.", vim.log.levels.ERROR)
                end
            end
        }
    })
  else
    notify("Failed to fetch GitLab snippets: " .. (resp or "Unknown error"), vim.log.levels.ERROR)
  end
end

function M.config()
  vim.api.nvim_create_user_command("GitlabSnippetCreate", function()
    M.upload_current_buffer_interactive({ mode = "create" })
  end, {})

  vim.api.nvim_create_user_command("GitlabSnippetUpdate", function()
    M.update_current_buffer_quick()
  end, {})

  vim.api.nvim_create_user_command("GitlabSnippetUpload", function()
    M.upload_current_buffer_interactive()
  end, {})
  
  vim.api.nvim_create_user_command("GitlabSnippetList", function()
    M.list_snippets()
  end, {})

  vim.keymap.set("n", "wc", function()
    M.upload_current_buffer_interactive({ mode = "create" })
  end, { noremap = true, silent = true, desc = "GitLab Snippet Create" })

  vim.keymap.set("n", "wu", function()
    M.update_current_buffer_quick()
  end, { noremap = true, silent = true, desc = "GitLab Snippet Update" })
  
  vim.keymap.set("n", "wl", function()
    M.list_snippets()
  end, { noremap = true, silent = true, desc = "GitLab Snippet List" })
end

M.config()

return {}


