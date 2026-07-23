local mason_registry = require("mason-registry")
local jdtls_pkg = mason_registry.get_package("jdtls")
if not jdtls_pkg:is_installed() then
  return
end

local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"

local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local lombok_path = jdtls_path .. "/lombok.jar"

local os_config = "mac"
if vim.fn.has("mac") == 1 then
  os_config = "mac"
elseif vim.fn.has("unix") == 1 then
  os_config = "linux"
elseif vim.fn.has("win32") == 1 then
  os_config = "win"
end

local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
  return
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name

local config = {
  cmd = {
    "/opt/homebrew/opt/openjdk@21/bin/java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-javaagent:" .. lombok_path,
    "-jar", launcher_jar,
    "-configuration", jdtls_path .. "/config_" .. os_config,
    "-data", workspace_dir
  },
  root_dir = root_dir,
  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        -- 在这里配置您的 Java 8 路径，告诉 jdtls 使用 Java 8 来编译和校验您的项目
        runtimes = {
          {
            name = "JavaSE-1.8",
            path = "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home",
          }
        }
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = "all", -- literals, all, none
        },
      },
      format = {
        enabled = true,
      },
    },
    signatureHelp = { enabled = true },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*"
      },
    },
  },
  init_options = {
    bundles = {}
  },
}

-- 绑定额外的快捷键 (可选)
config.on_attach = function(client, bufnr)
  -- 在这里你可以绑定 Java 特有的快捷键，比如组织导入，抽取变量等
  -- 基础的 LSP 快捷键由于全局配置应该已经生效了
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', '<leader>jo', require('jdtls').organize_imports, opts)
  vim.keymap.set('n', '<leader>jv', require('jdtls').extract_variable, opts)
  vim.keymap.set('v', '<leader>jv', '<Esc><Cmd>lua require("jdtls").extract_variable(true)<CR>', opts)
  vim.keymap.set('n', '<leader>jc', require('jdtls').extract_constant, opts)
  vim.keymap.set('v', '<leader>jc', '<Esc><Cmd>lua require("jdtls").extract_constant(true)<CR>', opts)
  vim.keymap.set('n', '<leader>jm', require('jdtls').extract_method, opts)
  vim.keymap.set('v', '<leader>jm', '<Esc><Cmd>lua require("jdtls").extract_method(true)<CR>', opts)
end

require("jdtls").start_or_attach(config)
