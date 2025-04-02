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

function ToggleNvimTreeFocus()
  local nvim_tree = require("nvim-tree.api").tree
  local current_win = vim.api.nvim_get_current_win()
  local nvim_tree_win = nvim_tree.get_win()

  if nvim_tree_win and nvim_tree_win == current_win then
    vim.api.nvim_set_current_win(vim.api.nvim_list_wins()[1])  -- 切换到第一个窗口
  else
    nvim_tree.focus()
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
    

    -- 焦点位置来回切换
    -- vim.keymap.set('n', '<S-space>', function()
    --   if vim.fn.bufname():match 'NvimTree_' then
    --     vim.cmd.wincmd 'p'
    --   else
    --     vim.cmd('NvimTreeFindFile')

    --   end
    -- end, { desc = 'nvim-tree: toggle' })

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

        -- 打开当前目录
        vim.keymap.set("n", "<leader>op", function()
          local node = require("nvim-tree.api").tree.get_node_under_cursor()
          if node then
            local path = node.absolute_path
            -- 转义单引号和空格
            path = path:gsub("'", "'\\''")
            vim.cmd("silent !/usr/bin/open '" .. path .. "'")
          end
        end, { desc = "Open in Finder" })

    end

    nvim_tree.setup({
        sort_by = "case_sensitive",
        on_attach = on_attach,
        view = {
          centralize_selection = false,
          cursorline = true,
          debounce_delay = 15,
          width = 40,
          side = "left",
          preserve_window_proportions = false,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
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
                glyphs = { git = { unstaged = "~", staged = "✓", unmerged = "", renamed = "+", untracked = "?", deleted = "", ignored = " " } }
            }
        },
        diagnostics = {
            enable = true, show_on_dirs = true, debounce_delay = 50,
            icons = { hint = "", info = "", warning = "", error = "" }
        },
        actions = {
          use_system_clipboard = true,
          change_dir = {
            enable = true,
            global = false,
            restrict_above_cwd = false,
          },
          open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
              enable = true,
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                buftype = { "nofile", "terminal", "help" },
              },
            },
          },
        },
        trash = {
          cmd = "trash",
          require_confirm = true,
        },
        log = {
          enable = false,
          truncate = false,
          types = {
            all = false,
            config = false,
            copy_paste = false,
            diagnostics = false,
            git = false,
            profile = false,
          },
        },
        git = {
          enable = true,
          ignore = true,
          timeout = 400,
        },
        filters = {
          dotfiles = false,
          custom = {},
          exclude = {},
        },
    })
end

return M

