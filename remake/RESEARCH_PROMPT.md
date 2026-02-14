# リサーチ目的

Cursor用のProject Rulesとして作成された`.mdc`ファイルを、Agent Skills形式（`SKILL.md`）に変換し、複数のAIコーディングツールで汎用的に使えるようにするための情報を収集する。

特に以下の点について調査する：

1. Cursor Project Rules（`.mdc`形式）とAgent Skills（`SKILL.md`形式）の構造比較と変換方針
2. 複数のAIコーディングツール（Claude Code, Cursor, Kiro, Gemini CLI, Antigravity, Codex CLI）での汎用的な共有方法
3. `global.mdc`のような常時適用されるルールの扱い方（Skillsとして扱うべきか否か）
4. ツール固有のファイル（`init-worktree.md`, `worktree-init.sh`, `おまけのルール.md`）の除外方針の妥当性
5. 既存のmdcファイルに記載された内容を可能な限り維持する方法

# プロジェクト概要

このリポジトリは、Cursorの`.cursor/rules`フォルダに配置する`.mdc`ファイル形式でAI支援開発のガイドラインとタスクルールを管理している。

**リポジトリURL**: https://github.com/t-kuni/cursor-rules

**目的**: AIエージェントによる開発作業の品質向上とワークフロー標準化

**現状の構造**:
- `.mdc`ファイルはYAML frontmatter + Markdown本文で構成
- frontmatterには`description`、`alwaysApply`、`globs`などのメタデータを含む
- ファイルは目的別に分類されている（後述）

# 既存の実装・仕様情報

## ファイル分類

リポジトリには以下の`.mdc`ファイルが存在する：

### 1. 常時適用ルール
- **global.mdc**
  - `alwaysApply: true`が設定されている唯一のファイル
  - プロジェクト概要、現状のフェーズ・基本方針、絶対厳守ルール、フォルダ構成などを定義
  - すべてのタスク遂行時に有効なルールを記載

### 2. ガイドライン系（guideline-*.mdc）
- **guideline-alert.mdc**: 遂行障害リスト（ALERT.md）の記述ガイドライン
- **guideline-code.mdc**: コーディングガイドライン（Go言語向けの記述を含む）
- **guideline-research.mdc**: リサーチレポートの執筆ガイドライン
- **guideline-specs.mdc**: 仕様書（spec）の執筆ガイドライン
- **guideline-tasks.mdc**: タスク一覧（TASK.md）の作成ガイドライン
- **guideline-test.mdc**: テストに関するガイドライン

### 3. タスク系（tasks-*.mdc）
- **tasks-bug-fix.mdc**: バグ修正タスクのルール
- **tasks-exec-research.mdc**: リサーチ実行タスクのルール
- **tasks-exec-tasks.mdc**: タスク遂行のルール
- **tasks-make-research-prompt.mdc**: リサーチプロンプト作成ルール
- **tasks-make-spec.mdc**: 仕様書作成タスクのルール
- **tasks-make-task-list.mdc**: タスク一覧作成タスクのルール
- **tasks-test-error.mdc**: テストエラー対応のルール

### 4. 対象外ファイル（変換対象外）
- **init-worktree.md**: Cursor worktree初期化の説明（Cursor専用）
- **worktree-init.sh**: Cursor worktree初期化スクリプト（Cursor専用）
- **おまけのルール.md**: 未使用のルール

## .mdcファイルの構造

すべての`.mdc`ファイルは以下の構造を持つ：

```yaml
---
description: ファイルの説明と参照条件
globs: （オプション）対象ファイルパターン
alwaysApply: true/false（デフォルトはfalse）
---

（Markdown形式の本文）
```

**主要な特徴**:
- `description`フィールドには「参照条件」が含まれることが多い（例：「仕様書(spec)を作成・編集する」）
- 一部のガイドラインでは、冒頭に特定のテキストを出力する指示が含まれている
- 連番を付けない方針が多く見られる（修正コストを下げるため）
- 1事実1箇所の原則が強調されている（重複管理を避ける）

## 主要な概念とワークフロー

### ファイル生成フロー
1. **RESEARCH_PROMPT.md**: リサーチのための質問を外部AIに渡す
2. **research/[YYYYMMDD_hhmm]_*.md**: リサーチ結果を格納
3. **spec/*.md**: 仕様書を格納
4. **TASK.md**: タスク一覧を格納
5. **ALERT.md**: 遂行障害リストを格納

### 主要な原則
- プロトタイピング・MVP重視
- AI作業前提のため、学習コストより最善の実装を優先
- 不採用の情報は削除する（ノイズ削減）
- テストエラー時や想定外の作業発生時はALERT.mdに記載して中断

## 既存のリサーチ情報

`remake/research_strategy.md`には以下の情報が記載されている：

### Agent Skillsへの変換の相性
- Cursor `.mdc`はYAML frontmatter + 本文という構造で、Skills の`SKILL.md`と変換しやすい
- "いつ読むか/何の時に使うか"をfrontmatter + descriptionに寄せられる

### 複数ツール対応の選択肢
1. **Agent Skillsを単一の正とする**: Claude Code (`.claude/skills/*/SKILL.md`) と GitHub Copilot (`.github/skills/*/SKILL.md`や`.github/copilot-instructions.md`) がサポート
2. **AGENTS.mdを置く**: エージェント向けREADMEとしてツール間のブレを減らす入口
3. **正本→各ツール形式へ生成**: 単一フォーマットを正として各ツール形式へ自動生成
4. **MCPで外部化**: Model Context Protocolでナレッジを中央集権管理

### ツール別の配置場所
- **Claude Code**: `CLAUDE.md` + `.claude/skills/*/SKILL.md`
- **GitHub Copilot**: `.github/copilot-instructions.md` + `.github/prompts/*.prompt.md` + `.github/skills/*/SKILL.md`
- **Cursor**: `.cursor/rules/*.mdc`（継続）

# 変換要件

以下の条件を満たす変換方法を検討してください：

1. mdcファイルに記載された内容（ルール、ガイドライン、手順）を可能な限り維持する
2. 変換結果は`remake/`フォルダに格納する
3. `global.mdc`の扱い（常時適用ルールをSkillsとして扱うべきか、別の形式にすべきか）
4. 以下のツールで動作可能にする：
   - Claude Code
   - Cursor
   - Kiro
   - Gemini CLI
   - Antigravity
   - Codex CLI
5. Cursor専用ファイル（`init-worktree.md`, `worktree-init.sh`）と未使用ファイル（`おまけのルール.md`）は変換対象外

# リサーチ観点

以下の観点について調査し、選択肢がある場合は意思決定が必要な点を明示してください：

## 1. Agent Skills形式への変換方法

- Cursor `.mdc`とAgent Skills `SKILL.md`のフォーマット比較
- frontmatterの`description`、`alwaysApply`、`globs`をSkillsでどう表現するか
- ガイドライン系とタスク系のSkills分類方針

## 2. 複数ツールでの互換性確保

- 各AIコーディングツール（Claude Code, Cursor, Kiro, Gemini CLI, Antigravity, Codex CLI）のSkills/ルール読み込み仕様
- すべてのツールで共通利用できるフォーマットの有無
- ツール固有の拡張機能が必要な場合の対応方法

## 3. 常時適用ルール（global.mdc）の扱い

- `alwaysApply: true`をSkillsでどう表現するか
- 各ツールでの「常時適用」に相当する機能（例：`CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`）
- Skillsとは別の形式で管理すべきか

## 4. ファイル配置戦略

- 単一の正本を置き、各ツール向けに生成する方式の是非
- `remake/`フォルダの構成（Skills形式、生成スクリプト、ドキュメントなど）
- バージョン管理とメンテナンス性

## 5. 変換スクリプト・ツールの必要性

- 手動変換 vs 自動変換スクリプトの作成
- 既存ツール（例：promptfoo, Langfuse）の活用可能性
- CI/CDでの自動生成の検討

## 6. 内容の維持と品質保証

- mdcファイルの「冒頭に特定テキストを出力する」指示をSkillsでどう表現するか
- リンク参照（例：`[guideline-alert.mdc](.cursor/rules/guideline-alert.mdc)`）の変換方法
- 変換後の動作確認方法

# 使用ライブラリ・ツール

現時点では特定のライブラリやフレームワークは使用していない。純粋なMarkdownファイルとして管理されている。

# 期待する調査結果

各リサーチ観点について、以下の形式でまとめてください：

- 調査結果の要約
- 選択肢がある場合は「⚠ 意思決定が必要です」と明記
  - 選択肢A、選択肢B...の形で明示
  - 推奨度の高い選択肢から記述
- 技術的な制約や注意点
- 参考URL（公式ドキュメントなど）
