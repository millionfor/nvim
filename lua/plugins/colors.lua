return {
    "brenoprata10/nvim-highlight-colors",
    config = function()
        require("nvim-highlight-colors").setup({
            render = 'foreground', -- or 'foreground' or 'first_column'
            enable_named_colors = true,
            enable_tailwind = true,
        })
    end,
}
