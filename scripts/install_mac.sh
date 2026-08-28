#!/usr/bin/env bash
# ==============================================================================
# macOS 专属 Neovim 一键环境配置与安装脚本
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/scripts/common.sh"

INSTALL_FONT=1
SYNC_PLUGINS=1

# 参数解析
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-font)
            INSTALL_FONT=0
            shift
            ;;
        --no-sync)
            SYNC_PLUGINS=0
            shift
            ;;
        *)
            shift
            ;;
    esac
done

log_banner "开始配置 macOS (Darwin) 环境与 Neovim 依赖"

# 1. 检查并安装 Homebrew
if ! has_cmd brew; then
    log_info "未检测到 Homebrew，准备自动安装..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Apple Silicon 与 Intel 路径注入
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    log_success "检测到 Homebrew 已安装"
fi

# 2. 安装核心 CLI 依赖与工具
log_info "通过 Homebrew 安装/更新必要组件..."
BREW_PACKAGES=(
    neovim
    ripgrep
    fd
    fzf
    node
    python3
    lazygit
    btop
    ranger
    macism
)

for pkg in "${BREW_PACKAGES[@]}"; do
    if brew list "$pkg" >/dev/null 2>&1; then
        log_info "组件已安装: $pkg"
    else
        log_info "正在安装: $pkg ..."
        brew install "$pkg" || log_warn "安装 $pkg 失败，请稍后手动排查。"
    fi
done

# 3. 安装 Nerd Font (JetBrains Mono Nerd Font)
if [ "$INSTALL_FONT" -eq 1 ]; then
    log_info "安装 JetBrains Mono Nerd Font 字体..."
    if brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1; then
        log_success "字体 font-jetbrains-mono-nerd-font 已安装"
    else
        brew install --cask font-jetbrains-mono-nerd-font || {
            log_warn "Homebrew cask 安装字体受阻，尝试下载解压至 ~/Library/Fonts ..."
            FONT_DIR="${HOME}/Library/Fonts"
            mkdir -p "$FONT_DIR"
            TMP_FONT_DIR="$(mktemp -d)"
            curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -o "${TMP_FONT_DIR}/JetBrainsMono.tar.xz"
            tar -xf "${TMP_FONT_DIR}/JetBrainsMono.tar.xz" -C "$FONT_DIR"
            rm -rf "$TMP_FONT_DIR"
            log_success "JetBrains Mono Nerd Font 下载并安装完成！"
        }
    fi
fi

# 4. 配置 Python 环境与 Pillow (图片预览支持)
log_info "配置 Python3 及 pynvim, pillow 扩展..."
if has_cmd pip3; then
    pip3 install --upgrade pip >/dev/null 2>&1 || true
    pip3 install --user pynvim pillow >/dev/null 2>&1 || pip3 install pynvim pillow >/dev/null 2>&1 || {
        log_warn "pip3 全局安装受限，尝试创建专用 virtualenv..."
        PYTHON_VENV="${HOME}/.local/share/nvim-venv"
        mkdir -p "${HOME}/.local/share"
        python3 -m venv "$PYTHON_VENV"
        "${PYTHON_VENV}/bin/pip" install --upgrade pip
        "${PYTHON_VENV}/bin/pip" install pynvim pillow
        log_success "已在专用虚拟环境中安装依赖: ${PYTHON_VENV}"
    }
    log_success "Python 依赖环境已就绪"
fi

# 5. 初始化本地账号密钥配置文件 (QuanQuan.rc)
setup_user_rc "$SCRIPT_DIR"

# 6. 配置 Neovim 软链接
setup_nvim_symlink "$SCRIPT_DIR"

# 7. 同步插件
if [ "$SYNC_PLUGINS" -eq 1 ]; then
    sync_lazy_plugins
fi

log_banner "macOS Neovim 环境一键配置完成！享受丝滑的编码体验 🚀"
