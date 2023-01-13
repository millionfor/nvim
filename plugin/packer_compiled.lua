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
local package_path_str = "/Users/gongzijian/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/gongzijian/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/gongzijian/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/gongzijian/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/gongzijian/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
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
  ["Comment.nvim"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/Comment.nvim",
    url = "https://github.com/numToStr/Comment.nvim"
  },
  ["alpha-nvim"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/alpha-nvim",
    url = "https://github.com/goolord/alpha-nvim"
  },
  ["coc-volar"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/coc-volar",
    url = "https://github.com/yaegassy/coc-volar"
  },
  ["coc-volar-tools"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/coc-volar-tools",
    url = "https://github.com/yaegassy/coc-volar-tools"
  },
  ["coc.nvim"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/coc.nvim",
    url = "https://github.com/neoclide/coc.nvim"
  },
  ["copilot.vim"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/copilot.vim",
    url = "https://github.com/github/copilot.vim"
  },
  fzf = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/fzf",
    url = "https://github.com/junegunn/fzf"
  },
  ["fzf.vim"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
  },
  ["markdown-preview.nvim"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  ["nvim-hlchunk"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/nvim-hlchunk",
    url = "https://github.com/yaocccc/nvim-hlchunk"
  },
  ["nvim-lines.lua"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/nvim-lines.lua",
    url = "https://github.com/yaocccc/nvim-lines.lua"
  },
  ["nvim-template"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/nvim-template",
    url = "https://github.com/millionfor/nvim-template"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["onedark.nvim"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/onedark.nvim",
    url = "https://github.com/millionfor/onedark.nvim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["toggleterm.nvim"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/toggleterm.nvim",
    url = "https://github.com/akinsho/toggleterm.nvim"
  },
  ["vim-echo"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-echo",
    url = "https://github.com/yaocccc/vim-echo"
  },
  ["vim-expand-region"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-expand-region",
    url = "https://github.com/terryma/vim-expand-region"
  },
  ["vim-floaterm"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-floaterm",
    url = "https://github.com/voldikss/vim-floaterm"
  },
  ["vim-interestingwords"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-interestingwords",
    url = "https://github.com/lfv89/vim-interestingwords"
  },
  ["vim-jsdoc"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-jsdoc",
    url = "https://github.com/heavenshell/vim-jsdoc"
  },
  ["vim-markdown-toc"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-markdown-toc",
    url = "https://github.com/mzlogin/vim-markdown-toc"
  },
  ["vim-prettier"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-prettier",
    url = "https://github.com/prettier/vim-prettier"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/yaocccc/vim-surround"
  },
  ["vim-translate"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-translate",
    url = "https://github.com/VincentCordobes/vim-translate"
  },
  ["vim-visual-multi"] = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vim-visual-multi",
    url = "https://github.com/mg979/vim-visual-multi"
  },
  vimspector = {
    loaded = true,
    path = "/Users/gongzijian/.local/share/nvim/site/pack/packer/start/vimspector",
    url = "https://github.com/puremourning/vimspector"
  }
}

time([[Defining packer_plugins]], false)

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
