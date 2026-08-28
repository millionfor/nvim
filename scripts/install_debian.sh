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
run_sudo apt-get update -y || log_warn "APT 索引更新存在部分源警告（可能是系统第三方 PPA 签名失效），继续执行后续安装..."

APT_PACKAGES=(
    git
    curl
    wget
    build-essential
    gcc
    g++
    make
    cmake
    ninja-build
    gettext
    software-properties-common
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

log_info "正在通过 apt 安装基础组件..."
if ! run_sudo apt-get install -y --no-install-recommends "${APT_PACKAGES[@]}"; then
    log_warn "批量 apt 安装存在部分包缺失，正在逐个安装关键组件..."
    for pkg in "${APT_PACKAGES[@]}"; do
        run_sudo apt-get install -y "$pkg" || log_warn "软件包 $pkg 安装失败，跳过..."
    done
fi

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

# 3. 安装/升级至 Neovim 官方最新 Release (0.10+)
log_info "检查 Neovim 官方最新版本状态..."
LATEST_NVIM_TAG="$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | grep -Po '"tag_name": "\K[^"]*' || echo "")"
NEEDS_NVIM_INSTALL=1

if has_cmd nvim; then
    NVIM_VER_STR="$(nvim --version | head -n 1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo 'v0.0.0')"
    log_info "当前已安装 Neovim 版本: ${NVIM_VER_STR}"
    
    # 检查是否可正常运行且已是最新版本
    if nvim --version >/dev/null 2>&1; then
        if [ -n "$LATEST_NVIM_TAG" ] && [ "$NVIM_VER_STR" = "$LATEST_NVIM_TAG" ]; then
            log_success "当前 Neovim 已是官方最新版本 (${NVIM_VER_STR})"
            NEEDS_NVIM_INSTALL=0
        else
            log_info "发现新版本或需要重新部署 (当前: ${NVIM_VER_STR}, 目标: ${LATEST_NVIM_TAG:-最新Release})..."
        fi
    else
        log_warn "当前 Neovim 无法正常执行，准备重新部署最新版本..."
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
        log_success "Neovim 0.10+ 二进制已部署至 /usr/local/bin/nvim"
    else
        mkdir -p "${HOME}/.local/opt" "${HOME}/.local/bin"
        rm -rf "${HOME}/.local/opt/nvim-linux-${NVIM_ARCH}"
        tar -C "${HOME}/.local/opt" -xzf "${TMP_NVIM_DIR}/${NVIM_TARBALL}"
        ln -sf "${HOME}/.local/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" "${HOME}/.local/bin/nvim"
        log_success "Neovim 0.10+ 二进制已部署至 ~/.local/bin/nvim"
    fi
    rm -rf "$TMP_NVIM_DIR"

    # 验证二进制是否能在当前系统的 glibc 下正常执行 (如 Ubuntu 20.04 的 glibc 2.31 无法执行新预编译包)
    if ! nvim --version >/dev/null 2>&1; then
        log_warn "检测到系统 glibc 与官方预编译二进制不匹配 (常见于 Ubuntu 20.04 等发行版)。"
        log_info "正在自动启动兼容性安装方案..."

        # 尝试方案 1: Ubuntu PPA (neovim-ppa/unstable)
        if [ "$(detect_os)" = "ubuntu" ] && has_cmd add-apt-repository; then
            log_info "尝试通过 PPA (ppa:neovim-ppa/unstable) 安装适配本系统 glibc 的 Neovim..."
            run_sudo add-apt-repository -y ppa:neovim-ppa/unstable || true
            run_sudo apt-get update -y || true
            run_sudo apt-get install -y neovim || true
            if [ -f "/usr/bin/nvim" ]; then
                run_sudo ln -sf /usr/bin/nvim /usr/local/bin/nvim || true
            fi
        fi

        # 尝试方案 2: 若依然无法运行，直接从源码极速编译 (100% 适配宿主机 glibc)
        if ! nvim --version >/dev/null 2>&1; then
            log_info "正在自动从源码编译安装 Neovim (100% 兼容当前系统)..."
            run_sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential || true
            TMP_BUILD_DIR="$(mktemp -d)"
            git clone --depth 1 --branch stable https://github.com/neovim/neovim.git "$TMP_BUILD_DIR"
            pushd "$TMP_BUILD_DIR" >/dev/null
            make CMAKE_BUILD_TYPE=RelWithDebInfo
            if [ "$(id -u)" -eq 0 ] || has_cmd sudo; then
                run_sudo make install
            else
                make CMAKE_INSTALL_PREFIX="${HOME}/.local" install
            fi
            popd >/dev/null
            rm -rf "$TMP_BUILD_DIR"
        fi

        if nvim --version >/dev/null 2>&1; then
            log_success "Neovim 兼容性安装成功！当前版本: $(nvim --version | head -n 1)"
        else
            log_error "Neovim 兼容性构建受阻，请检查系统依赖。"
        fi
    fi
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
    (curl -fsSL https://deb.nodesource.com/setup_20.x | run_sudo bash -) || log_warn "NodeSource 脚本执行有警告，尝试直接安装 nodejs..."
    run_sudo apt-get install -y nodejs || log_warn "Node.js 安装受阻，请稍后手动安装。"
    if has_cmd node; then
        log_success "Node.js 安装成功: $(node -v)"
    fi
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

    if curl -fsSL "$LAZYGIT_URL" -o "${TMP_LZ_DIR}/lazygit.tar.gz"; then
        tar -xf "${TMP_LZ_DIR}/lazygit.tar.gz" -C "$TMP_LZ_DIR"
        if [ "$(id -u)" -eq 0 ] || has_cmd sudo; then
            run_sudo install -m 755 "${TMP_LZ_DIR}/lazygit" /usr/local/bin/lazygit || true
            log_success "Lazygit 已安装至 /usr/local/bin/lazygit"
        else
            mkdir -p "${HOME}/.local/bin"
            install -m 755 "${TMP_LZ_DIR}/lazygit" "${HOME}/.local/bin/lazygit" || true
            log_success "Lazygit 已安装至 ~/.local/bin/lazygit"
        fi
    else
        log_warn "Lazygit 下载失败，跳过安装。"
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
    python3 -m venv "$PYTHON_VENV" >/dev/null 2>&1 || python3 -m virtualenv "$PYTHON_VENV" >/dev/null 2>&1 || true
fi

if [ -f "${PYTHON_VENV}/bin/pip" ]; then
    "${PYTHON_VENV}/bin/pip" install --upgrade pip >/dev/null 2>&1 || true
    "${PYTHON_VENV}/bin/pip" install pynvim pillow >/dev/null 2>&1 || true
    log_success "Python 专属虚拟环境已就绪: ${PYTHON_VENV}"
else
    pip3 install --user --break-system-packages pynvim pillow >/dev/null 2>&1 || pip3 install --user pynvim pillow >/dev/null 2>&1 || true
    log_info "已尝试通过用户目录安装 Python 扩展"
fi

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
