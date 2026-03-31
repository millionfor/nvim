local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

return {
    s("upv", {
        t("fix: update "),
        f(function()
            local handle = io.popen('jq -r ".name" package.json 2>/dev/null')
            if handle then
                local name = handle:read("*a"):gsub("%s+", "")
                handle:close()
                if name ~= "" and name ~= "null" then
                    -- 去除特殊字符，仅保留字母、数字、连字符和下划线
                    return name:gsub("[^%w%-_]", "")
                end
            end
            return "package"
        end),
        t(" version (v"),
        f(function()
            local handle = io.popen('jq -r ".version" package.json 2>/dev/null')
            if handle then
                local version = handle:read("*a"):gsub("%s+", "")
                handle:close()
                if version ~= "" and version ~= "null" then
                    return version
                end
            end
            return "unknown"
        end),
        t(")")
    }),
    s("upp", {
        f(function()
            local function get_content(cmd)
                local h = io.popen(cmd)
                if not h then
                    return nil
                end
                local content = h:read("*a")
                h:close()
                return content
            end

            local pkg_path = "package.json"
            local git_root = io.popen("git rev-parse --show-toplevel 2>/dev/null"):read("*a"):gsub("%s+", "")
            if git_root ~= "" then
                pkg_path = git_root .. "/package.json"
            end

            local curr_raw = get_content("cat " .. pkg_path .. " 2>/dev/null")
            if not curr_raw or curr_raw == "" then
                return "fix: update package"
            end

            local head_raw = get_content("git show HEAD:package.json 2>/dev/null")
            if not head_raw or head_raw == "" then
                head_raw = "{}"
            end

            local ok1, curr = pcall(vim.json.decode, curr_raw)
            local ok2, head = pcall(vim.json.decode, head_raw)

            if not ok1 or not curr then
                return "fix: update package"
            end
            if not ok2 or not head then
                head = {}
            end

            local changes = {}
            local sections = { "dependencies", "devDependencies" }
            for _, sect in ipairs(sections) do
                local c_sect = curr[sect] or {}
                local h_sect = head[sect] or {}
                for pkg, ver in pairs(c_sect) do
                    if ver ~= h_sect[pkg] then
                        local clean_ver = ver:gsub("^[%^~%*]", "")
                        table.insert(changes, pkg .. "@" .. clean_ver)
                    end
                end
            end

            if #changes == 0 then
                return "fix: update package"
            end

            return "fix: update package " .. table.concat(changes, "、") .. " version"
        end)
    }),
    s("ww", {
        f(function()
            local handle = io.popen("curl -s 'wttr.in/ShangHai?format=3'")
            if handle then
                local weather = handle:read("*a"):gsub("%s+$", "")
                handle:close()
                return weather ~= "" and weather or "weather fetch failed"
            end
            return "weather fetch failed"
        end)
    })
}
