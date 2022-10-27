
local G = require('G')
local nvim_tree = require("nvim-tree")
nvim_tree.setup({
  auto_reload_on_write = true,
  disable_netrw = false,
  hijack_cursor = false,
  hijack_netrw = true,
  hijack_unnamed_buffer_when_opening = false,
  ignore_buffer_on_setup = false,
  open_on_setup = false,
  open_on_setup_file = false,
  open_on_tab = false,
  reload_on_bufenter = true,
  sort_by = "name",
  view = {
    width = 46,
    hide_root_folder = false,
    side = "left",
    preserve_window_proportions = false,
    number = false,
    relativenumber = true,
    signcolumn = "yes",
    mappings = {
        list = {
            { key = "P", action = "cd" },
            { key = "<BS>", action = "dir_up" },
            { key = "<Esc>", action = "close" },
            { key = "<Tab>", action = "expand" },
            { key = "<Right>", action = "expand" },
            { key = "<Left>", action = "close_node" },
            { key = ">", action = "next_git_item" },
            { key = "<", action = "prev_git_item" },
            { key = "?", action = "toggle_help" },
            { key = "A", action = "create" },
        },
    },
    float = { enable = true, open_win_config = { border = "rounded", width = 46, height = 60, row = 0, col = 999 } }

  },
  renderer = {
    indent_markers = {
      enable = false,
      icons = {
        corner = "└ ",
        edge = "│ ",
        none = "  ",
      },
    },
    icons = {
      webdev_colors = true,
    },
  },
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
    ignore_list = {},
  },
  ignore_ft_on_setup = {},
  system_open = {
    cmd = "",
    args = {},
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  filters = {
    dotfiles = false,
    custom = {},
    exclude = {},
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 400,
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
})
G.g.nvim_tree_firsttime = 1
G.map({ { 'n', '<F1>', 'g:nvim_tree_firsttime != 1 ? ":NvimTreeToggle<cr>" : ":let g:nvim_tree_firsttime = 0<cr>:NvimTreeToggle $PWD<cr>"', {silent = true, noremap = true, expr = true}} })
G.cmd("hi! NvimTreeCursorLine cterm=NONE ctermbg=237")
G.cmd("hi! link NvimTreeFolderIcon NvimTreeFolderName")
