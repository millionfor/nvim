local M = {}

function M.init()
    -- 设置模板目录
    vim.g.tmpl_search_paths = { '~/.config/nvim/templates' }

    vim.g.tmpl_author_name = 'QuanQuan'
    vim.g.tmpl_author_email = 'millionfor@apache.org'
    vim.g.tmpl_author_hostname = 'quanquan.app'
end

return {
    {
        "tibabit/vim-templates",
        init = M.init,
    }
}
