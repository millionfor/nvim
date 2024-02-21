
local G = require('G')

require('toggleterm').setup {
  hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' }, -- hide mapping boilerplate
}

local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
  cmd = 'lazygit',
  hidden = true,
  direction = 'float',
  on_open = function(term)
    vim.cmd('startinsert!')
    vim.api.nvim_buf_set_keymap(0, 't', '<esc>', '<cmd>close<CR>', { silent = false, noremap = true })
    if vim.fn.mapcheck('<esc>', 't') ~= '' then
      vim.api.nvim_buf_del_keymap(term.bufnr, 't', '<esc>')
    end
  end,
})

function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end

local ranger = Terminal:new({
  cmd = 'ranger',
  hidden = true,
  direction = 'float',
  on_open = function(term)
    vim.cmd('startinsert!')
    vim.api.nvim_buf_set_keymap(0, 't', '<esc>', '<cmd>close<CR>', { silent = false, noremap = true })
    if vim.fn.mapcheck('<esc>', 't') ~= '' then
      vim.api.nvim_buf_del_keymap(term.bufnr, 't', '<esc>')
    end
  end,
})

function _RANGER_TOGGLE()
  ranger:toggle()
end

local btop = Terminal:new({
  cmd = 'btop',
  hidden = true,
  direction = 'float',
  on_open = function(term)
    vim.cmd('startinsert!')
    vim.api.nvim_buf_set_keymap(0, 't', '<esc>', '<cmd>close<CR>', { silent = false, noremap = true })
    if vim.fn.mapcheck('<esc>', 't') ~= '' then
      vim.api.nvim_buf_del_keymap(term.bufnr, 't', '<esc>')
    end
  end,
})

function _BTOP_TOGGLE()
  btop:toggle()
end



G.map({
  { 'n', 'L', '<cmd>lua _LAZYGIT_TOGGLE()<cr>', {silent = true, noremap = true}},
  { 'n', 'R', '<cmd>lua _RANGER_TOGGLE()<cr>', {silent = true, noremap = true}},
  { 'n', 'B', '<cmd>lua _BTOP_TOGGLE()<cr>', {silent = true, noremap = true}},
  { 'n', 'T', ':ToggleTerm direction=float<CR>', {silent = true, noremap = true}},
})

