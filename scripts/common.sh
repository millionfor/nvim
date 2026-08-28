#!/usr/bin/env bash
# ==============================================================================
# 通用工具函数与环境检查模块
# ==============================================================================

set -euo pipefail

# 颜色定义
C_RESET="\033[0m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_PURPLE="\033[35m"
C_CYAN="\033[36m"
C_BOLD="\033[1m"

# 日志辅助
log_banner() {
    echo -e "\n${C_PURPLE}${C_BOLD}================================================================${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}  $1${C_RESET}"
    echo -e "${C_PURPLE}${C_BOLD}================================================================${C_RESET}\n"
}

log_info() {
    echo -e "${C_BLUE}${C_BOLD}[INFO]${C_RESET} $1"
}

log_success() {
    echo -e "${C_GREEN}${C_BOLD}[SUCCESS]${C_RESET} $1"
}

log_warn() {
    echo -e "${C_YELLOW}${C_BOLD}[WARN]${C_RESET} $1"
}

log_error() {
    echo -e "${C_RED}${C_BOLD}[ERROR]${C_RESET} $1"
}

# 检查命令是否存在
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# 架构检测 (x86_64, aarch64/arm64)
detect_arch() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo "$arch"
            ;;
    esac
}

# 操作系统检测 (macOS, debian, ubuntu, linux)
detect_os() {
    local os
    os="$(uname -s)"
    if [ "$os" = "Darwin" ]; then
        echo "macos"
    elif [ "$os" = "Linux" ]; then
        if [ -f /etc/os-release ]; then
            # shellcheck source=/dev/null
            . /etc/os-release
            case "${ID:-linux}" in
                debian)
                    echo "debian"
                    ;;
                ubuntu)
                    echo "ubuntu"
                    ;;
                *)
                    if [ "${ID_LIKE:-}" = "debian" ]; then
                        echo "debian"
                    else
                        echo "linux"
                    fi
                    ;;
            esac
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Sudo 辅助运行
run_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif has_cmd sudo; then
        sudo "$@"
    else
        log_error "需要 root 权限，但系统中未安装 sudo。请切换到 root 用户再执行。"
        return 1
    fi
}

# 软链接 Neovim 配置目录
setup_nvim_symlink() {
    local repo_dir="$1"
    local target_dir="${HOME}/.config/nvim"

    # 如果仓库目录本身已位于 ~/.config/nvim，无需重复软链接
    if [ "$repo_dir" = "$target_dir" ]; then
        log_success "配置目录已直接就绪于: ${target_dir}"
        return 0
    fi

    log_info "配置 Neovim 软链接: ${target_dir} -> ${repo_dir}"

    mkdir -p "${HOME}/.config"

    if [ -L "$target_dir" ]; then
        local current_link
        current_link="$(readlink "$target_dir")"
        if [ "$current_link" = "$repo_dir" ]; then
            log_success "配置软链接已正确指向: ${repo_dir}"
            return 0
        else
            log_warn "更新现有的软链接: ${current_link} -> ${repo_dir}"
            rm -f "$target_dir"
        fi
    elif [ -d "$target_dir" ]; then
        local backup_dir="${HOME}/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        log_warn "检测到现有配置目录，正在备份至: ${backup_dir}"
        mv "$target_dir" "$backup_dir"
    fi

    ln -s "$repo_dir" "$target_dir"
    log_success "Neovim 配置目录软链接成功创建！"
}

# 自动同步 Lazy.nvim 插件
sync_lazy_plugins() {
    log_info "正在预热并同步 Neovim 插件 (headless mode)..."
    if has_cmd nvim; then
        if nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1; then
            log_success "Lazy.nvim 插件同步完成！"
        else
            log_warn "Lazy.nvim 后台同步已触发（首次打开 Neovim 时会自动补齐剩余依赖）。"
        fi
    else
        log_warn "未找到 nvim 命令，跳过插件预热。"
    fi
}

# 初始化用户账号密码与密钥配置文件 (QuanQuan.rc)
setup_user_rc() {
    local repo_dir="$1"
    local rc_file="${repo_dir}/QuanQuan.rc"
    local example_file="${repo_dir}/QuanQuan.rc.example"

    if [ ! -f "$rc_file" ]; then
        if [ -f "$example_file" ]; then
            cp "$example_file" "$rc_file"
        else
            cat << 'EOF' > "$rc_file"
# ==============================================================================
# ⚡ QuanQuan.rc - Neovim 本地用户账号、密码与私密 Token 配置
# (注：此文件已被 .gitignore 忽略，不会提交到 Git 仓库，请放心填写)
# ==============================================================================
export GITHUB_TOKEN=""
export GITLAB_BASE_URL=""
export GITLAB_TOKEN=""
export NVIM_USER_NAME="QuanQuan"
export NVIM_USER_EMAIL="millionfor@apache.org"
EOF
        fi
        log_success "已自动在根目录创建账号密钥配置文件: ${rc_file}"
        log_info "💡 可在 ${rc_file} 中填写 GitHub/GitLab Token 等私密配置（已被 .gitignore 严格忽略）。"
    else
        log_info "检测到已有账号密钥配置文件: ${rc_file} (保留现有配置)"
    fi
}
