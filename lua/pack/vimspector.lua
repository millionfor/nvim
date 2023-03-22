local G = require('G')
local M = {}


function M.config()
  -- G.g.vimspector_enable_mappings = 'HUMAN'

  G.map({
    -- 进入调试
    { 'n', '<leader>d', ':call vimspector#Launch()<cr>', { noremap = true, silent = true } },
    -- 关闭调试
    { 'n', '<leader>e', ':call vimspector#Reset()<cr>', { noremap = true, silent = true } },
    -- 调试时继续,否则开始调试
    { 'n', '<leader>c', ':call vimspector#Continue()<cr>', { noremap = true, silent = true } },
    -- 调试打断点
    { 'n', '<leader>t', ':call vimspector#ToggleBreakpoint()<cr>', { noremap = true, silent = true } },
    -- 调试取消断点
    { 'n', '<leader>T', ':call vimspector#ClearBreakpoints()<cr>', { noremap = true, silent = true } },
    -- 重新加载调试
    { 'n', '<leader>s', '<Plug>VimspectorRestart', { noremap = true, silent = true } },
    { 'n', '<leader>o', '<Plug>VimspectorStepOut', { noremap = true, silent = true } },
    { 'n', '<leader>dl', '<Plug>VimspectorStepInto', { noremap = true, silent = true } },
    { 'n', '<leader>dj', '<Plug>VimspectorStepOver', { noremap = true, silent = true } },
  })
end

function M.setup()
    -- do nothing
end

return M




