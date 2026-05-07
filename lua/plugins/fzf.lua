-- Fzf-lua configuration module
local M = {}

-- Initialize keybindings and dynamic options
function M.init()
    -- Helper to get configuration options based on current working directory
    local get_cwd_opts = function()
        local cwd = os.getenv("PWD") or vim.fn.getcwd()
        -- Check if .gitignore exists to decide whether to ignore hidden files
        local has_gitignore = vim.fn.filereadable(cwd .. "/.gitignore") == 1
        return {
            cwd = cwd,
            -- fd options: hide .git, follow links, handle gitignore logic
            fd_opts = "--color=never --type f --hidden --follow --exclude .git" .. (not has_gitignore and " --no-ignore" or ""),
            -- rg options: formatting for live grep, handle gitignore logic, exclude .git
            rg_opts = "--column --line-number --no-heading --color=always --smart-case --fixed-strings --hidden " .. (not has_gitignore and "--no-ignore " or "") .. "-g '!.git'",
        }
    end

    -- Keybindings for common fzf-lua actions
    -- Find files
    vim.keymap.set('n', '<c-f>', function() require("fzf-lua").files(get_cwd_opts()) end, { silent = true, noremap = true })
    -- Live grep across files
    vim.keymap.set('n', '<c-a>', function() require("fzf-lua").live_grep(get_cwd_opts()) end, { silent = true, noremap = true })
    -- Switch buffers
    vim.keymap.set('n', '<c-b>', function() require("fzf-lua").buffers() end, { silent = true, noremap = true })
    -- Search in current buffer lines
    vim.keymap.set('n', '<c-l>', function() require("fzf-lua").blines() end, { silent = true, noremap = true })
    -- Git status search
    vim.keymap.set('n', '<c-g>', function() require("fzf-lua").git_status({ cwd = os.getenv("PWD") }) end, { silent = true, noremap = true })
    -- Recent files (only in current directory)
    vim.keymap.set('n', '<c-h>', function() require("fzf-lua").oldfiles({ cwd = os.getenv("PWD"), cwd_only = true }) end, { silent = true, noremap = true })
end

-- Setup global fzf-lua options
function M.config()
    require("fzf-lua").setup({
        -- Highlight group configurations
        hls = {
            border         = "FloatBorder",
            scrollbar_f    = "FzfLuaScrollBorderFull",
            scrollbar_e    = "FzfLuaScrollBorderEmpty",
        },
        -- Window options, using custom gradient borders
        winopts = {
            border = require("gradient_border").get(),
            preview = {
                border = require("gradient_border").get()
            }
        }
    })
end

-- Plugin spec for lazy.nvim
return { "ibhagwan/fzf-lua", dependencies = { "kyazdani42/nvim-web-devicons" }, init = M.init, config = M.config }
