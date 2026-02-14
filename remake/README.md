# Agent Skills変換結果

Cursor用の`.mdc`ルールファイルをAgent Skills形式に変換した結果です。

## 変換方針

調査資料（`research_rearch.md`）に基づき、以下の方針で変換しました：

- **選択肢A**: 1:1変換 + `metadata`に元frontmatterを完全保持
- **内容の維持**: 本文は無加工でそのまま移植
- **frontmatter変換**: Agent Skills仕様（`name`, `description`, `metadata`）に準拠

## ファイル構成

### 常時適用ルール

- `AGENTS.md`: 元`global.mdc`の内容（常時適用ルールとして配置）

### Agent Skills（13スキル）

各ディレクトリに`SKILL.md`が格納されています：

#### ガイドライン系 (6スキル)

- `guideline-specs/`: 仕様書(spec)執筆ガイドライン
- `guideline-alert/`: 遂行障害リスト(ALERT.md)作成ガイドライン
- `guideline-tasks/`: タスク一覧(TASK.md)作成ガイドライン
- `guideline-test/`: テストコードガイドライン
- `guideline-research/`: リサーチレポート(research)執筆ガイドライン
- `guideline-code/`: コーディングガイドライン

#### タスク系 (7スキル)

- `tasks-make-spec/`: 仕様検討ルール
- `tasks-exec-tasks/`: タスク遂行ルール
- `tasks-make-task-list/`: タスク洗い出しルール
- `tasks-make-research-prompt/`: リサーチプロンプト作成ルール
- `tasks-test-error/`: テストエラー原因調査ルール
- `tasks-exec-research/`: リサーチルール
- `tasks-bug-fix/`: バグ原因調査ルール

## 変換対象外ファイル

以下のファイルは変換対象外としました：

- `init-worktree.md`: Cursor固有の機能
- `worktree-init.sh`: Cursor固有のスクリプト
- `おまけのルール.md`: 使用しないルール

## 使用方法

### Claude Code / Kiro での使用

```bash
# プロジェクトの.claude/skillsまたは.kiro/skillsにコピー
cp -r remake/guideline-* /path/to/project/.claude/skills/
cp -r remake/tasks-* /path/to/project/.claude/skills/
cp remake/AGENTS.md /path/to/project/AGENTS.md
```

### OpenAI Codex での使用

```bash
# AGENTS.mdをプロジェクトルートにコピー
cp remake/AGENTS.md /path/to/project/AGENTS.md
```

### Cursor での使用

元の`.mdc`ファイルを使い続けるか、Agent Skills形式も併用できます。

## Agent Skills仕様への準拠

### frontmatter構造

```yaml
---
name: スキル名（ディレクトリ名と一致、小文字英数と-のみ）
description: 簡潔な説明（AIが自動発火判断に使用）
---
```

### 本文

- 元の`.mdc`ファイルの本文をそのまま維持
- 「すべての回答の冒頭に...」という出力指示も維持（仕様上推奨される形式）
- 内部リンクは元のまま（必要に応じて後で調整可能）

## N重管理について

調査結果と要件に基づき、以下の運用を前提としています：

- **正本**: この`remake/`ディレクトリ配下
- **使用時**: 各プロジェクトに手動でコピー
- **N重管理**: 許容（各プロジェクトで独自にカスタマイズ可能）

## 参考資料

- `research_rearch.md`: 変換方針の調査資料
- `research_strategy.md`: 戦略資料
- Agent Skills仕様: https://agentskills.io/specification
