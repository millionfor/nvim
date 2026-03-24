local M = {}

local function getenv(name)
  local v = vim.fn.getenv(name)
  if v == vim.NIL or v == nil or v == "" then
    return nil
  end
  return v
end

local function get_token()
  return getenv("GITHUB_TOKEN") or getenv("GH_TOKEN")
end

local function notify(msg, level)
  vim.notify("GitHub Gist: " .. msg, level or vim.log.levels.INFO)
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
  local function find_id(text)
    -- Look for GistID: <id>
    local id = text:match("GistID[:%s%-_]+(%x+)")
    if id and #id == 32 then return id:lower() end

    -- Fallback: look for any 32-char hex string word in the text
    for word in text:gmatch("%x+") do
      if #word == 32 then return word:lower() end
    end
    return nil
  end

  -- Priority 1: Current line
  local id = find_id(vim.api.nvim_get_current_line())
  if id then return id end

  -- Priority 2: Header (first 120 lines)
  local lines = buf_get_lines()
  local max_scan = math.min(#lines, 120)
  for i = 1, max_scan do
    id = find_id(lines[i])
    if id then return id end
  end
  return nil
end

local function buf_replace_placeholders(id)
  local changed = false
  local lines = buf_get_lines()
  for i, l in ipairs(lines) do
    local nl = l:gsub("%%Gist_ID%%", tostring(id))
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

local function github_request(method, endpoint, payload)
  local token = get_token()
  if not token then
    notify("Missing GITHUB_TOKEN or GH_TOKEN", vim.log.levels.ERROR)
    return 0, nil, "Missing token"
  end

  local cmd = {
    "curl",
    "-sS",
    "-X",
    method,
    "-H",
    "Authorization: token " .. token,
    "-H",
    "Accept: application/vnd.github.v3+json",
    "-H",
    "Content-Type: application/json",
  }

  local input = nil
  if payload then
    input = vim.fn.json_encode(payload)
    table.insert(cmd, "--data-binary")
    table.insert(cmd, "@-")
  end

  table.insert(cmd, endpoint)
  table.insert(cmd, "-w")
  table.insert(cmd, "\n%{http_code}")

  local raw = vim.fn.system(cmd, input)
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

function M.create_gist()
  if buf_has_placeholder() then
    -- Already handled by logic below
  end

  local filename = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":t")
  if filename == "" then filename = "untitled" end

  local content = table.concat(buf_get_lines(), "\n")
  local payload = {
    description = "",
    public = false,
    files = {
      [filename] = {
        content = content
      }
    }
  }

  notify("Creating gist...")
  local http_code, obj, resp = github_request("POST", "https://api.github.com/gists", payload)

  if http_code >= 200 and http_code < 300 and obj and obj.id then
    local id = obj.id
    local changed = buf_replace_placeholders(id)
    if not changed and not buf_extract_id() then
        -- Insert header if no ID found and no placeholder was present
        local p = comment_prefix()
        local lines = buf_get_lines()
        local insert_at = 0
        if #lines >= 1 and lines[1]:match("^#!") then
            insert_at = 1
        end
        table.insert(lines, insert_at + 1, string.format("%s GistID: %s", p, id))
        buf_set_lines(lines)
        changed = true
    end

    if changed then
      vim.cmd("silent! write")
      -- Sync final content with ID back to GitHub
      local sync_content = table.concat(buf_get_lines(), "\n")
      local sync_payload = {
        files = {
          [filename] = {
            content = sync_content
          }
        }
      }
      github_request("PATCH", "https://api.github.com/gists/" .. id, sync_payload)
    end
    notify("Gist created: " .. id)
    vim.fn.setreg("+", obj.html_url)
  else
    notify("Failed to create gist: " .. (resp or "Unknown error"), vim.log.levels.ERROR)
  end
end

function M.update_gist()
  local id = buf_extract_id()
  if not id then
    notify("No GistID found in file. Use gc to create.", vim.log.levels.WARN)
    return
  end

  local filename = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":t")
  if filename == "" then filename = "untitled" end

  local content = table.concat(buf_get_lines(), "\n")
  local payload = {
    files = {
      [filename] = {
        content = content
      }
    }
  }

  notify("Updating gist " .. id .. "...")
  local http_code, obj, resp = github_request("PATCH", "https://api.github.com/gists/" .. id, payload)

  if http_code >= 200 and http_code < 300 then
    notify("Gist updated: " .. id)
  else
    notify("Failed to update gist: " .. (resp or "Unknown error"), vim.log.levels.ERROR)
  end
end

function M.list_gists()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
      -- Fallback to terminal-style list if fzf-lua is not available
      notify("fzf-lua not found. Please install it for better UI.", vim.log.levels.WARN)
      return
  end

  notify("Fetching gists...")
  local http_code, obj, resp = github_request("GET", "https://api.github.com/gists", nil)

  if http_code >= 200 and http_code < 300 and type(obj) == "table" then
    local lines = {}
    local max_width = vim.api.nvim_get_option("columns")
    
    for i, gist in ipairs(obj) do
        local id = gist.id:sub(1, 7)
        local desc = gist.description ~= "" and gist.description or "(no description)"
        local filenames = {}
        for fname, _ in pairs(gist.files) do table.insert(filenames, fname) end
        local filename = filenames[1] or "untitled"
        
        -- Format time: 2024-03-12T01:23:45Z -> 03-12 01:23
        local time = gist.updated_at:gsub(".*%-(%d%d%-%d%dT%d%d:%d%d).*", "%1"):gsub("T", " ")
        
        -- Column formatting
        local line = string.format("%-3d │ %-7s │ %-20s │ %-40s │ %12s", i, id, filename, desc, time)
        table.insert(lines, line)
    end

    if #lines == 0 then
        notify("No gists found.")
        return
    end

    fzf.fzf_exec(lines, {
        prompt = "Gists> ",
        winopts = {
            height = 0.6,
            width = 0.8,
            row = 0.5,
            col = 0.5,
            border = require("gradient_border").get(),
            title = " GitHub Gists ",
            title_pos = "center",
        },
        actions = {
            ["default"] = function(selected)
                if not selected or #selected == 0 then return end
                local idx_str = selected[1]:match("^(%d+)")
                if not idx_str then return end
                local idx = tonumber(idx_str)
                local gist_summary = obj[idx]
                if not gist_summary then return end

                notify("Fetching Gist content...")
                local http_code, g_obj, resp = github_request("GET", "https://api.github.com/gists/" .. gist_summary.id)
                
                if http_code >= 200 and http_code < 300 and g_obj and g_obj.files then
                    local filenames = {}
                    for fname, _ in pairs(g_obj.files) do table.insert(filenames, fname) end
                    local fname = filenames[1]
                    if not fname then return end

                    local fileinfo = g_obj.files[fname]
                    local content_lines = split_lines(fileinfo.content)
                    
                    -- Check if GistID already in content
                    local has_id = false
                    for _, l in ipairs(content_lines) do
                        if l:find("GistID") then has_id = true break end
                    end

                    if not has_id then
                        local p = comment_prefix()
                        table.insert(content_lines, 1, string.format("%s GistID: %s", p, g_obj.id))
                        table.insert(content_lines, 2, "")
                    end

                    buf_set_lines(content_lines)
                    notify("Gist " .. g_obj.id:sub(1, 7) .. " loaded into buffer.")
                else
                    notify("Failed to fetch Gist content: " .. (resp or "Unknown error"), vim.log.levels.ERROR)
                end
            end
        }
    })
  else
    notify("Failed to fetch gists: " .. (resp or "Unknown error"), vim.log.levels.ERROR)
  end
end

function M.config()
  vim.keymap.set("n", "gl", M.list_gists, { noremap = true, silent = true, desc = "List Gists" })
  vim.keymap.set("n", "gc", M.create_gist, { noremap = true, silent = true, desc = "Create Gist" })
  vim.keymap.set("n", "gu", M.update_gist, { noremap = true, silent = true, desc = "Update Gist" })
end

M.config()

return {
    "github-gist", -- Placeholder name since it's a local config
    virtual = true,
    dir = vim.fn.stdpath("config") .. "/lua/plugins/github-gist-virtual", -- Not really used but follows pattern
    lazy = false,
}
