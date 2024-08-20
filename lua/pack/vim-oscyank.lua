

local G = require('G')
local M = {}


function M.config()
  local function copy(lines, _)
    G.g.vim.fn.OSCYankString(table.concat(lines, "\n"))
  end

  local function paste()
    return {
      G.g.vim.fn.split(vim.fn.getreg(''), '\n'),
      G.g.vim.fn.getregtype('')
    }
  end
  G.vim.g.clipboard = {
    name = "osc52",
    copy = {
      ["+"] = copy,
      ["*"] = copy
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste
    }
  }

  G.vim.g.oscyank_term = 'default'
  G.vim.cmd [[
    set clipboard+=unnamedplus
  ]]
end

function M.setup()
    -- do nothing
end

return M







