#!/usr/bin/env bash
# ==============================================================================
# Debian 12 (Bookworm) & Debian-based Linux 专属 Neovim 一键环境配置与安装脚本
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

log_banner "开始配置 Debian 12 (Bookworm) / Linux 环境与 Neovim 依赖"

ARCH="$(detect_arch)"
log_info "检测到系统 CPU 架构: ${ARCH}"

# 1. 更新 apt 并安装基础构建工具及核心 CLI
log_info "更新 APT 软件包索引并安装基础开发工具..."
run_sudo apt-get update -y

APT_PACKAGES=(
    git
    curl
    wget
    build-essential
    gcc
    g++
    make
    unzip
    tar
    gzip
    ripgrep
    fd-find
    fzf
    xclip
    wl-clipboard
    ranger
    btop
    fontconfig
    python3
    python3-pip
    python3-venv
)

log_info "正在通过 apt 安装基础组件: ${APT_PACKAGES[*]}"
run_sudo apt-get install -y "${APT_PACKAGES[@]}" || {
    log_warn "部分软件包安装失败，尝试继续后续步骤..."
}

# 2. Debian 12 fd 命令别名兼容 (fdfind -> fd)
log_info "配置 Debian 12 fd 命令适配..."
if has_cmd fdfind && ! has_cmd fd; then
    FDFIND_PATH="$(command -v fdfind)"
    if [ "$(id -u)" -eq 0 ] || has_cmd sudo; then
        run_sudo ln -sf "$FDFIND_PATH" /usr/local/bin/fd
        log_success "已创建软链接: /usr/local/bin/fd -> ${FDFIND_PATH}"
    else
        mkdir -p "${HOME}/.local/bin"
        ln -sf "$FDFIND_PATH" "${HOME}/.local/bin/fd"
        log_success "已创建软链接: ~/.local/bin/fd -> ${FDFIND_PATH}"
    fi
fi

# 3. 安装/升级 Neovim 0.10+ (Debian 12 默认 apt 的 0.8.3 版本不兼容)
log_info "检查 Neovim 版本..."
NEEDS_NVIM_INSTALL=1
if has_cmd nvim; then
    NVIM_VER_STR="$(nvim --version | head -n 1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo 'v0.0.0')"
    log_info "当前 Neovim 版本: ${NVIM_VER_STR}"
    # 提取次版本号
    MINOR_VER="$(echo "$NVIM_VER_STR" | cut -d. -f2)"
    MAJOR_VER="$(echo "$NVIM_VER_STR" | cut -d. -f1 | tr -d 'v')"
    if [ "$MAJOR_VER" -gt 0 ] || [ "$MINOR_VER" -ge 10 ]; then
        log_success "Neovim 版本已满足要求 (>= 0.10.0)"
        NEEDS_NVIM_INSTALL=0
    else
        log_warn "Debian 自带的 Neovim (${NVIM_VER_STR}) 低于 0.10.0，本项目特性需要 0.10+，准备下载官方最新 Release..."
    fi
fi

if [ "$NEEDS_NVIM_INSTALL" -eq 1 ]; then
    NVIM_ARCH=""
    case "$ARCH" in
        x86_64)
            NVIM_ARCH="x86_64"
            ;;
        arm64)
            NVIM_ARCH="arm64"
            ;;
        *)
            NVIM_ARCH="x86_64"
            ;;
    esac

    NVIM_TARBALL="nvim-linux-${NVIM_ARCH}.tar.gz"
    NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/${NVIM_TARBALL}"
    TMP_NVIM_DIR="$(mktemp -d)"

    log_info "正在下载 Neovim 最新预编译二进制 (${NVIM_URL})..."
    curl -fsSL "$NVIM_URL" -o "${TMP_NVIM_DIR}/${NVIM_TARBALL}"

    if [ "$(id -u)" -eq 0 ] || has_cmd sudo; then
        run_sudo mkdir -p /opt
        run_sudo rm -rf "/opt/nvim-linux-${NVIM_ARCH}"
        run_sudo tar -C /opt -xzf "${TMP_NVIM_DIR}/${NVIM_TARBALL}"
        run_sudo ln -sf "/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim
        log_success "Neovim 0.10+ 成功安装至 /usr/local/bin/nvim"
    else
        mkdir -p "${HOME}/.local/opt" "${HOME}/.local/bin"
        rm -rf "${HOME}/.local/opt/nvim-linux-${NVIM_ARCH}"
        tar -C "${HOME}/.local/opt" -xzf "${TMP_NVIM_DIR}/${NVIM_TARBALL}"
        ln -sf "${HOME}/.local/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" "${HOME}/.local/bin/nvim"
        log_success "Neovim 0.10+ 成功安装至 ~/.local/bin/nvim"
    fi
    rm -rf "$TMP_NVIM_DIR"
fi

# 4. 安装 Node.js 20+ LTS (Mason LSP 所需)
log_info "检查 Node.js 运行环境..."
NEEDS_NODE=1
if has_cmd node; then
    NODE_MAJOR="$(node -v | cut -d. -f1 | tr -d 'v')"
    if [ "$NODE_MAJOR" -ge 18 ]; then
        log_success "Node.js 版本满足要求: $(node -v)"
        NEEDS_NODE=0
    fi
fi

if [ "$NEEDS_NODE" -eq 1 ]; then
    log_info "安装 Node.js 20 LTS (NodeSource)..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | run_sudo bash -
    run_sudo apt-get install -y nodejs
    log_success "Node.js 安装成功: $(node -v)"
fi

# 5. 安装 Lazygit 二进制
if ! has_cmd lazygit; then
    log_info "安装 Lazygit 最新二进制..."
    LAZYGIT_ARCH=""
    case "$ARCH" in
        x86_64)
            LAZYGIT_ARCH="x86_64"
            ;;
        arm64)
            LAZYGIT_ARCH="arm64"
            ;;
        *)
            LAZYGIT_ARCH="x86_64"
            ;;
    esac

    LAZYGIT_VER="$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*' || echo "0.44.1")"
    LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VER}_Linux_${LAZYGIT_ARCH}.tar.gz"
    TMP_LZ_DIR="$(mktemp -d)"

    curl -fsSL "$LAZYGIT_URL" -o "${TMP_LZ_DIR}/lazygit.tar.gz"
    tar -xf "${TMP_LZ_DIR}/lazygit.tar.gz" -C "$TMP_LZ_DIR"

    if [ "$(id -u)" -eq 0 ] || has_cmd sudo; then
        run_sudo install -m 755 "${TMP_LZ_DIR}/lazygit" /usr/local/bin/lazygit
        log_success "Lazygit 已安装至 /usr/local/bin/lazygit"
    else
        mkdir -p "${HOME}/.local/bin"
        install -m 755 "${TMP_LZ_DIR}/lazygit" "${HOME}/.local/bin/lazygit"
        log_success "Lazygit 已安装至 ~/.local/bin/lazygit"
    fi
    rm -rf "$TMP_LZ_DIR"
else
    log_success "Lazygit 已安装: $(command -v lazygit)"
fi

# 6. 配置 Python 专用虚拟环境 (优雅绕过 Debian 12 PEP 668 限制)
log_info "配置 Python 独立虚拟环境及 pynvim, pillow (图片预览支持)..."
PYTHON_VENV="${HOME}/.local/share/nvim-venv"
mkdir -p "${HOME}/.local/share"
if [ ! -d "$PYTHON_VENV" ]; then
    python3 -m venv "$PYTHON_VENV"
fi
"${PYTHON_VENV}/bin/pip" install --upgrade pip >/dev/null 2>&1 || true
"${PYTHON_VENV}/bin/pip" install pynvim pillow
log_success "Python 专属环境已就绪: ${PYTHON_VENV}"

# 7. 安装 JetBrains Mono Nerd Font 字体
if [ "$INSTALL_FONT" -eq 1 ]; then
    log_info "配置 JetBrains Mono Nerd Font 字体..."
    FONT_DIR="${HOME}/.local/share/fonts/JetBrainsMono"
    mkdir -p "$FONT_DIR"
    TMP_FONT_DIR="$(mktemp -d)"
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -o "${TMP_FONT_DIR}/JetBrainsMono.tar.xz"
    tar -xf "${TMP_FONT_DIR}/JetBrainsMono.tar.xz" -C "$FONT_DIR"
    rm -rf "$TMP_FONT_DIR"
    if has_cmd fc-cache; then
        fc-cache -fv "$FONT_DIR" >/dev/null 2>&1 || true
    fi
    log_success "JetBrains Mono Nerd Font 安装并刷新缓存完成！"
fi

# 8. 初始化本地账号密钥配置文件 (QuanQuan.rc)
setup_user_rc "$SCRIPT_DIR"

# 9. 配置 Neovim 软链接
setup_nvim_symlink "$SCRIPT_DIR"

# 10. 同步插件
if [ "$SYNC_PLUGINS" -eq 1 ]; then
    sync_lazy_plugins
fi

log_banner "Debian 12 / Linux Neovim 环境一键配置完成！享受高效的编码体验 🚀"
