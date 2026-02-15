#!/bin/bash
# Gemini CLI セットアップスクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリと設定を読み込み
source "${SCRIPT_DIR}/scripts/lib/setup-common.sh"
source "${SCRIPT_DIR}/scripts/mappings/gemini.sh"

# ターゲットディレクトリ（デフォルトはカレントディレクトリ）
TARGET_DIR="${1:-.}"

# セットアップ実行
execute_setup "${TOOL_NAME}" "${TARGET_DIR}" "${SKILLS_DIR}" "${GUIDANCE_FILE}"
