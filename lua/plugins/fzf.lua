local M = {}

function M.init()
    local get_cwd_opts = function()
        local cwd = os.getenv("PWD") or vim.fn.getcwd()
        local has_gitignore = vim.fn.filereadable(cwd .. "/.gitignore") == 1
        return {
            cwd = cwd,
            fd_opts = "--color=never --type f --hidden --follow --exclude .git" .. (not has_gitignore and " --no-ignore" or ""),
            rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden " .. (not has_gitignore and "--no-ignore " or "") .. "-g '!.git'",
        }
    end

    vim.keymap.set('n', '<c-f>', function() require("fzf-lua").files(get_cwd_opts()) end, { silent = true, noremap = true })
    vim.keymap.set('n', '<c-a>', function() require("fzf-lua").live_grep(get_cwd_opts()) end, { silent = true, noremap = true })
    vim.keymap.set('n', '<c-b>', function() require("fzf-lua").buffers() end, { silent = true, noremap = true })
    vim.keymap.set('n', '<c-l>', function() require("fzf-lua").blines() end, { silent = true, noremap = true })
    vim.keymap.set('n', '<c-g>', function() require("fzf-lua").git_status({ cwd = os.getenv("PWD") }) end, { silent = true, noremap = true })
    vim.keymap.set('n', '<c-h>', function() require("fzf-lua").oldfiles({ cwd = os.getenv("PWD"), cwd_only = true }) end, { silent = true, noremap = true })
end

function M.config()
    require("fzf-lua").setup({
        hls = {
            border         = "FloatBorder",
            scrollbar_f    = "FzfLuaScrollBorderFull",
            scrollbar_e    = "FzfLuaScrollBorderEmpty",
        },
        winopts = {
            border = require("gradient_border").get(),
            preview = {
                border = require("gradient_border").get()
            }
        }
    })
end

return { "ibhagwan/fzf-lua", dependencies = { "kyazdani42/nvim-web-devicons" }, init = M.init, config = M.config }
