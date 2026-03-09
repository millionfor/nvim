local M = {}

function M.init()
    vim.g['prettier#quickfix_enabled'] = 1
    vim.g['prettier#autoformat'] = 0
    vim.g['prettier#autoformat_require_pragma'] = 0
    vim.g['prettier#autoformat_config_files'] = '~/.prettierrc'

    vim.keymap.set('n', 'pr', ':PrettierAsync<cr>', { silent = true, noremap = true, desc = 'Prettier Format' })
end

return {
    "prettier/vim-prettier",
    build = "yarn install",
    init = M.init,
    cmd = { "Prettier", "PrettierAsync", "PrettierFragment" }
}
