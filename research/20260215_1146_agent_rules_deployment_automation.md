## 1) 各ツールの「置き場所」と「内容改変の要否」（改変なしでいけるか）

### Cursor IDE

* **Project Rules**: `.cursor/rules/` 配下に Markdown（`.md` / `.mdc`）で置ける。旧形式として `.cursorrules` もある。([Cursor][1])
* **Agent Skills**: `.cursor/skills/<skill-name>/SKILL.md` 形式で運用されている（コミュニティ実例ベース）。([Zenn][2])
* **結論**: **コピーのみで対応可能**（ただし `.mdc` の frontmatter で適用範囲制御をしたい場合は内容改変が必要になり得るので、今回は `.md` 運用 or Skills 側に寄せる）。([Cursor][1])

### Claude Code

* **Project memory**: `./.claude/CLAUDE.md`（または `./CLAUDE.md`）が読み込まれる。([Claude Code][3])
* **Project rules**: `./.claude/rules/*.md`（トピック別に分割できる）。([Claude Code][3])
* **Skills**: `./.claude/skills/<skill-name>/SKILL.md`（ネストしたディレクトリでも自動発見）。([Claude API Docs][4])
* **結論**: **コピーのみで対応可能**。

### Codex CLI

* **AGENTS.md**: `AGENTS.md` / `AGENTS.override.md` をディレクトリ階層で探索・結合（各階層最大1ファイル）。([OpenAI Developers][5])
* **Agent Skills**: リポジトリ内は `.agents/skills` を CWD から repo root まで走査。([OpenAI Developers][6])
* **結論**: **コピーのみで対応可能**。

### Gemini CLI

* **Project context**: `GEMINI.md` を階層で探索（上方向＋サブディレクトリ走査）。([Gemini CLI][7])
* **Agent Skills**: `.gemini/skills/`（workspace）・`~/.gemini/skills/`（user）等から発見。([Gemini CLI][8])
* **結論**: **コピーのみで対応可能**（ただし `AGENTS.md` をそのまま使うには設定で `context.fileName` 変更が必要。改変なし運用に寄せるなら `GEMINI.md` にリネーム配置）。([Gemini CLI][7])

---

## 2) original → 各ツールへの「展開ルール」（内容改変なし＝コピー＆リネームのみ）

前提：`agent-rules/original/` は一切書き換えない。

### Skills（13個）を展開

* Cursor: `original/<skill>/` → `<target>/.cursor/skills/<skill>/`（ディレクトリごとコピー）
* Claude Code: `original/<skill>/` → `<target>/.claude/skills/<skill>/`
* Codex CLI: `original/<skill>/` → `<target>/.agents/skills/<skill>/` ([OpenAI Developers][6])
* Gemini CLI: `original/<skill>/` → `<target>/.gemini/skills/<skill>/` ([Gemini CLI][8])

### 基本ガイダンス（`original/AGENTS.md`）を展開

* Cursor: `<target>/AGENTS.md`（リネーム不要・ルートにコピー）([Cursor][9])
* Claude Code: `<target>/.claude/CLAUDE.md`（**`AGENTS.md` → `CLAUDE.md` にリネームしてコピー**）([Claude Code][3])
* Codex CLI: `<target>/AGENTS.md`（リネーム不要・ルートにコピー）([OpenAI Developers][5])
* Gemini CLI: `<target>/GEMINI.md`（**`AGENTS.md` → `GEMINI.md` にリネームしてコピー**）([Gemini CLI][7])

---

## 3) セットアップスクリプトのアーキテクチャ（意思決定）

### 採用案

**選択肢A（ツールごとに独立）＋「共通ライブラリ」**

* 入口：`setup-cursor.sh`, `setup-claude.sh`, `setup-codex.sh`, `setup-gemini.sh`
* 共通処理：`scripts/lib/setup-common.sh`（パス解決、copy、backup、dry-run、検証）
* ツール差分：`scripts/mappings/<tool>.sh`（展開先ディレクトリ定義・リネーム定義）

分割しても重複を最小化でき、ツール追加も “mapping を足すだけ” に寄せられる。

### 追加の選択肢（D）

**A + 統合ラッパー**：`setup.sh cursor|claude|codex|gemini`
（CI では統合を叩き、人間は `setup-*.sh` でも良い）

---

## 4) ファイル変換（実装方式）の意思決定

今回の制約だと「変換」は実質 **コピー＆リネーム**だけなので、
**選択肢A（シェル）**で十分（`cp`/`rsync` + `mkdir -p` + `find`）。

---

## 5) 配置先（意思決定）

**選択肢A（各ツール標準配置）**で確定が安全。

* `.cursor/skills`, `.claude/skills`, `.agents/skills`, `.gemini/skills` など、ツールが自動発見する場所に置けるため。([Claude API Docs][4])

---

## 6) 更新の取り込み（意思決定）

**選択肢A（上書きコピー）**が最も整合性を保ちやすい。
カスタマイズは「上書きされない場所」に逃がすのが現実的：

* Claude Code: `CLAUDE.local.md`（自動で `.gitignore`）を個人差分置き場にできる。([Claude Code][3])
* Gemini CLI: `~/.gemini/GEMINI.md`（グローバル）＋プロジェクト `GEMINI.md`（共有）で分離できる。([Gemini CLI][7])
* Codex: `~/.codex/AGENTS.md`（グローバル）＋リポジトリ `AGENTS.md`（共有）のレイヤで分離できる。([OpenAI Developers][5])

---

## 7) エラーハンドリング／バリデーション（スクリプトに入れると良い最低限）

* `original/` と `original/AGENTS.md` の存在チェック
* 展開先ディレクトリの作成と権限チェック
* 既存ファイルがある場合の挙動：

  * `--dry-run`（予定出力）
  * `--backup`（退避してから上書き）
  * `--force`（問答無用で上書き）
* 「内容を書き換えていない」保証：

  * コピー後に `diff -r`（またはハッシュ）で **source と dest が一致**することを検証（リネームは除く）

---

## 8) ドキュメント整備／CI連携（やるなら最短ルート）

* README に「各 `setup-*.sh` が作るファイル一覧（パス）」を固定で載せる
* CI（例：GitHub Actions）で

  1. 空のテンポラリ repo を作る
  2. 各 `setup-*.sh --dry-run` と実行
  3. 期待するパスが生成され、かつ内容差分がないことをテストする

[1]: https://cursor.com/docs/context/skills?utm_source=chatgpt.com "Agent Skills | Cursor Docs"
[2]: https://zenn.dev/redamoon/articles/article38-cursor-skills-rules-commands?utm_source=chatgpt.com "Cursorの5つの指示方法を比較してみた：AGENTS.md、ルール"
[3]: https://code.claude.com/docs/en/memory "Manage Claude's memory - Claude Code Docs"
[4]: https://docs.anthropic.com/en/docs/claude-code/skills "Extend Claude with skills - Claude Code Docs"
[5]: https://developers.openai.com/codex/guides/agents-md/ "Custom instructions with AGENTS.md"
[6]: https://developers.openai.com/codex/skills/ "Agent Skills"
[7]: https://geminicli.com/docs/cli/gemini-md/ "Provide context with GEMINI.md files | Gemini CLI"
[8]: https://geminicli.com/docs/cli/skills/ "Agent Skills | Gemini CLI"
[9]: https://cursor.com/docs/context/rules?utm_source=chatgpt.com "Rules | Cursor Docs"
