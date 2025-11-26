
local G = require('G')
local M = {}

function M.config()
end

function M.setup()
local dap = require("dap")
local dap_utils = require("dap.utils")

-- 启用调试日志（帮助排查问题）
dap.set_log_level('TRACE')

-- 配置 pwa-node adapter (使用 executable 类型，更简单可靠)
dap.adapters["pwa-node"] = function(cb, config)
  if config.preLaunchTask then
    vim.fn.system(config.preLaunchTask)
  end

  -- vsDebugServer 使用随机端口启动，不要使用 config.port
  cb({
    type = "server",
    host = "127.0.0.1",
    port = "${port}",  -- 这是 vsDebugServer 的端口，会自动分配
    executable = {
      command = "node",
      args = {
        os.getenv("HOME") .. "/.DAP/vscode-js-debug/out/src/vsDebugServer.js",
        "${port}"
      },
    }
  })
end

-- 配置 pwa-chrome adapter
dap.adapters["pwa-chrome"] = function(cb, config)
  cb({
    type = "server",
    host = "127.0.0.1",
    port = "${port}",  -- vsDebugServer 的端口，会自动分配
    executable = {
      command = "node",
      args = {
        os.getenv("HOME") .. "/.DAP/vscode-js-debug/out/src/vsDebugServer.js",
        "${port}"
      },
    }
  })
end

local exts = {
  "javascript",
  "typescript",
  "javascriptreact",
  "typescriptreact",
  -- using pwa-chrome
  "vue",
  "svelte",
}

for i, ext in ipairs(exts) do
  dap.configurations[ext] = {
    -- NestJS/Express 附加到运行中的服务器（最常用）
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to NestJS/Node Server (Port 9229)",
      -- 使用 cwd 而不是 ${workspaceFolder}，这样会使用当前工作目录
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      address = "localhost",
      port = 9229,
      restart = true,
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
      outFiles = {
        "${workspaceFolder}/dist/**/*.js",
        "!**/node_modules/**",
      },
    },
    -- 自定义端口附加
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to Node Server (Custom Port)",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      port = function()
        return tonumber(vim.fn.input("Debug port: ", "9229"))
      end,
      restart = true,
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node)",
      cwd = "${workspaceFolder}",
      args = { "${file}" },
      sourceMaps = true,
      protocol = "inspector",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node with ts-node)",
      cwd = "${workspaceFolder}",
      runtimeArgs = { "--loader", "ts-node/esm" },
      runtimeExecutable = "node",
      args = { "${file}" },
      sourceMaps = true,
      protocol = "inspector",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
      resolveSourceMapLocations = {
        "${workspaceFolder}/**",
        "!**/node_modules/**",
      },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Current File (pwa-node with deno)",
      cwd = "${workspaceFolder}",
      runtimeArgs = { "run", "--inspect-brk", "--allow-all", "${file}" },
      runtimeExecutable = "deno",
      attachSimplePort = 9229,
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Current File (pwa-node with jest)",
      cwd = "${workspaceFolder}",
      runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest" },
      runtimeExecutable = "node",
      args = { "${file}", "--coverage", "false" },
      rootPath = "${workspaceFolder}",
      sourceMaps = true,
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Current File (pwa-node with vitest)",
      cwd = "${workspaceFolder}",
      program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
      args = { "--inspect-brk", "--threads", "false", "run", "${file}" },
      autoAttachChildProcesses = true,
      smartStep = true,
      console = "integratedTerminal",
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch Test Current File (pwa-node with deno)",
      cwd = "${workspaceFolder}",
      runtimeArgs = { "test", "--inspect-brk", "--allow-all", "${file}" },
      runtimeExecutable = "deno",
      smartStep = true,
      console = "integratedTerminal",
      attachSimplePort = 9229,
    },
    {
      type = "pwa-chrome",
      request = "attach",
      name = "Attach Program (pwa-chrome, select port)",
      program = "${file}",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      port = function()
        return G.fn.input("Select port: ", 9222)
      end,
      webRoot = "${workspaceFolder}",
    },
    {
      type = "node2",
      request = "attach",
      name = "Attach Program (Node2)",
      processId = dap_utils.pick_process,
    },
    {
      type = "node2",
      request = "attach",
      name = "Attach Program (Node2 with ts-node)",
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      skipFiles = { "<node_internals>/**" },
      port = 9229,
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach Program (pwa-node, select pid)",
      cwd = "${workspaceFolder}",
      processId = dap_utils.pick_process,
      skipFiles = { "<node_internals>/**" },
    },
  }
end





  local dapui = require("dapui")

  dapui.setup({
    controls = {
      element = "repl",
      enabled = true,
      icons = {
        disconnect = "",
        pause = "",
        play = "",
        run_last = "",
        step_back = "",
        step_into = "",
        step_out = "",
        step_over = "",
        terminate = ""
      }
    },
    element_mappings = {},
    expand_lines = true,
    floating = {
      border = "single",
      mappings = {
        close = { "q", "<Esc>" }
      }
    },
    force_buffers = true,
    icons = {
      collapsed = "",
      current_frame = "",
      expanded = ""
    },
    layouts = { {
        elements = { {
            id = "scopes",
            size = 0.25
          }, {
            id = "breakpoints",
            size = 0.25
          }, {
            id = "stacks",
            size = 0.25
          }, {
            id = "watches",
            size = 0.25
          } },
        position = "left",
        size = 40
      }, {
        elements = { {
            id = "repl",
            size = 0.5
          }, {
            id = "console",
            size = 0.5
          } },
        position = "bottom",
        size = 10
      } },
    mappings = {
      edit = "e",
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      repl = "r",
      toggle = "t"
    },
    render = {
      indent = 1,
      max_value_lines = 100
    }
  })

  local dap = require("dap")
  dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open({})
  end

  dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close({})
  end


  dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close({})
  end
  
  -- 打开/关闭dapui
  vim.keymap.set('n', '<leader>ui', require 'dapui'.toggle)
  -- 打开/关闭repl
  vim.keymap.set('n', '<F6>', require 'dap'.continue)
  -- 进入下一行
  vim.keymap.set('n', '<F10>', require 'dap'.step_over)
  -- 进入函数
  vim.keymap.set('n', '<F11>', require 'dap'.step_into)
  -- 退出函数
  vim.keymap.set('n', '<F12>', require 'dap'.step_out)
  -- 设置断点
  vim.keymap.set('n', '<leader>b', require 'dap'.toggle_breakpoint)
  -- 设置条件断点
  vim.keymap.set('n', '<leader>B', function()
    require 'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end)
  -- 查看 DAP 日志（排查问题用）
  vim.keymap.set('n', '<leader>dl', function()
    local log_path = vim.fn.stdpath('cache') .. '/dap.log'
    vim.cmd('edit ' .. log_path)
  end, { desc = 'Open DAP log file' })









  local dap_breakpoint_color = {
      breakpoint = {
          ctermbg=0,
          fg='#993939',
          bg='#31353f',
      },
      logpoing = {
          ctermbg=0,
          fg='#61afef',
          bg='#31353f',
      },
      stopped = {
          ctermbg=0,
          fg='#98c379',
          bg='#31353f'
      },
  }

  G.api.nvim_set_hl(0, 'DapBreakpoint', dap_breakpoint_color.breakpoint)
  G.api.nvim_set_hl(0, 'DapLogPoint', dap_breakpoint_color.logpoing)
  G.api.nvim_set_hl(0, 'DapStopped', dap_breakpoint_color.stopped)

  local dap_breakpoint = {
      error = {
          text = "●",
          texthl = "DapBreakpoint",
          linehl = "DapBreakpoint",
          numhl = "DapBreakpoint",
      },
      condition = {
          text = 'ﳁ',
          texthl = 'DapBreakpoint',
          linehl = 'DapBreakpoint',
          numhl = 'DapBreakpoint',
      },
      rejected = {
          text = "",
          texthl = "DapBreakpint",
          linehl = "DapBreakpoint",
          numhl = "DapBreakpoint",
      },
      logpoint = {
          text = '',
          texthl = 'DapLogPoint',
          linehl = 'DapLogPoint',
          numhl = 'DapLogPoint',
      },
      stopped = {
          text = '',
          texthl = 'DapStopped',
          linehl = 'DapStopped',
          numhl = 'DapStopped',
      },
  }

  G.fn.sign_define('DapBreakpoint', dap_breakpoint.error)
  G.fn.sign_define('DapBreakpointCondition', dap_breakpoint.condition)
  G.fn.sign_define('DapBreakpointRejected', dap_breakpoint.rejected)
  G.fn.sign_define('DapLogPoint', dap_breakpoint.logpoint)
  G.fn.sign_define('DapStopped', dap_breakpoint.stopped)

  require("nvim-dap-virtual-text").setup {
      enabled = true,                        -- enable this plugin (the default)
      enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
      highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
      highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
      show_stop_reason = true,               -- show stop reason when stopped for exceptions
      commented = false,                     -- prefix virtual text with comment string
      only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
      all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
      clear_on_continue = false,             -- clear virtual text on "continue" (might cause flickering when stepping)
      --- A callback that determines how a variable is displayed or whether it should be omitted
      --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
      --- @param buf number
      --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
      --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
      --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
      --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
      display_callback = function(variable, buf, stackframe, node, options)
      -- by default, strip out new line characters
        if options.virt_text_pos == 'inline' then
          return ' = ' .. variable.value:gsub("%s+", " ")
        else
          return variable.name .. ' = ' .. variable.value:gsub("%s+", " ")
        end
      end,
      -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
      virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

      -- experimental features:
      all_frames = false,                    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
      virt_lines = false,                    -- show virtual lines instead of virtual text (will flicker!)
      virt_text_win_col = nil                -- position the virtual text at a fixed window column (starting from the first text column) ,
                                             -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
  }
end

return M










