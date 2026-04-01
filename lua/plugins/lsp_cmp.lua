-- LSP 相关的插件配置
local M = {}

function M.init_blink()
    vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpActiveParameter", { fg = "#00afaf", bold = true })
    vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = "#00afaf" })
    -- Making scrollbar match the gradient border color
    vim.api.nvim_set_hl(0, "BlinkCmpMenuScrollbar", { fg = "#ff87d7" })
    
    vim.api.nvim_create_autocmd('CmdlineEnter', {
        callback = function()
            local type = vim.fn.getcmdtype()
            if type == '/' or type == '?' or type == ':' then
                vim.schedule(function()
                    if vim.fn.mode() == 'c' then
                        require('blink.cmp').show()
                    end
                end)
            end
        end
    })
end

M.blink_opts = {
    enabled = function() return vim.bo.filetype ~= 'sagarename' end,
    snippets = { preset = 'luasnip' },
    keymap = {
        preset = 'default',
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },

        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-y>'] = { 'select_and_accept', 'fallback' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-k>'] = { 'show', 'show_documentation', 'hide_documentation' },
    },
    appearance = { nerd_font_variant = 'mono' },
    completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = require('gradient_border').get() } },
        menu = {
            border = require('gradient_border').get(),
            draw = { columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } } }
        },
        list = { selection = { preselect = true, auto_insert = true } },
        ghost_text = { enabled = false },
        accept = { auto_brackets = { enabled = false } }
    },
    signature = { enabled = true, window = { border = require('gradient_border').get() } },
    cmdline = {
        keymap = {

            ['<Up>'] = { 'select_prev', 'fallback' },
            ['<Down>'] = { 'select_next', 'fallback' },
            ['<Left>'] = { },
            ['<Right>'] = { },
            ['<CR>'] = {
                -- 搜索模式时 如果所有选项都是相同的，则直接提交
                function(cmp)
                    if vim.fn.getcmdtype() == '/' and cmp.is_visible() then
                        local items = require('blink.cmp.completion.list').items
                        local all_same = #items > 0
                        for i = 2, #items do if items[i].label ~= items[1].label then all_same = false break end end
                        if all_same then
                            cmp.accept_and_enter()
                            return true
                        end
                    end
                end,
                'select_accept_and_enter',
                'fallback'
            },
            ['<C-e>'] = { 'cancel', 'fallback' },
        },
        sources = { "cmdlinehistory", "cmdline", "buffer" },
        completion = { menu = { auto_show = true }, list = { selection = { preselect = true, auto_insert = true } } }
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', "ripgrep", "datword" },
        providers = {
            datword = { name = "datword", module = "blink-cmp-dat-word", opts = { paths = {  vim.fn.stdpath('config') .. "/word.txt" } } },
            ripgrep = { name = "ripgrep", module = "blink-ripgrep", opts = { debounce_ms = 200, max_item_count = 100 } },
            cmdlinehistory = {
                name = 'history',
                module = 'cmdlinehistory',
                score_offset = 100,
            },
            snippets = {
                score_offset = 100,
            },
        }
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
}

function M.saga_config()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    require('lspsaga').setup({
        ui = { border = require('gradient_border').get(), code_action = '💡' },
        lightbulb = { enable = false },
        beacon = { enable = false },
        symbol_in_winbar = { enable = false },
        finder = { keys = { toggle_or_open = '<cr>', quit = { 'q', '<esc>' } } },
        definition = { keys = { edit = '<cr>', quit = { 'q', '<esc>' } } },
        rename = { in_select = false, keys = { quit = '<esc>' } },
        code_action = { keys = { quit = { 'q', '<esc>' } } },
        diagnostic = { keys = { quit = { 'q', '<esc>' } } },
    })
    vim.lsp.config('*', { capabilities = capabilities })
    vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)

            if client and client.server_capabilities.semanticTokensProvider then
                client.server_capabilities.semanticTokensProvider = nil
            end

            local opts = { silent = true, buffer = bufnr }
            local frontend_jump = require('frontend_jump')
            vim.keymap.set('n', 'gd', function() frontend_jump.jump() end, opts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gy', '<cmd>Lspsaga goto_type_definition<cr>', opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', 'gr', '<cmd>Lspsaga finder<cr>', opts)
            vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<cr>', opts)
            vim.keymap.set({ 'v', 'x', 'n' }, 'ga', '<cmd>Lspsaga code_action<cr>', opts)
            vim.keymap.set('n', '<F2>', '<cmd>Lspsaga rename<cr>A', opts)
            vim.keymap.set('n', '<c-e>', '<cmd>Lspsaga show_buf_diagnostics<cr>', opts)
            vim.keymap.set('n', '\\e', '<cmd>Lspsaga show_workspace_diagnostics<cr>', opts)
            vim.keymap.set({ 'v', 'x' }, '=', function()
                vim.lsp.buf.format({ async = true })
                vim.api.nvim_input('<Esc>')
            end, opts)
        end,
    })
end

return {
    { "mason-org/mason.nvim", lazy = false, opts = { ui = { border = require("gradient_border").get() } }, keys = { { '<leader>m', '<cmd>Mason<cr>', desc = 'Mason' } } },
    { 'nvimdev/lspsaga.nvim', dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons', 'saghen/blink.cmp' }, lazy = false, config = M.saga_config },
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
            require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/lua/snippets" } })
        end
    },
    {
        'saghen/blink.cmp',
        dependencies = { "L3MON4D3/LuaSnip", "xieyonn/blink-cmp-dat-word", "mikavilpas/blink-ripgrep.nvim", "yaocccc/blink-cmp-cmdlinehistory" },
        version = '1.*',
        lazy = false,
        init = M.init_blink,
        opts = M.blink_opts,
        opts_extend = { "sources.default" } 
    },

}
