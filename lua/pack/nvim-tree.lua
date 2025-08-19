local G = require('G')
local M = {}

-- 有时候进入到依赖文件内，此时想在依赖文件所在目录查看文件 nvim-tree 并没有一个很好的方法，所以写了这个func
local inner_cwd = ""
local outer_cwd = ""
function M.magicCd()
    local api = require("nvim-tree.api")
    local core = require("nvim-tree.core")

    local file_path = G.fn.expand('#:p:h')
    local tree_cwd = core.get_cwd()

    if inner_cwd == "" then
        inner_cwd = tree_cwd
    end

    -- 树在内部目录 且 当前文件为外部文件 则切换到外部目录
    if tree_cwd == inner_cwd and string.find(file_path, '^' .. inner_cwd) == nil then
        inner_cwd = tree_cwd
        outer_cwd = file_path
        return api.tree.change_root(file_path)
    end

    -- 树在内部目录 且 当前文件为内部文件 则切换到外部目录（如果有的话）
    if tree_cwd == inner_cwd and string.find(file_path, '^' .. inner_cwd) ~= nil then
        if outer_cwd ~= "" then
            return api.tree.change_root(outer_cwd)
        end
    end

    -- 树在外部目录 且 当前文件为外部文件 则切换到内部目录
    if tree_cwd ~= inner_cwd and string.find(file_path, '^' .. outer_cwd) ~= nil then
        return api.tree.change_root(inner_cwd)
    end

    -- 树在外部目录 且 当前文件为内部文件 则切换到内部目录
    if tree_cwd ~= inner_cwd and string.find(file_path, '^' .. inner_cwd) ~= nil then
        return api.tree.change_root(inner_cwd)
    end
end


function M.config()
    -- G.g.nvim_tree_firsttime = 1
    -- G.map({ { 'n', '<leader>e', 'g:nvim_tree_firsttime != 1 ? ":NvimTreeToggle<cr>" : ":let g:nvim_tree_firsttime = 0<cr>:NvimTreeToggle $PWD<cr>"', {silent = true, noremap = true, expr = true}} })
    G.cmd("hi! NvimTreeCursorLine cterm=NONE ctermbg=238")
    G.cmd("hi! link NvimTreeFolderIcon NvimTreeFolderName")
    G.cmd("au FileType NvimTree nnoremap <buffer> <silent> C :lua require('pack.nvim-tree').magicCd()<cr>")
end

function M.setup()
    local nvim_tree = require("nvim-tree")

    local function on_attach(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set('n', 'P', api.tree.change_root_to_node, opts('CD'))
        vim.keymap.set('n', '<BS>', api.tree.change_root_to_parent, opts('Up'))
        vim.keymap.set('n', '<Esc>', api.tree.close, opts('Close'))
        vim.keymap.set('n', '<Left>', api.node.navigate.parent_close, opts('Close Directory'))
        vim.keymap.set('n', '<Right>', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', '<CR>',  api.node.open.edit, opts('Open'))
        vim.keymap.set('n', ')', api.node.navigate.git.next, opts('Next Git'))
        vim.keymap.set('n', '(', api.node.navigate.git.prev, opts('Prev Git'))
        vim.keymap.set('n', '>', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
        vim.keymap.set('n', '<', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
        vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
        vim.keymap.set('n', 'A', api.fs.create, opts('Create'))
        vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
        vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))

        -- 当前目录
        vim.keymap.set("n", "<leader>op", function()
          local node = require("nvim-tree.api").tree.get_node_under_cursor()
          if node then
            local path = node.absolute_path
            -- 转义单引号和空格
            path = path:gsub("'", "'\\''")
            vim.cmd("silent !/usr/bin/open '" .. path .. "'")
          end
        end, { desc = "Open in Finder" })


        -- 转换为 kebab-case (xxx-xx-xx)
        local function to_kebab_case(file_name)
          -- 1. 先将所有非字母数字字符替换为下划线
          local underscored = string.gsub(file_name, "%W", "_")

          -- 2. 将连续的下划线替换为单个下划线
          underscored = string.gsub(underscored, "__+", "_")

          -- 3. 将大写字母转换为小写，并在大写字母前插入下划线 (camelCase to snake_case)
          local snake_case = string.gsub(underscored, "%u", function(c)
            return "_" .. string.lower(c)
          end)

          -- 4. 将所有下划线替换为横杠
          local kebab_case = string.gsub(snake_case, "_", "-")

          -- 5. 移除字符串开头和结尾的横杠
          kebab_case = string.gsub(kebab_case, "^%-", "")
          kebab_case = string.gsub(kebab_case, "%-$", "")

          return kebab_case
        end

        -- 转换为 PascalCase (XxxXxxXxx)
        local function to_pascal_case(file_name)
          -- 将连字符和下划线替换为空格
          file_name = string.gsub(file_name, "[-_]", " ")

          -- 将字符串分割成单词
          local words = {}
          for word in string.gmatch(file_name, "%S+") do
            table.insert(words, word)
          end

          -- 将每个单词首字母大写，然后连接在一起
          local pascal_case = ""
          for _, word in ipairs(words) do
            pascal_case = pascal_case .. string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2)
          end

          return pascal_case
        end

        -- 获取当前星期
        local function get_chinese_weekday()
            local day = os.date("%A")
            local days = {
                ["星期日"] = "日",
                ["星期一"] = "一",
                ["星期二"] = "二",
                ["星期三"] = "三",
                ["星期四"] = "四",
                ["星期五"] = "五",
                ["星期六"] = "六"
            }
            return days[day]
        end

        -- 定义模板路径（按需修改路径）
        local template_dir = vim.fn.expand("~/.config/nvim/templates")

        -- 监听文件创建事件
        api.events.subscribe(api.events.Event.FileCreated, function(data)
          local file_path = data.fname
          local file_ext = vim.fn.fnamemodify(file_path, ":e")

          -- 获取对应模板路径
          local template_file = ({
            vue = "vue.template",
            sh = "sh.template",
            ts = "ts.template",
            js = "js.template",
            rs = "rs.template",
            -- 添加更多文件类型...
          })[file_ext]

          if template_file then
            local template_path = template_dir .. "/" .. template_file

            -- 仅当新文件为空时才插入模板
            local content = vim.fn.readfile(file_path)
            if #content == 0 then
              local ok, template = pcall(vim.fn.readfile, template_path)
              if ok then
                -- 生成 SNAKE_CASE 变量
                local file_name = vim.fn.fnamemodify(file_path, ":t:r")
                local kebab_class = to_kebab_case(file_name)
                local pascal_case = to_pascal_case(file_name)


                -- 替换模板中的变量
                local replaced_template = string.gsub(table.concat(template, "\n"), "{{SNAKE_CLASS}}", kebab_class)
                replaced_template = string.gsub(replaced_template, "{{CAMEL_CLASS}}", pascal_case)
                replaced_template = string.gsub(replaced_template, "{{FILE}}", file_name)
                replaced_template = string.gsub(replaced_template, "{{NAME}}", "QuanQuan")
                replaced_template = string.gsub(replaced_template, "{{EMAIL}}", "millionfor@apache.org")
                replaced_template = string.gsub(replaced_template, "{{DAY}}",get_chinese_weekday())
                replaced_template = string.gsub(replaced_template, "{{MONTH}}",os.date("%m"))
                replaced_template = string.gsub(replaced_template, "{{DATE}}",os.date("%d"))
                replaced_template = string.gsub(replaced_template, "{{YEAR}}",tonumber(os.date("%Y")))
                replaced_template = string.gsub(replaced_template, "{{TIME}}",os.date("%H:%M:%S %Z"))

                vim.fn.writefile(vim.split(replaced_template, "\n"), file_path)
                print("Template added: " .. template_file)
              else
                print("Template not found: " .. template_file)
              end
            end
          end

        end)

    end

    nvim_tree.setup({
        on_attach = on_attach,
        sort_by = "case_sensitive",
        actions = {
            open_file = {
                window_picker = { enable = false }
            }
        },
        view = {
            float = {
                enable = true,
                open_win_config = function()
                    local columns = G.o.columns
                    local lines = G.o.lines
                    local width = math.max(math.floor(columns * 0.25), 50)
                    local height = math.max(math.floor(lines * 0.8), 20)
                    local left = math.ceil((columns - width) * 0.5)
                    local top = math.ceil((lines - height) * 0.5 - 2)
                    return { relative = "editor", border = "rounded", width = width, height = height, row = top, col = left }
                end,
            }
        },
        update_focused_file = {
            enable = true,
            update_root = false,
            ignore_list = {},
        },
        renderer = {
            group_empty = true,
            indent_markers = { enable = true },
            icons = {
                git_placement = "after", webdev_colors = true,
                glyphs = {
                    git = { unstaged = "~", staged = "✓", unmerged = "", renamed = "+", untracked = "?", deleted = "", ignored = " " },
                    folder = { empty = "", empty_open = "" }
                }
            }
        },
        filters = {
          -- 过滤隐藏文件
          dotfiles = false
        },
        diagnostics = {
            enable = true, show_on_dirs = true, debounce_delay = 50,
            icons = { hint = "", info = "", warning = "", error = "" }
        },
    })

end


return M

