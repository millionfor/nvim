local M = {}

M.lsp_by_ft = {
    lua = { "lua_ls" },
    solidity = { "solidity_ls" },
    javascript = { "vtsls", "tailwindcss" },
    javascriptreact = { "vtsls", "tailwindcss" },
    typescript = { "vtsls", "tailwindcss" },
    typescriptreact = { "vtsls", "tailwindcss" },
    vue = { "vue_ls", "vtsls", "tailwindcss", "emmet_ls" },
    html = { "html", "tailwindcss", "emmet_ls" },
    css = { "cssls", "tailwindcss", "emmet_ls" },
    scss = { "cssls", "tailwindcss", "emmet_ls" },
    less = { "cssls", "tailwindcss", "emmet_ls" },
    json = { "jsonls" },
    jsonc = { "jsonls" },
    go = { "gopls" },
    gomod = { "gopls" },
    gowork = { "gopls" },
    gotmpl = { "gopls" },
    sh = { "bashls" },
    bash = { "bashls" },
    zsh = { "bashls" },
}

M.pkg_by_lsp = {
    lua_ls = "lua-language-server",
    vue_ls = "vue-language-server",
    vtsls = "vtsls",
    jsonls = "json-lsp",
    html = "html-lsp",
    cssls = "css-lsp",
    gopls = "gopls",
    bashls = "bash-language-server",
    tailwindcss = "tailwindcss-language-server",
    emmet_ls = "emmet-ls",
    solidity_ls = "nomicfoundation-solidity-language-server",
}

vim.diagnostic.config({ signs = { text = { [1] = '┃', [2] = '┃', [3] = '┃', [4] = '┃' } }, update_in_insert = false })
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, {
            scope = "cursor",
            focusable = false,
            border = require("gradient_border").get(),
            header = "",
            prefix = "",
        })
    end
})

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "VimEnter" }, {
    group = vim.api.nvim_create_augroup("MYLSPINIT", { clear = true }),
    callback = function(event)
        local registry = require("mason-registry")
        for _, lsp in ipairs(M.lsp_by_ft[vim.bo[event.buf].filetype] or {}) do
            local pkg_name = M.pkg_by_lsp[lsp]
            local ok, pkg = pcall(registry.get_package, pkg_name)
            if ok then
                if not pkg:is_installed() and not pkg:is_installing() then
                    print("Installing " .. pkg_name .. " for " .. lsp)
                    pkg:install()
                end

                local lsp_config = {}
                local has_config, config = pcall(require, "lsp." .. lsp)
                if has_config then
                    lsp_config = config
                end
                vim.lsp.config(lsp, lsp_config)
                vim.lsp.enable(lsp)
            end
        end
    end,
})
