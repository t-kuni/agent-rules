#!/bin/bash
# 共通セットアップライブラリ

# 色付き出力
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ログ出力
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# original ディレクトリのパスを取得
get_original_dir() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    echo "${script_dir}/original"
}

# Skills をコピー
copy_skills() {
    local original_dir="$1"
    local target_skills_dir="$2"

    log_info "Copying skills to ${target_skills_dir}..."

    # target_skills_dir が存在しない場合は作成
    mkdir -p "${target_skills_dir}"

    # original 配下の全スキルディレクトリをコピー
    for skill_dir in "${original_dir}"/*/; do
        if [ -d "${skill_dir}" ]; then
            skill_name=$(basename "${skill_dir}")
            log_info "  - Copying ${skill_name}..."
            cp -r "${skill_dir}" "${target_skills_dir}/${skill_name}"
        fi
    done

    log_success "Skills copied successfully"
}

# 基本ガイダンスファイルをコピー（リネーム対応）
copy_guidance() {
    local original_file="$1"
    local target_file="$2"

    log_info "Copying guidance file to ${target_file}..."

    # target ファイルのディレクトリが存在しない場合は作成
    local target_dir=$(dirname "${target_file}")
    mkdir -p "${target_dir}"

    cp "${original_file}" "${target_file}"
    log_success "Guidance file copied successfully"
}

# セットアップ実行
execute_setup() {
    local tool_name="$1"
    local target_dir="$2"
    local skills_dir="$3"
    local guidance_file="$4"

    log_info "Setting up ${tool_name} in ${target_dir}..."
    echo ""

    local original_dir=$(get_original_dir)

    # Skills をコピー
    copy_skills "${original_dir}" "${target_dir}/${skills_dir}"
    echo ""

    # 基本ガイダンスをコピー
    copy_guidance "${original_dir}/AGENTS.md" "${target_dir}/${guidance_file}"
    echo ""

    log_success "${tool_name} setup completed!"
    echo ""
    echo "Files created:"
    echo "  - ${target_dir}/${skills_dir}/ (13 skills)"
    echo "  - ${target_dir}/${guidance_file}"
}
