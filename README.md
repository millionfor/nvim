# ⚡ Neovim 现代化 IDE 配置 (macOS & Debian 12 深度适配)

> 极致性能、开箱即用、全自动化依赖管理的现代 Neovim 配置。深度支持 **macOS (Apple Silicon & Intel)** 与 **Debian 12 (Bookworm) / Linux** 双平台，并实现系统专属特性的解耦隔离。

---

## 🚀 一键安装指南

本项目自带生产级一键安装脚本，自动检测系统与架构（x86_64 / arm64），智能补齐全部 CLI 依赖、LSP、Nerd 字体及运行时环境：

### 1. 快速安装

#### 方式 A：远程一行命令安装（推荐）

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/millionfor/nvim/main/install.sh)"
```

#### 方式 B：手动克隆并安装

```bash
git clone https://github.com/millionfor/nvim.git ~/.config/nvim
cd ~/.config/nvim && ./install.sh
```

### 2. 脚本特性与参数

- **智能多平台适配**：
  - **macOS**：自动配置 Homebrew、`macism` 英文输入法自动切换、Apple Silicon/Intel 路径注入、JetBrains Mono 字体。
  - **Debian 12**：Debian 12 默认 apt 的 Neovim (0.8.3) 无法满足现代 LSP 需求，脚本将**自动下载并部署官方最新的 Neovim 0.10+ 二进制**、自动处理 `fdfind -> fd` 软链接、NodeSource Node.js 20 LTS、独立的 Python 虚拟环境（优雅突破 PEP 668 限制）、Lazygit 与剪贴板工具 (`xclip`/`wl-clipboard`)。
- **自定义安装选项**：
  ```bash
  ./install.sh --help       # 查看帮助信息
  ./install.sh --no-font    # 跳过 Nerd Font 下载
  ./install.sh --no-sync    # 跳过 Lazy 插件预热
  ./install.sh --mac        # 强制执行 macOS 安装流程
  ./install.sh --debian     # 强制执行 Debian 12 安装流程
  ```

---

## 📁 平台隔离与架构设计

为了保持配置的纯粹与可移植性，本项目将操作系统相关特性收敛于 `lua/platform/` 模块：

```text
~/.config/nvim
├── init.lua                  # 入口文件 (先初始化 platform 平台层)
├── install.sh                # 统一安装入口脚本
├── scripts/                  # 平台安装子脚本
│   ├── common.sh             # 公共工具函数库 (架构/日志/备份/软链)
│   ├── install_mac.sh        # macOS 专属安装器 (Homebrew/macism/字体)
│   └── install_debian.sh     # Debian 12 专属安装器 (Nvim 0.10+/Node 20/venv)
├── lua/
│   ├── platform/             # 跨平台解耦层
│   │   ├── init.lua          # 平台抽象入口 (统一 open_file / 系统判断)
│   │   ├── mac.lua           # macOS 专属: macism 输入法、Homebrew PATH
│   │   └── linux.lua         # Linux 专属: 剪贴板校验、fdfind/fcitx 适配
│   ├── options.lua           # 基础 Vim 选项与全局高亮
│   ├── keymap.lua            # 全局按键映射与智能编辑增强
│   ├── lazyinit.lua          # Lazy.nvim 插件管理器引导
│   ├── lspinit.lua           # 现代化 LSP / Mason 自动注册
│   ├── lsp/                  # 各语言 LSP 定制选项 (vtsls, vue, gopls...)
│   ├── plugins/              # 各功能插件配置 (fzf, tree, cmp, git...)
│   └── utils/                # 辅助脚本 (image_render.py 终端图片真彩预览)
├── ftplugin/                 # 语言特定快捷键与功能 (Java, Markdown, Vue...)
├── snippets/                 # VSCode 格式代码片段
└── templates/                # 新建文件智能模板
```

---

## 目录
- [修饰键对照表](#修饰键对照表)
- [1. 基础操作与窗口管理 (lua/keymap.lua)](#1-基础操作与窗口管理-luakeymaplua)
- [2. LSP 与代码导航 (lspsaga / blink.cmp)](#2-lsp-与代码导航-lspsagablinkcmp)
- [3. 模糊搜索 (fzf-lua)](#3-模糊搜索-fzf-lua)
- [4. Git 版本控制 (gitsigns / lazygit)](#4-git-版本控制-gitsignslazygit)
- [5. 目录树管理 (nvim-tree)](#5-目录树管理-nvim-tree)
- [6. 多光标编辑 (visual-multi.nvim)](#6-多光标编辑-visual-multinvim)
- [7. 浮动终端与一键运行 (vim-floaterm)](#7-浮动终端与一键运行-vim-floaterm)
- [8. 文本处理、注释与翻译](#8-文本处理注释与翻译)
- [9. 特定语言专属快捷键 (ftplugin)](#9-特定语言专属快捷键-ftplugin)

---

## 修饰键对照表

| 符号 / 记号 | Mac 键盘 | Windows / Linux 键盘 | 常用说明 |
| :--- | :--- | :--- | :--- |
| `<leader>` | `<Space>` (空格) | `<Space>` (空格) | Leader 前缀键 |
| `<c-...>` | `Ctrl` / `⌃` | `Ctrl` | Control 键 |
| `<m-...>` | `Option` / `⌥` | `Alt` | Meta / Option / Alt 键 |
| `<s-...>` | `Shift` / `⇧` | `Shift` | Shift 键 |
| `<cmd>` / `<super>` | `Command` / `⌘` | `Win` / `Super` | 操作系统 Command / Win 键 |

---

## 1. 基础操作与窗口管理 (`lua/keymap.lua`)

### 文件保存与退出
| 模式 | Mac 快捷键 | Windows / Linux 快捷键 | 功能说明 |
| :--- | :--- | :--- | :--- |
| Normal / Visual | `S` | `S` | 智能保存当前文件（必要时自动创建目录/sudo保存） |
| Normal / Visual | `S` `S` | `S` `S` | 保存并退出当前 Buffer |
| Normal | `Q` | `Q` | 强制退出 (`:q!`) |
| Normal | `R` | `R` | 重新加载当前文件 (`:e %`) |
| Normal | `W` 或 `sd` 或 `Esc Esc` | `W` 或 `sd` 或 `Esc Esc` | 智能关闭当前 Buffer |

### 编辑与快速跳转
| 模式 | Mac 快捷键 | Windows / Linux 快捷键 | 功能说明 |
| :--- | :--- | :--- | :--- |
| Normal / Visual | `;` | `;` | 快速映射为 `:`（无需按 Shift） |
| Normal | `\` 或 `Esc` | `\` 或 `Esc` | 取消搜索高亮（同时清除词高亮 `ff` / `FF`） |
| Normal | `+` / `_` | `+` / `_` | 数字自增 (`Ctrl-a`) / 数字自减 (`Ctrl-x`) |
| Normal | `<BS>` (退格键) | `<BS>` (退格键) | 快速删除光标所在单词（不污染剪切板） |
| Insert | `Ctrl + h` | `Ctrl + h` | 插入模式按单词快速向左删除 |
| Normal / Insert | `Ctrl + j` | `Ctrl + j` | 从逗号 `,` 处打断并自动换行 |
| Normal / Visual | `Ctrl + s` | `Ctrl + s` | 快速唤起全局/选中区域正则替换 (`:%s/\v//gc`) |
| Visual | `Alt + Up / Down` | `Alt + Up / Down` | 向上 / 向下移动当前选中行 |
| Normal / Insert | `Alt + Up / Down` | `Alt + Up / Down` | 向上 / 向下移动当前行 |
| Command | `Ctrl + a` / `Ctrl + e` | `Ctrl + a` / `Ctrl + e` | 命令行模式跳转到行首 / 行尾 |
| Command | `Up` / `Down` | `Up` / `Down` | 命令行历史命令搜索 |
| Normal | `<Space>` | `<Space>` | 智能在行首(`^`)、行尾(`$`)与首字符(`0`)间循环跳转 |
| Normal / Visual | `0` | `0` | 括号/引号配对跳转 (`%`) |
| Visual | `T` / `t` | `T` / `t` | 驼峰转换（首字母大写 / 首字母小写） |
| Visual | `<` / `>` 或 `Shift+Tab` / `Tab` | `<` / `>` 或 `Shift+Tab` / `Tab` | 缩进文本并保持选中状态 |
| Normal | `\w` | `\w` | 切换当前文件是否自动换行 (`wrap`) |
| Normal / Visual | `-` | `-` | 智能代码折叠与展开 |

### 快速文本选择 (Leader 选区扩展)
| 模式 | 快捷键 (Mac / Win) | 功能说明 |
| :--- | :--- | :--- |
| Normal | `<Space> + '` | 选中单引号 `'...'` 内文本 |
| Normal | `<Space> + ''` | 选中双引号 `"..."` 内文本 |
| Normal | `<Space> + (` 或 `)` | 选中圆括号 `(...)` 内文本 |
| Normal | `<Space> + [` | 选中方括号 `[...]` 内文本 |
| Normal | `<Space> + [[` | 选中花括号 `{...}` 内文本 |
| Normal | `<Space> + `` ` `` | 选中反引号 `` `...` `` 内文本 |
| Normal | `<Space> + <Space>` | 选中当前 HTML/XML 标签内容 |
| Visual | `<Space>` | 扩大当前选区，包含边界括号/引号 |

### 分屏与窗口导航
| 模式 | Mac 快捷键 | Windows / Linux 快捷键 | 功能说明 |
| :--- | :--- | :--- | :--- |
| Normal | `sv` | `sv` | 左右垂直分屏 |
| Normal | `sp` | `sp` | 上下水平分屏 |
| Normal | `sc` | `sc` | 关闭当前窗口 |
| Normal | `so` | `so` | 关闭除当前窗口外的其他所有窗口 |
| Normal | `s + 方向键` | `s + 方向键` | 向左/右/上/下切换窗口 |
| Normal | `Ctrl + Space` 或 `<Space> f` | `Ctrl + Space` 或 `<Space> f` | 轮流切换焦点窗口 |
| Normal | `s=` | `s=` | 平均分配所有窗口大小 |
| Normal | `Alt + .` / `Alt + ,` | `Alt + .` / `Alt + ,` | 增大 / 缩小当前窗口宽度 |
| Normal | `ss` | `ss` | 切换到下一个 Buffer |
| Normal/Insert/Visual | `Alt + Left / Right` | `Alt + Left / Right` | 左右快速切换 Buffer |

---

## 2. LSP 与代码导航 (`lspsaga` / `blink.cmp`)

| 模式 | Mac / Win 快捷键 | 说明 |
| :--- | :--- | :--- |
| Normal | `gd` | 跳转到定义 (Definition，支持多框架/跨端跳转) |
| Normal | `gD` | 跳转到声明 (Declaration) |
| Normal | `gy` | 跳转到类型定义 (Type Definition) |
| Normal | `gi` | 跳转到接口实现 (Implementation) |
| Normal | `gr` | 查看引用列表 (Lspsaga Finder) |
| Normal | `K` | 查看悬浮文档 (Hover Doc) |
| Normal / Visual | `ga` | 触发代码修复操作 (Code Action) |
| Normal | `F2` | 重命名当前变量/函数 (Rename) |
| Normal | `Ctrl + e` | 查看当前文件 Diagnostics 诊断错误 |
| Normal | `\e` | 查看整个工作区 Diagnostics 诊断列表 |
| Visual | `=` | LSP 格式化选中代码 |
| Normal | `<Space> m` | 打开 Mason 语言服务器管理面板 |

---

## 3. 模糊搜索 (`fzf-lua`)

| 模式 | Mac 快捷键 | Windows / Linux 快捷键 | 说明 |
| :--- | :--- | :--- | :--- |
| Normal | `Ctrl + f` | `Ctrl + f` | 全局文件名搜索 (Files) |
| Normal | `Ctrl + a` | `Ctrl + a` | 全局文本搜索 (Live Grep) |
| Normal | `Ctrl + b` | `Ctrl + b` | 已打开 Buffer 列表搜索 |
| Normal | `Ctrl + l` | `Ctrl + l` | 当前文件内部文本搜索 (Buffer Lines) |
| Normal | `Ctrl + g` | `Ctrl + g` | Git 更改状态文件搜索 |
| Normal | `Ctrl + h` | `Ctrl + h` | 最近打开过的历史文件搜索 (Oldfiles) |

---

## 4. Git 版本控制 (`gitsigns`)

| 模式 | Mac / Win 快捷键 | 说明 |
| :--- | :--- | :--- |
| Normal | `(` / `)` | 跳转到上一处 / 下一处 Git 修改块 (Hunk) |
| Normal | `B` | 浮动预览当前 Git 修改块 (Preview Hunk) |
| Normal | `C` | 侧边栏及弹窗查询当前行 Git Blame 提交历史 |
| Normal | `\g` | Diff 模式对比当前文件历史修改 |
| 终端模式 | `L` | 在浮动终端内打开图形化 `lazygit` |

---

## 5. 目录树管理 (`nvim-tree`)

| 模式 | Mac 快捷键 | Windows / Linux 快捷键 | 说明 |
| :--- | :--- | :--- | :--- |
| Normal | `<Space> e` | `<Space> e` | 打开 / 关闭文件树面板 |
| 文件树内 | `op` | `op` | 在系统文件管理器 (Finder / 资源管理器) 中打开选中目录 |
| 文件树内 | `P` | `P` | 将选中的文件夹切换为项目根目录 (Root) |
| 文件树内 | `<BS>` (退格键) | `<BS>` (退格键) | 返回上一级父目录 |
| 文件树内 | `A` 或 `a` | `A` 或 `a` | 创建新文件 / 目录（自动应用模板） |
| 文件树内 | `r` | `r` | 重命名文件 |
| 文件树内 | `C` | `C` | 智能切换根目录 (Magic CD) |
| 文件树内 | `<CR>` / `<Right>` | `<CR>` / `<Right>` | 打开文件 / 展开目录 |
| 文件树内 | `<Left>` / `<Esc>` | `<Left>` / `<Esc>` | 折叠目录 / 关闭目录树 |

---

## 6. 多光标编辑 (`visual-multi.nvim`)

| 模式 | Mac 快捷键 | Windows / Linux 快捷键 | 说明 |
| :--- | :--- | :--- | :--- |
| Normal | `Ctrl + n` | `Ctrl + n` | 选中当前词并在下一个匹配项添加光标 |
| Normal | `Ctrl + d` | `Ctrl + d` | 一键全选当前文件中的所有匹配项 |
| Multi Mode | `Ctrl + Up / Down` | `Ctrl + Up / Down` | 向上 / 向下直接添加多行光标 |
| Multi Mode | `Ctrl + Left / Right` | `Ctrl + Left / Right` | 左右移动多光标选区 |
| Multi Mode | `Ctrl + x` | `Ctrl + x` | 在当前光标绝对位置添加光标 |
| Multi Mode | `Ctrl + w` | `Ctrl + w` | 在单词位置添加光标 |
| Multi Mode | `q` | `q` | 移除当前光标位置的选区 |
| Multi Mode | `+` / `_` | `+` / `_` | 所有光标位置数字批量递增 / 递减 |
| Multi Mode | `u` / `Ctrl + r` | `u` / `Ctrl + r` | 多光标下的撤销 (Undo) / 重做 (Redo) |

---

## 7. 浮动终端与一键运行 (`vim-floaterm`)

| 模式 | Mac / Win 快捷键 | 说明 |
| :--- | :--- | :--- |
| Normal / Insert | `F5` | **一键编译并运行当前文件** (支持 JS, TS, Python, Go, Java, C, Shell, Lua) |
| Normal | `Ctrl + t` | 切换标准浮动终端 (`TERM`) |
| Normal | `L` | 打开/切换 `lazygit` 终端 |
| Normal | `R` | 打开/切换 `ranger` 文件管理器 |
| Normal | `B` | 打开/切换 `btop` 系统监控 |
| Normal | `T` | 打开/切换第二个独立浮动终端 (`TERM2`) |

---

## 8. 文本处理、注释与翻译

| 模式 | Mac / Win 快捷键 | 说明 |
| :--- | :--- | :--- |
| Normal | `<Space> t` | 唤起命名风格转换器 (camelCase, PascalCase, kebab-case, snake_case 等) |
| Normal | `??` | 切换当前行注释 |
| Visual | `/` | 切换选中区域多行注释 |
| Normal | `F6` | 开启 / 关闭 Markdown 渲染预览 (`render-markdown`) |
| Visual | `C` | 生成 console.log / logger 打印代码 (`vim-echo`) |
| Visual / Normal | `mm` | 划词翻译并弹窗显示/替换 (`babel.nvim`) |

---

## 9. 特定语言专属快捷键 (`ftplugin`)

### Java (`ftplugin/java.lua`)
- `<Space> jo`: 自动整理并优化导入包 (`organize_imports`)
- `<Space> jv`: 提取变量 (`extract_variable`)
- `<Space> jc`: 提取常量 (`extract_constant`)
- `<Space> jm`: 提取方法 (`extract_method`)

### Markdown (`ftplugin/markdown.lua`)
- `<CR>`: 智能勾选 / 取消勾选 Task 复选框 `[ ]`
- Visual `B`: 快速加粗选中文字 `**bold**`
- Visual `I`: 快速倾斜选中文字 `*italic*`
- Visual `T`: 转换为待办事项 `- [ ] text`
- Visual `` ` ``: 转换为行内代码 `` `code` ``
- Visual `C`: 转换为代码块 ` ```plaintext ... ``` `
