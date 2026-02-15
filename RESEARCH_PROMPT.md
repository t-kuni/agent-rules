# リサーチプロンプト

## 何をリサーチするか？

別のリポジトリのこのリポジトリのファイルを展開したい時、ローカルにこのリポジトリがない状態から `TOOL=[ツール名] curl -sSL https://raw.githubusercontent.com/t-kuni/agent-rules/refs/heads/main/setup.sh | bash` でこのリポジトリのファイルの展開が完了するようにしたい。実現方法を検討して。

## プロジェクト概要

本プロジェクト（agent-rules）は、SDD（仕様駆動開発）のための各種AIツール用のルール・スキルのテンプレートです。

### サポートツール

- Cursor IDE
- Claude Code
- Codex CLI
- Gemini CLI

### ディレクトリ構造

```
agent-rules/
├── original/              # 原本ファイル（13個のスキル + AGENTS.md）
│   ├── AGENTS.md
│   ├── guideline-alert/
│   ├── guideline-code/
│   ├── guideline-research/
│   ├── guideline-specs/
│   ├── guideline-tasks/
│   ├── guideline-test/
│   ├── tasks-bug-fix/
│   ├── tasks-exec-research/
│   ├── tasks-exec-tasks/
│   ├── tasks-make-research-prompt/
│   ├── tasks-make-spec/
│   ├── tasks-make-task-list/
│   └── tasks-test-error/
├── scripts/
│   ├── lib/
│   │   └── setup-common.sh    # 共通セットアップロジック
│   └── mappings/              # ツール別のマッピング定義
│       ├── claude.sh
│       ├── codex.sh
│       ├── cursor.sh
│       └── gemini.sh
├── setup-claude.sh
├── setup-codex.sh
├── setup-cursor.sh
└── setup-gemini.sh
```

## 既存の実装情報

### 現在のセットアップスクリプトの仕組み

各ツール用のセットアップスクリプト（例: setup-claude.sh）は以下の構造で動作しています：

```bash
#!/bin/bash
set -e

# スクリプトのディレクトリを取得（ローカルパスを想定）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリと設定を読み込み
source "${SCRIPT_DIR}/scripts/lib/setup-common.sh"
source "${SCRIPT_DIR}/scripts/mappings/claude.sh"

# ターゲットディレクトリ（デフォルトはカレントディレクトリ）
TARGET_DIR="${1:-.}"

# セットアップ実行
execute_setup "${TOOL_NAME}" "${TARGET_DIR}" "${SKILLS_DIR}" "${GUIDANCE_FILE}"
```

### マッピング定義（例: scripts/mappings/claude.sh）

```bash
TOOL_NAME="Claude Code"
SKILLS_DIR=".claude/skills"
GUIDANCE_FILE=".claude/CLAUDE.md"
```

他のツールも同様の構造で、以下のようなマッピングがあります：
- Cursor: `.cursor/skills/`, `AGENTS.md`
- Codex: `.agents/skills/`, `AGENTS.md`
- Gemini: `.gemini/skills/`, `GEMINI.md`

### 共通セットアップロジック（scripts/lib/setup-common.sh）

主な処理：

1. `copy_skills()`: original配下の全スキルディレクトリをターゲットにコピー
2. `copy_guidance()`: AGENTS.mdをターゲット（ツールに応じてリネーム）にコピー
3. `execute_setup()`: 上記を組み合わせてセットアップを実行

現在の実装では、`get_original_dir()`が以下のようにローカルパスを取得しています：

```bash
get_original_dir() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    echo "${script_dir}/original"
}
```

### 既存のREADMEに記載されている使用例

現在のREADMEでは、以下のように各ツール別のスクリプトを実行する形式です：

```bash
# Claude Codeの場合
curl -sSL https://raw.githubusercontent.com/t-kuni/agent-rules/refs/heads/main/setup-claude.sh | bash
```

## リサーチ要件

以下のリサーチ観点について検討してください：

### 1. ⚠ 意思決定が必要です：setup.shの設計方針

**選択肢A：環境変数TOOLでツールを切り替える単一スクリプト（推奨）**

`TOOL=[ツール名]`という環境変数を受け取り、内部で適切なマッピングを選択してセットアップを実行する単一のsetup.shスクリプトを作成する方針。

メリット：
- ユーザー向けのコマンドがシンプル（`TOOL=claude curl ... | bash`）
- setup.sh一つを管理すればよい
- 各ツール用のsetup-[tool].shとの共存が可能

デメリット：
- setup.sh内で条件分岐が必要

**選択肢B：setup.shがラッパーとして既存スクリプトを呼び出す**

setup.shがTOOL環境変数に応じて、既存のsetup-[tool].shを呼び出す薄いラッパーとして機能する方針。

メリット：
- 既存のsetup-[tool].shをそのまま利用できる
- ロジックの重複が最小限

デメリット：
- curlでのダウンロードが複数回必要になる可能性
- スクリプト間の依存関係が複雑化

### 2. リモートからの実行における技術的課題の解決

**リサーチ項目：**
- curlでダウンロードしたスクリプトをbashにパイプした場合、SCRIPT_DIRの取得がどのように動作するか
- sourceコマンドで読み込む共通ライブラリ（setup-common.sh）やマッピングファイルをリモートから取得する方法
- 一時ディレクトリを使用する場合の実装方法

### 3. original配下のファイルの取得方法

**リサーチ項目：**
- GitHubから直接ファイルをダウンロードする方法（curl/wget）
- ディレクトリ構造を保持したままダウンロードする方法
- git cloneを使わずに特定のディレクトリのみを取得する方法（GitHub API、tarballダウンロードなど）

### 4. エラーハンドリングと検証

**リサーチ項目：**
- TOOL環境変数が未指定または不正な値の場合の処理
- ネットワークエラー時の適切なエラーメッセージ
- セットアップ完了の検証方法

### 5. 既存スクリプトとの互換性

**リサーチ項目：**
- 既存のsetup-[tool].shスクリプトを維持しつつ、新しいsetup.shを追加する方法
- 両方のアプローチをサポートする場合の実装方針
- READMEの更新方針
