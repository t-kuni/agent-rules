#!/usr/bin/env bash
# リモート実行対応のセットアップスクリプト
# Usage: TOOL=claude curl -sSL https://raw.githubusercontent.com/t-kuni/agent-rules/refs/heads/main/setup.sh | bash

set -euo pipefail

# ---- config ----
REPO_OWNER="t-kuni"
REPO_NAME="agent-rules"
REF="main" # 再現性を上げるならコミットSHAに置き換え
ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${REF}.tar.gz"

# ---- input ----
tool_raw="${TOOL:-}"
if [[ -z "${tool_raw}" ]]; then
  echo "Error: TOOL is required (claude|codex|cursor|gemini)" >&2
  exit 1
fi
tool="$(echo "${tool_raw}" | tr '[:upper:]' '[:lower:]')"

case "${tool}" in
  claude|codex|cursor|gemini) ;;
  *)
    echo "Error: invalid TOOL='${tool_raw}' (claude|codex|cursor|gemini)" >&2
    exit 1
    ;;
esac

TARGET_DIR="${1:-.}"

# ---- deps ----
command -v curl >/dev/null 2>&1 || { echo "Error: curl not found" >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "Error: tar not found" >&2; exit 1; }

# ---- download & extract ----
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t agent-rules)"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

echo "Downloading ${REPO_NAME} from GitHub..."
curl -fsSL "${ARCHIVE_URL}" | tar -xz -C "${TMP_DIR}"

REPO_DIR="$(find "${TMP_DIR}" -maxdepth 1 -type d -name "${REPO_NAME}-*" | head -n 1 || true)"
if [[ -z "${REPO_DIR}" || ! -d "${REPO_DIR}" ]]; then
  echo "Error: extracted repo directory not found" >&2
  exit 1
fi

# ---- source libs (as real files) ----
# shellcheck disable=SC1090
source "${REPO_DIR}/scripts/lib/setup-common.sh"
# shellcheck disable=SC1090
source "${REPO_DIR}/scripts/mappings/${tool}.sh"

# ---- override get_original_dir for remote setup ----
# リモート実行時は展開したディレクトリの original を指す
get_original_dir() {
    echo "${REPO_DIR}/original"
}

# ---- run ----
execute_setup "${TOOL_NAME}" "${TARGET_DIR}" "${SKILLS_DIR}" "${GUIDANCE_FILE}"

# ---- verify ----
if [[ ! -d "${TARGET_DIR}/${SKILLS_DIR}" ]]; then
  echo "Error: skills dir not found: ${TARGET_DIR}/${SKILLS_DIR}" >&2
  exit 1
fi
if [[ ! -f "${TARGET_DIR}/${GUIDANCE_FILE}" ]]; then
  echo "Error: guidance file not found: ${TARGET_DIR}/${GUIDANCE_FILE}" >&2
  exit 1
fi
