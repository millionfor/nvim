

local G = require('G')
local M = {}


function M.config()

end

function M.setup()
    local alpha = require'alpha'

  local startify = require'alpha.themes.startify'

  local logo = {
    type = 'text',
    val = {
      [[                      ____                     ____                      _____ _____  ______            ]],
      [[  █████              / __ \                   / __ \                    |_   _|  __ \|  ____|   /\      ]],
      [[▒██▓  ██▒           | |  | |_   _  __ _ _ __ | |  | |_   _  __ _ _ __     | | | |  | | |__     /  \     ]],
      [[▒██▒  ██░           | |  | | | | |/ _  |  _ \| |  | | | | |/ _  |  _ \    | | | |  | |  __|   / /\ \    ]],
      [[░██  █▀ ░           | |__| | |_| | (_| | | | | |__| | |_| | (_| | | | |  _| |_| |__| | |____ / ____ \   ]],
      [[░▒███▒█▄             \___\_\\__,_|\__,_|_| |_|\___\_\\__,_|\__,_|_| |_| |_____|_____/|______/_/    \_\  ]],
      [[░░ ▒▒░ ▒                                                                                                ]],
      [[ ░ ▒░  ░            +---------------------------------------------------------------------------------+']],
      [[   ░   ░            |          圈圈(@millionfor) <millionfor@apache.org> wwww.quanquansy.com          |']],
      [[    ░               +---------------------------------------------------------------------------------+']],
    },
    opts = {
      position = 'center',
      hl = 'WarningMsg',
    },
  }


  local info = {
    type = 'text',
    opts = {
      hl = 'DevIconVim',
      position = 'left',
    },
  }

  local message = {
    type = 'text',
    val = ' ',
    opts = {
      position = 'left',
      hl = 'Statement',
    },
  }

  local header = {
    type = 'group',
    val = {
      logo,
      info,
      message,
    },
  }

  local buttons = {
    type = 'group',
    val = {
      {
        type = 'text',
        val = 'Actions',
        opts = {
          hl = 'String',
          position = 'left',
          width = 10
        },
      },
      { type = 'padding', val = 1 },
      startify.button('e', '  New file', ':ene <BAR> startinsert<CR>'),
      startify.button('f', '  Find file', ":Files<CR>"),
      -- startify.button('a', '  Live grep', "<cmd>lua require('telescope.builtin').live_grep({shorten_path=true})<CR>"),
      -- startify.button(
      --   'd',
      --   '  Dotfiles',
      --   "<cmd>lua require('telescope.builtin').find_files({ search_dirs = { os.getenv('HOME') .. '/dotfiles' } })<CR>"
      -- ),
      startify.button('u', '  Update plugins', ':PackerSync<CR>'),
      startify.button('q', '  Quit', ':qa<CR>'),
    },
    opts = {
      position = 'left',
      width = 50,
      spacing = 0
    },
  }

  local mru = {
    type = 'group',
    val = {
      {
        type = 'text',
        val = 'Recent files',
        opts = {
          hl = 'String',
          position = 'left',
          width = 50,
        },
      },
      { type = 'padding', val = 1 },
      {
        type = 'group',
        val = function()
          return { startify.mru(1, vim.fn.getcwd(), 30) }
        end,
      },
    },
  }


  local config = {
    layout = {
      header,
      { type = 'padding', val = 1 },
      mru,
      { type = 'padding', val = 1 },
      buttons
    }
  }
  alpha.setup(config)
    -- do nothing

end

return M




