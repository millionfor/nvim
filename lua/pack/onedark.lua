local G = require('G')
local M = {}

function M.config()
end

function M.setup()
    -- do nothing
  require("onedark").setup({
    function_style = "italic",
    -- sidebars = {"qf", "vista_kind", "terminal", "packer"},

    -- Change the "hint" color to the "orange0" color, and make the "error" color bright red
    colors = {
    },

    -- Overwrite the highlight groups
    overrides = function(c)
      return {
      }
    end
  })
end

return M


