
local G = require('G')
local M = {}

function M.config()
end

function M.setup()
  local NS = { noremap = true, silent = true }

  -- 与 1 个字符对齐
  vim.keymap.set(
      'x',
      '<leader>a',
      function()
          require'align'.align_to_char({
              preview = true,
              length = 1,
          })
      end,
      NS
  )

  -- 通过预览对齐 2 个字符
  vim.keymap.set(
      'x',
      'ad',
      function()
          require'align'.align_to_char({
              preview = true,
              length = 2,
          })
      end,
      NS
  )

  -- 通过预览与字符串对齐
  vim.keymap.set(
      'x',
      'aw',
      function()
          require'align'.align_to_string({
              preview = true,
              regex = false,
          })
      end,
      NS
  )

  -- 与带有预览的 Vim 正则表达式对齐
  vim.keymap.set(
      'x',
      'ar',
      function()
          require'align'.align_to_string({
              preview = true,
              regex = true,
          })
      end,
      NS
  )

  -- 使用预览将段落与字符串对齐的 gawip 示例
  vim.keymap.set(
      'n',
      'gaw',
      function()
          local a = require'align'
          a.operator(
              a.align_to_string,
              {
                  regex = false,
                  preview = true,
              }
          )
      end,
      NS
  )

  -- 将段落与 1 个字符对齐的 gaaip 示例
  vim.keymap.set(
      'n',
      'gaa',
      function()
          local a = require'align'
          a.operator(a.align_to_char)
      end,
      NS
  )
end

return M


