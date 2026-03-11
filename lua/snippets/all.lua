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
