
-- 设置vue文件自动添加template代码
vim.cmd([[
  augroup auto_vue_template
    au!
    autocmd BufNewFile *.vue lua set_vue_template()
  augroup END
  
  augroup auto_sh_template
    au!
    autocmd BufNewFile *.sh lua set_sh_template()
  augroup END
  
  augroup auto_js_template
    au!
    autocmd BufNewFile *.js,*.ts lua set_js_template()
  augroup END
]])

function set_vue_template()
  -- 获取文件名
  local filename = vim.fn.expand('%:t:r')

  -- 输入模板代码
  local template = {
    "<template>",
    string.format("  <div :class=\"classes\">%s</div>", filename),
    "</template>",
    "",
    "<script>",
    "",
    string.format("const prefixCls = 'vi-%s'", filename),
    "",
    "export default {",
    string.format("  name: 'vi-%s',", filename),
    "  data() {",
    "    return {}",
    "  },",
    "  props: {},",
    "  methods: {},",
    "  watch: {},",
    "  created() {},",
    "  mounted() {},",
    "  computed: {",
    "    classes() {",
    "      return [",
    string.format("        `${ prefixCls }`"),
    "      ]",
    "    }",
    "  },",
    "  components: {}",
    "}",
    "</script>",
    "",
    "<style lang=\"scss\" rel=\"stylesheet/scss\">",
    string.format("  $-prefix-cls: 'vi-%s';", filename),
    string.format("  .#{$-prefix-cls} {", filename),
    "  }",
    "</style>",
    "<!-- vim: set ft=vue ff=unix et sw=2 ts=2 sts=2 tw=180: -->",
  }

  -- 将模板代码插入到文件中
  vim.api.nvim_buf_set_lines(0, 0, 0, false, template)
end

function set_sh_template()
  -- 获取文件名
  local filename = vim.fn.expand('%:t:r')

  local current_time = os.date("%a, %b %d, %Y %R")
  
  local function getModifiedTimeStr()
    return string.format("# Last Modified    %s", current_time)
  end

  local template = {
    "#!/bin/bash",
    "# vim: set ft=sh fdm=manual ts=2 sw=2 sts=2 tw=85 et:",
    "",
    "# =======================================================",
    "# Description:     ",
    string.format("# Filename:        %s", filename),
    "# Author           QuanQuan <millionfor@apache.org>",
    getModifiedTimeStr(),
    "# GistID           %Gist_ID%",
    "# GistURL          https://gist.github.com/millionfor/%Gist_ID%",
    "# =======================================================",

  }

  -- 将模板代码插入到文件中
  vim.api.nvim_buf_set_lines(0, 0, 0, false, template)
end

function set_js_template()
  -- 获取文件名
  local filename = vim.fn.expand('%:t:r')

  local current_time = os.date("%a, %b %d, %Y %R")
  
  local function getCreatedTimeStr()
    return string.format(" * @Created Time    %s", current_time)
  end
  
  local function getModifiedTimeStr()
    return string.format(" * @Last Modified   %s", current_time)
  end

  local template = {
    "/**",
    string.format(" * Filename:        %s", filename),
    getCreatedTimeStr(),
    getModifiedTimeStr(),
    " * @Author          QuanQuan <millionfor@apache.org>",
    " * @Description     ts",
    " */",
    " ",
    "// vim: set ft=typescript fdm=marker et ff=unix tw=180 sw=2:",
  }

  -- 将模板代码插入到文件中
  vim.api.nvim_buf_set_lines(0, 0, 0, false, template)
end


