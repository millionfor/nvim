return {
    "Vonr/align.nvim",
    branch = "v2",
    keys = {
        -- 与 1 个字符对齐 (Visual 模式)
        {
            "<leader>a",
            function()
                require("align").align_to_char({
                    preview = true,
                    length = 1,
                })
            end,
            mode = "x",
            desc = "Align to 1 char"
        },
        -- 与 1 个字符对齐 (Normal 模式 - 操作符)
        {
            "<leader>a",
            function()
                local a = require("align")
                a.operator(a.align_to_char, {
                    preview = true,
                    length = 1,
                })
            end,
            mode = "n",
            desc = "Align operator (1 char)"
        },
        -- 通过预览对齐 2 个字符
        {
            "ad",
            function()
                require("align").align_to_char({
                    preview = true,
                    length = 2,
                })
            end,
            mode = "x",
            desc = "Align to 2 chars"
        },
        -- 通过预览与字符串对齐
        {
            "aw",
            function()
                require("align").align_to_string({
                    preview = true,
                    regex = false,
                })
            end,
            mode = "x",
            desc = "Align to string"
        },
        -- 与带有预览的 Vim 正则表达式对齐
        {
            "ar",
            function()
                require("align").align_to_string({
                    preview = true,
                    regex = true,
                })
            end,
            mode = "x",
            desc = "Align to regex"
        },
        -- 使用预览将段落与字符串对齐的 gawip 示例
        {
            "gaw",
            function()
                local a = require("align")
                a.operator(a.align_to_string, {
                    regex = false,
                    preview = true,
                })
            end,
            mode = "n",
            desc = "Align operator (string)"
        },
        -- 将段落与 1 个字符对齐的 gaaip 示例
        {
            "gaa",
            function()
                local a = require("align")
                a.operator(a.align_to_char)
            end,
            mode = "n",
            desc = "Align operator (1 char)"
        },
    }
}
