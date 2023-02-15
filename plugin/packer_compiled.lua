-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/quanquan/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/quanquan/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/quanquan/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/quanquan/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/quanquan/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["coc.nvim"] = {
    config = { "require('pack/coc').setup()" },
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/coc.nvim",
    url = "https://github.com/neoclide/coc.nvim"
  },
  ["copilot.vim"] = {
    config = { "require('pack/copilot').setup()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/copilot.vim",
    url = "https://github.com/github/copilot.vim"
  },
  fzf = {
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/fzf",
    url = "https://github.com/junegunn/fzf"
  },
  ["fzf.vim"] = {
    config = { "require('pack/fzf').setup()" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
  },
  ["markdown-preview.nvim"] = {
    commands = { "MarkdownPreview" },
    config = { "require('pack/markdown').setup()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  ["nvim-hlchunk"] = {
    config = { "require('pack/nvim-hlchunk').setup()" },
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/nvim-hlchunk",
    url = "https://github.com/yaocccc/nvim-hlchunk"
  },
  ["nvim-lines.lua"] = {
    config = { "require('pack/nvim-lines').setup()" },
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/nvim-lines.lua",
    url = "https://github.com/yaocccc/nvim-lines.lua"
  },
  ["nvim-tree.lua"] = {
    commands = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
    config = { "require('pack/nvim-tree').setup()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    after = { "playground" },
    config = { "require('pack/tree-sitter').setup()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["onedark.nvim"] = {
    config = { "require('pack/onedark').setup()" },
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/onedark.nvim",
    url = "https://github.com/millionfor/onedark.nvim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  playground = {
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["vim-comment"] = {
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/vim-comment",
    url = "https://github.com/yaocccc/vim-comment"
  },
  ["vim-echo"] = {
    commands = { "VECHO" },
    config = { "require('pack/vim-echo').setup()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/vim-echo",
    url = "https://github.com/yaocccc/vim-echo"
  },
  ["vim-expand-region"] = {
    config = { "require('pack/vim-expand-region').setup()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/vim-expand-region",
    url = "https://github.com/terryma/vim-expand-region"
  },
  ["vim-floaterm"] = {
    config = { "require('pack/vim-floaterm').setup()" },
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/vim-floaterm",
    url = "https://github.com/voldikss/vim-floaterm"
  },
  ["vim-interestingwords"] = {
    config = { "require('pack/vim-interestingwords').setup()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/vim-interestingwords",
    url = "https://github.com/lfv89/vim-interestingwords"
  },
  ["vim-jsdoc"] = {
    config = { "require('pack/vim-jsdoc').setup()" },
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/vim-jsdoc",
    url = "https://github.com/heavenshell/vim-jsdoc"
  },
  ["vim-markdown-toc"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc",
    url = "https://github.com/mzlogin/vim-markdown-toc"
  },
  ["vim-prettier"] = {
    config = { "require('pack/vim-prettier').setup()" },
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/vim-prettier",
    url = "https://github.com/prettier/vim-prettier"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/yaocccc/vim-surround"
  },
  ["vim-translate"] = {
    config = { "require('pack/vim-translate').setup()" },
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/vim-translate",
    url = "https://github.com/VincentCordobes/vim-translate"
  },
  ["vim-visual-multi"] = {
    config = { "require('pack/vim-visual-multi').setup()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/opt/vim-visual-multi",
    url = "https://github.com/mg979/vim-visual-multi"
  },
  vimspector = {
    config = { "require('pack/vimspector').setup()" },
    loaded = true,
    path = "/home/quanquan/.local/share/nvim/site/pack/packer/start/vimspector",
    url = "https://github.com/puremourning/vimspector"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: vim-prettier
time([[Config for vim-prettier]], true)
require('pack/vim-prettier').setup()
time([[Config for vim-prettier]], false)
-- Config for: onedark.nvim
time([[Config for onedark.nvim]], true)
require('pack/onedark').setup()
time([[Config for onedark.nvim]], false)
-- Config for: vim-floaterm
time([[Config for vim-floaterm]], true)
require('pack/vim-floaterm').setup()
time([[Config for vim-floaterm]], false)
-- Config for: vim-translate
time([[Config for vim-translate]], true)
require('pack/vim-translate').setup()
time([[Config for vim-translate]], false)
-- Config for: nvim-hlchunk
time([[Config for nvim-hlchunk]], true)
require('pack/nvim-hlchunk').setup()
time([[Config for nvim-hlchunk]], false)
-- Config for: vim-jsdoc
time([[Config for vim-jsdoc]], true)
require('pack/vim-jsdoc').setup()
time([[Config for vim-jsdoc]], false)
-- Config for: nvim-lines.lua
time([[Config for nvim-lines.lua]], true)
require('pack/nvim-lines').setup()
time([[Config for nvim-lines.lua]], false)
-- Config for: vimspector
time([[Config for vimspector]], true)
require('pack/vimspector').setup()
time([[Config for vimspector]], false)
-- Config for: coc.nvim
time([[Config for coc.nvim]], true)
require('pack/coc').setup()
time([[Config for coc.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd fzf ]]
vim.cmd [[ packadd fzf.vim ]]

-- Config for: fzf.vim
require('pack/fzf').setup()

time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.api.nvim_create_user_command, 'VECHO', function(cmdargs)
          require('packer.load')({'vim-echo'}, { cmd = 'VECHO', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-echo'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('VECHO ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'NvimTreeFindFileToggle', function(cmdargs)
          require('packer.load')({'nvim-tree.lua'}, { cmd = 'NvimTreeFindFileToggle', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nvim-tree.lua'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('NvimTreeFindFileToggle ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'NvimTreeToggle', function(cmdargs)
          require('packer.load')({'nvim-tree.lua'}, { cmd = 'NvimTreeToggle', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nvim-tree.lua'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('NvimTreeToggle ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'MarkdownPreview', function(cmdargs)
          require('packer.load')({'markdown-preview.nvim'}, { cmd = 'MarkdownPreview', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'markdown-preview.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('MarkdownPreview ', 'cmdline')
      end})
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'markdown-preview.nvim', 'vim-markdown-toc'}, { ft = "markdown" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'copilot.vim'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead * ++once lua require("packer.load")({'nvim-treesitter'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd [[au CursorHold * ++once lua require("packer.load")({'vim-expand-region', 'vim-visual-multi', 'vim-interestingwords'}, { event = "CursorHold *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /home/quanquan/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]], true)
vim.cmd [[source /home/quanquan/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]]
time([[Sourcing ftdetect script at: /home/quanquan/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
