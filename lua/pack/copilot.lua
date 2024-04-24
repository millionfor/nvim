local G = require('G')
local M = {}

function M.config()
    G.g.copilot_no_tab_map = true

    -- G.g.copilot_proxy = 'http://127.0.0.1:1087'
    -- G.g.copilot_proxy_strict_ssl = false

    G.map({ {'i', '<Right>', 'copilot#Accept("<Right>")', {script = true, silent = true, expr = true}} })
end

function M.setup()
    -- do nothing
end

return M

