#!/usr/bin/env bash
# ==============================================================================
# ⚡ Neovim 跨平台一键安装引导脚本
# 支持本地执行与远程一键命令:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/millionfor/nvim/main/install.sh)"
# ==============================================================================

set -euo pipefail

# 默认仓库地址与安装目标路径
REPO_URL="${NVIM_REPO_URL:-https://github.com/millionfor/nvim.git}"
TARGET_DIR="${HOME}/.config/nvim"

# 判断当前是否在本地包含 scripts/common.sh 的仓库中运行
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    CANDIDATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "${CANDIDATE_DIR}/scripts/common.sh" ]; then
        SCRIPT_DIR="$CANDIDATE_DIR"
    fi
fi

# ==============================================================================
# 远程一键引导模式 (curl / wget / sh 管道运行)
# ==============================================================================
if [ -z "$SCRIPT_DIR" ]; then
    echo -e "\033[35m\033[1m================================================================\033[0m"
    echo -e "\033[36m\033[1m  ⚡ 启动 Neovim 远程一键安装引导程序\033[0m"
    echo -e "\033[35m\033[1m================================================================\033[0m\n"

    # 1. 检查并安装 git
    if ! command -v git >/dev/null 2>&1; then
        echo -e "\033[33m[WARN] 未检测到 git 工具，尝试自动安装...\033[0m"
        OS_TYPE="$(uname -s)"
        if [ "$OS_TYPE" = "Darwin" ]; then
            if command -v brew >/dev/null 2>&1; then
                brew install git
            else
                xcode-select --install || true
            fi
        elif [ "$OS_TYPE" = "Linux" ]; then
            if command -v apt-get >/dev/null 2>&1; then
                if [ "$(id -u)" -eq 0 ]; then
                    apt-get update -y && apt-get install -y git curl
                elif command -v sudo >/dev/null 2>&1; then
                    sudo apt-get update -y && sudo apt-get install -y git curl
                fi
            fi
        fi
    fi

    if ! command -v git >/dev/null 2>&1; then
        echo -e "\033[31m[ERROR] 缺少 git 工具，请先手动安装 git 后重试。\033[0m"
        exit 1
    fi

    # 2. 克隆或更新仓库至 ~/.config/nvim
    mkdir -p "${HOME}/.config"
    if [ -d "$TARGET_DIR" ]; then
        if [ -d "${TARGET_DIR}/.git" ]; then
            echo -e "\033[34m[INFO] 检测到已有配置仓库，正在拉取最新代码: ${TARGET_DIR} ...\033[0m"
            git -C "$TARGET_DIR" pull --rebase || true
        else
            BACKUP_DIR="${HOME}/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
            echo -e "\033[33m[WARN] 检测到现有非 Git 配置目录，正在备份至: ${BACKUP_DIR} ...\033[0m"
            mv "$TARGET_DIR" "$BACKUP_DIR"
            echo -e "\033[34m[INFO] 正在克隆配置仓库至: ${TARGET_DIR} ...\033[0m"
            git clone "$REPO_URL" "$TARGET_DIR"
        fi
    else
        echo -e "\033[34m[INFO] 正在克隆配置仓库至: ${TARGET_DIR} ...\033[0m"
        git clone "$REPO_URL" "$TARGET_DIR"
    fi

    # 3. 交由本地克隆后的脚本继续执行完整配置流程
    chmod +x "${TARGET_DIR}/install.sh" "${TARGET_DIR}/scripts/"*.sh 2>/dev/null || true
    exec bash "${TARGET_DIR}/install.sh" "$@"
fi

# ==============================================================================
# 本地执行模式 (已位于包含 scripts/ 的完整目录中)
# ==============================================================================
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/scripts/common.sh"

show_help() {
    cat << 'EOF'
⚡ Neovim 跨平台一键安装脚本

用法:
  ./install.sh [选项]

远程一键安装:
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/millionfor/nvim/main/install.sh)"

选项:
  -h, --help        显示帮助信息
  --no-font         跳过 Nerd Font 字体下载与安装
  --no-sync         跳过 Lazy.nvim 插件预热与同步
  --mac             强制执行 macOS 平台安装流程
  --debian          强制执行 Debian 12 / Linux 平台安装流程

支持平台:
  • macOS (Apple Silicon M1/M2/M3/M4 & Intel x86_64)
  • Debian 12 (Bookworm) 及兼容发行版 (Ubuntu, Deepin, 等)

EOF
}

TARGET_PLATFORM=""
PASSTHROUGH_ARGS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        --mac)
            TARGET_PLATFORM="macos"
            shift
            ;;
        --debian)
            TARGET_PLATFORM="debian"
            shift
            ;;
        --no-font)
            PASSTHROUGH_ARGS+=("--no-font")
            shift
            ;;
        --no-sync)
            PASSTHROUGH_ARGS+=("--no-sync")
            shift
            ;;
        *)
            PASSTHROUGH_ARGS+=("$1")
            shift
            ;;
    esac
done

# 确保所有脚本具备执行权限
chmod +x "${SCRIPT_DIR}/scripts/"*.sh 2>/dev/null || true

# 自动检测平台
if [ -z "$TARGET_PLATFORM" ]; then
    TARGET_PLATFORM="$(detect_os)"
fi

log_banner "⚡ 正在启动 Neovim 跨平台一键安装配置体系"
log_info "识别目标操作系统类型: ${TARGET_PLATFORM}"

case "$TARGET_PLATFORM" in
    macos)
        bash "${SCRIPT_DIR}/scripts/install_mac.sh" "${PASSTHROUGH_ARGS[@]}"
        ;;
    debian|ubuntu|linux)
        bash "${SCRIPT_DIR}/scripts/install_debian.sh" "${PASSTHROUGH_ARGS[@]}"
        ;;
    *)
        log_error "暂不支持当前操作系统: ${TARGET_PLATFORM}"
        log_info "支持的系统为: macOS (Darwin) 及 Debian 12 / Debian-based Linux。"
        exit 1
        ;;
esac
