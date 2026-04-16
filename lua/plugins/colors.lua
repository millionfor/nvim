-- 颜色高亮插件配置
return {
    "brenoprata10/nvim-highlight-colors",
    config = function()
        require("nvim-highlight-colors").setup({
            -- 渲染方式：'background' (背景色), 'foreground' (前景色) 或 'first_column' (第一列)
            render = 'foreground', 
            -- 启用命名颜色高亮 (例如: 'red', 'blue')
            enable_named_colors = true,
            -- 启用 Tailwind CSS 颜色高亮
            enable_tailwind = true,
        })
    end,
}
