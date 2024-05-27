

local G = require('G')
local M = {}

function M.config()
  --   -- Change '<C-g>' here to any keycode you like.
  --   vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
  --   vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
  --   vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
  --   vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })

  -- G.map({
  --   -- 进入调试
  --   { 'n', '<leader>k', ':call codeium#CycleCompletions()<cr>', { noremap = true, silent = true } },
  -- })

    -- G.map({ {'i', '<Right>', 'codeium#Accept()', {script = true, silent = true, expr = true}} })
end

function M.setup()
    -- do nothing
end

return M

