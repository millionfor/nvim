autocmd BufNewFile *.vue,*.js,*.ts,*.css call SetTitle()
autocmd BufWritePre *.vue,*.js,*.ts,*.css call SetLastModified()

let s:getCreatedTimeStr =  {->printf(' * @CreatedTime     %s', strftime("%a, %b %d, %Y %R"))}
let s:getModifiedTimeStr = {->printf(' * @LastModified    %s', strftime("%a, %b %d, %Y %R"))}

func s:getTemplete(type)
    let templates = {
        \'vue': [
        \    "<template>",
        \    "  <div :class=\"\classes\"\>",
        \    "    ",
        \    "  </div>",
        \    "</template>",
        \    "<script>",
        \    "const prefixCls = 'vi-".expand("%:t:r") . "'",
        \    "export default {",
        \    "  name: 'Vi".expand("%:t:r") . "'," ,
        \    "  data() {",
        \    "    return {}",
        \    "  },",
        \    "  props: {},",
        \    "  methods: {},",
        \    "  watch: {},",
        \    "  created() {},",
        \    "  mounted() {},",
        \    "  computed: {",
        \    "    classes() {",
        \    "      return [",
        \    "        `${ prefixCls }`",
        \    "       ]",
        \    "     }",
        \    "  },",
        \    "  components: {}",
        \    "}",
        \    "</script>",
        \    "<style lang=\"\scss\"\ rel=\"\stylesheet/scss\"\>",
        \    "$-prefix-cls: 'vi-".expand("%:t:r") . "';",
        \    ".#{$-prefix-cls} {",
        \    "}",
        \    "</style>",
        \    "<!-- vim: set ft=vue ff=unix et sw=2 ts=2 sts=2 tw=80: -->",
        \],
        \'javascript': [
        \    "/**",
        \    " * @FileName        ".expand("%:t:r"),
        \    s:getCreatedTimeStr(),
        \    s:getModifiedTimeStr(),
        \    " * @Author          QuanQuan <millionfor@apache.org>",
        \    " * @Description     js",
        \    " */",
        \    " ",
        \    " // vim: set ft=javascript fdm=marker et ff=unix tw=80 sw=2:",
        \],
        \'typescript': [
        \    "/**",
        \    " * @FileName        ".expand("%:t:r"),
        \    s:getCreatedTimeStr(),
        \    s:getModifiedTimeStr(),
        \    " * @Author          QuanQuan <millionfor@apache.org>",
        \    " * @Description     ts",
        \    " */",
        \    " ",
        \    " // vim: set ft=javascript fdm=marker et ff=unix tw=80 sw=2:",
        \],
        \'default': [
        \    "/**",
        \    " * @FileName        ".expand("%:t:r"),
        \    s:getCreatedTimeStr(),
        \    s:getModifiedTimeStr(),
        \    " * @Author          QuanQuan <millionfor@apache.org>",
        \    " * @Description     default",
        \    " */",
        \    " ",
        \    " // vim: set ft=javascript fdm=marker et ff=unix tw=80 sw=2:",
        \],
        \}
    return get(templates, a:type, templates['default'])
endf

func SetTitle()
    let template = s:getTemplete(&filetype)
    call append(0, template)
    exec 'normal G'
endf

func SetLastModified()
    for n in range(10)
        if getline(n) =~ '^\s*\*\s*@LastModified\s*\S*.*$'
            call setline(n, s:getModifiedTimeStr())
            return
        endif
    endfor
endf
