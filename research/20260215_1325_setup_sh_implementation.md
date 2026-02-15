## 1) setup.sh の設計方針（意思決定）

**選択肢A（単一スクリプト + `TOOL` で切替）**が要件に最も合います。理由は「`curl | bash` で実行されたスクリプトは自身の配置場所（ディレクトリ）を安定して特定できない」ため、既存の `setup-[tool].sh` のように `SCRIPT_DIR` 前提で `source` すると壊れやすいからです（後述）。([Stack Overflow][1])

設計としては **setup.sh を“ブートストラッパ”**にして、以下を行うのがシンプルです。

* `TOOL` を検証（`claude|codex|cursor|gemini` のようなキー）
* GitHub の **ソースコードアーカイブ（tar.gz）**を一時ディレクトリに展開
* 展開したローカルファイルとして `scripts/lib/setup-common.sh` と `scripts/mappings/<tool>.sh` を `source`
* 既存の `execute_setup` を呼び出してコピー実行

この形だと **ロジック重複なし**で、既存の共通ロジック／マッピングをそのまま使えます（`setup-common.sh` の `get_original_dir()` も「ファイルとして source される」前提なら正常に相対解決できます）。([GNU][2])

## 2) リモート実行（`curl | bash`）の技術的課題と解決

### 2-1. `SCRIPT_DIR`（`BASH_SOURCE`）取得はどう動くか

`curl ... | bash` は **bash が標準入力からコマンドを読む**実行形です。([Stack Overflow][1])
この場合、スクリプトが「ファイルとして存在していない」ため、`"${BASH_SOURCE[0]}"` や `$0` が **安定したパスになりません**（`bash -s` だと `$0` が `bash`、`bash /dev/stdin` だと `/dev/stdin`、`bash <(curl ...)` だと `/dev/fd/63` のように変わる）。([Stack Overflow][1])
`BASH_SOURCE` 自体は「コールスタック上の“呼び出し元ファイル”」用途の変数で、ファイル実体に依存します。([GNU][2])

→ したがって **`SCRIPT_DIR` 前提で `source "$SCRIPT_DIR/..."` は破綻しやすい**です。

### 2-2. `source` で共通ライブラリ等を“リモートから”読む方法

やり方は大きく2つあります。

* **推奨：一時ディレクトリにダウンロードして “ファイルとして” source**

  * tarball を展開して `source "$TMP/.../scripts/lib/setup-common.sh"` のように読む
  * これなら `get_original_dir()` の相対パス解決が成立しやすい

* 非推奨寄り：`source <(curl ...)` のようにプロセス置換で読む

  * `BASH_SOURCE` が `/dev/fd/...` になり、相対パス前提のロジックは崩れやすい（=結局どこかで実ファイル化が必要になりがち）

### 2-3. 一時ディレクトリを使う実装の要点

* `mktemp -d` で作成して `trap 'rm -rf "$TMP"' EXIT` で必ず掃除
* `curl -f`（HTTPエラーで失敗扱い）+ `-S`（エラー表示）+ `-L`（リダイレクト追従）を使うのが定番です。([Stack Overflow][1])

※補足：`curl | bash` では stdin がパイプで埋まるため、スクリプト内で `read` すると入力待ちにならない問題も起きます（必要なら `/dev/tty` を使う等の回避が要る）。([Unix & Linux Stack Exchange][3])

## 3) original 配下の取得方法（git clone なし）

### 推奨：GitHub の source code archive（tar.gz）

GitHub はブランチ／タグ／コミットを **tar.gz/zip のURLで直接取得**できます。公式ドキュメントに URL 形式の例があります。([GitHub Docs][4])

* ブランチ例（公式例）：`.../archive/refs/heads/main.tar.gz`([GitHub Docs][4])
* コミット例（公式例）：`.../archive/<commit>.zip`（tar.gz も可）([GitHub Docs][4])

ブランチは動くので再現性を上げたいなら commit SHA を使う、という整理もできます。([GitHub Docs][4])

### ディレクトリ構造を保持して取得

* tarball はそのまま保持されます（展開先に `agent-rules-<ref>/...` が作られる）。([GitHub Docs][4])

### “特定ディレクトリだけ”を取得したい場合

* tarball を落としてから、展開時に `tar` のパターン指定で必要部分だけ展開（環境依存・書き方がやや複雑）
* GitHub API（Contents / Tree）で列挙して個別 `download_url` を取得（レート制限や再帰処理が必要になり実装が重くなりがち）

要件的には「1回のダウンロードで確実に展開」が優先なので、まず tarball が最短です。([GitHub Docs][4])

## 4) エラーハンドリングと検証

### 4-1. `TOOL` 未指定／不正

* 未指定：`TOOL is required (claude|codex|cursor|gemini)` を stderr に出して終了
* 不正値：受け付ける値を明示して終了（大文字小文字は吸収してもよい）

### 4-2. ネットワークエラー

* `curl -fS` を使って失敗時に終了コードを返す（404/500 など）。([Stack Overflow][1])
* 展開に失敗したら `tar` の終了コードで検知し、`Download or extract failed` などを出して終了

### 4-3. セットアップ完了の検証

最低限、以下をチェックして失敗なら non-zero 終了：

* `"$TARGET_DIR/$SKILLS_DIR"` がディレクトリとして存在
* `"$TARGET_DIR/$GUIDANCE_FILE"` がファイルとして存在

## 5) 既存スクリプトとの互換性と README 更新方針

### 5-1. 互換性の取り方

* **既存 `setup-[tool].sh` はそのまま残す（ローカル clone 前提の入口）**
* **新規 `setup.sh` を追加（remote 実行の入口）**

既存スクリプトを remote 実行でも動かしたい場合は、`setup-[tool].sh` 側に「依存ファイルが見つからなければ tarball を落として再実行する」フォールバックを入れる手もありますが、目的が「単一コマンド」なら `setup.sh` に集約したほうが読みやすいです。

### 5-2. README 更新方針

* 推奨コマンドを `setup.sh` に寄せる（要件の形）

  * `TOOL=claude curl -sSL .../setup.sh | bash`
* 既存 `setup-[tool].sh` は「リポジトリを clone 済みの場合」向けとして併記（または残すが主導線から外す）

---

## setup.sh（案）

```bash
#!/usr/bin/env bash
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
```

[1]: https://stackoverflow.com/questions/4642915/passing-parameters-to-bash-when-executing-a-script-fetched-by-curl "Passing parameters to bash when executing a script fetched by curl - Stack Overflow"
[2]: https://www.gnu.org/s/bash/manual/html_node/Bash-Variables.html?utm_source=chatgpt.com "Bash Variables (Bash Reference Manual)"
[3]: https://unix.stackexchange.com/questions/510804/why-isnt-it-possible-to-read-from-stdin-with-read-when-piping-a-script-to-b?utm_source=chatgpt.com "scripting - Why isn't it possible to read from `stdin` with ` ..."
[4]: https://docs.github.com/zh/enterprise-server%403.19/repositories/working-with-files/using-files/downloading-source-code-archives "下载源代码存档 - GitHub Enterprise Server 3.19 Docs"
