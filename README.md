# Nvim Config

## 核心快捷键 (lua/keymap.lua)

| 模式 | 键 | 说明 |
| :--- | :--- | :--- |
| normal | `;` | 映射为 `:`，方便输入命令 |
| n,v | `S` | 保存文件 |
| n,v | `SS` | 保存并退出 |
| normal | `Q` | 强制退出 |
| normal | `R` | 重新加载当前文件 |
| normal | `+` | 数字自增 (ctrl-a) |
| normal | `_` | 数字自减 (ctrl-x) |
| normal | `,` | 执行宏 `@q` |
| normal | `\` | 取消高亮搜索 |
| command | `ctrl + a` | 跳转到行首 |
| command | `ctrl + e` | 跳转到行尾 |
| normal | `sv` | 左右分屏 |
| normal | `sp` | 上下分屏 |
| normal | `sc` | 关闭当前窗口 |
| normal | `so` | 关闭其他所有窗口 |
| normal | `ss` | 切换到下个 buffer |
| normal | `W`  | 关闭当前 buffer |
| all | `alt + left/right` | 左右跳转 buffer |
| all | `ctrl + shift + 方向` | 快速上下移动/句首句尾跳转 |
| normal | `space` | 行首行尾自动跳转 |

## 插件快捷键 (lua/plugins/)

### LSP & 代码查阅 (lspsaga / lsp_cmp)
| 模式 | 键 | 说明 |
| :--- | :--- | :--- |
| normal | `gd` | 跳转到定义 (goto_definition) |
| normal | `gD` | 跳转到声明 (declaration) |
| normal | `gy` | 跳转到类型定义 (goto_type_definition) |
| normal | `gi` | 跳转到实现 (implementation) |
| normal | `gr` | 查找引用 (finder) |
| normal | `K` | 查看悬浮文档 (hover_doc) |
| v,n | `ga` | 代码操作 (code_action) |
| normal | `F2` | 重命名 (rename) |
| normal | `ctrl+e` | 查看当前 buffer 诊断列表 |
| normal | `\e` | 查看 workspace 诊断列表 |

### 文本搜索 (fzf-lua)
| 模式 | 键 | 说明 |
| :--- | :--- | :--- |
| normal | `ctrl + a` | 全局文本搜索 (live_grep) |
| normal | `ctrl + f` | 全局文件搜索 (files) |
| normal | `ctrl + b` | buffer 列表搜索 (buffers) |
| normal | `ctrl + l` | 当前 buffer 文本搜索 (blines) |
| normal | `ctrl + g` | git 变更文件搜索 (git_status) |
| normal | `ctrl + h` | 历史文件搜索 (oldfiles) |

### Git 功能 (gitsigns)
| 模式 | 键 | 说明 |
| :--- | :--- | :--- |
| normal | `(` | 上一处修改 (prev_hunk) |
| normal | `)` | 下一处修改 (next_hunk) |
| normal | `B` | 预览当前 hunk (preview_hunk) |
| normal | `C` | 侧栏查询全行 Blame (blame_line) |
| normal | `\g` | Diff 对比当前文件 (diffthis) |

### 文件浏览 (nvim-tree)
| 模式 | 键 | 说明 |
| :--- | :--- | :--- |
| normal | `<leader>e` | 打开/关闭目录树 |
| normal | `<leader>op` | 在 Mac Finder 中打开当前节点 |
| 树面板内 | `P` | CD 到选中目录 |
| 树面板内 | `<BS>` | 回退到上级目录 |
| 树面板内 | `A/a / r`| 创建文件 / 重命名 |

### 快速注释 & Markdown (opts.lua)
| 模式 | 键 | 说明 |
| :--- | :--- | :--- |
| normal | `??` | 切换行注释 |
| visual | `/` | 切换行注释 (选中范围) |
| visual | `?` | 切换块注释 (选中范围) |
| normal | `F6` | 切换 Markdown 渲染预览 |

### 文本翻译 (vim-translate)
| 模式 | 键 | 说明 |
| :--- | :--- | :--- |
| normal | `M` | 翻译当前词 |
| visual | `MM` | 翻译并替换选中内容 |

### AI 辅助 (copilot)
| 模式 | 键 | 说明 |
| :--- | :--- | :--- |
| insert | `right` | 接受 AI 的生成建议 |
