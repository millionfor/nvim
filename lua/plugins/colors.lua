-- 颜色高亮插件配置
return {
    "brenoprata10/nvim-highlight-colors",
    config = function()
        require("nvim-highlight-colors").setup({
            -- 渲染方式：'background' (背景色), 'foreground' (前景色) 或 'first_column' (第一列)
            render = 'foreground', 
            -- 禁用命名颜色高亮 (例如: 'red', 'blue' 会匹配普通变量名导致频繁扫描卡顿)
            enable_named_colors = false,
            -- 启用 Tailwind CSS 颜色高亮
            enable_tailwind = true,
        })
    end,
}
