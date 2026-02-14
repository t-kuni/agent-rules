いまのリポジトリは、Cursor の Project Rules（`.cursor/rules` に置く `.mdc`）前提で、ガイドライン／タスクをファイル分割して配布している形ですね。([GitHub][1])
複数ツールで「同じナレッジ・プロンプト体系を共有」したいなら、次の選択肢が有力です。

---

## 1) Agent Skills（Skills）を“単一の正”にする（共有しやすさ最優先）

* Anthropicの Claude Code は、Skills を `.claude/skills/<skill>/SKILL.md` で扱え、サポートファイル（テンプレ・例・スクリプト等）も同梱できます。([Claude Code][2])
* GitHub の Copilot 側も Agent Skills を「オープンスタンダード」として扱い、`.github/skills` または `.claude/skills` 配置が明記されています（`SKILL.md` の YAML frontmatter＋本文）。([GitHub Docs][3])

**なぜ相性がいいか**

* あなたの `.mdc` も YAML frontmatter＋本文という構造で、Skills の `SKILL.md` と変換しやすいです（「概要/方針」「コーディング」「仕様検討」などを skill 単位にできる）。([GitHub][4])
* “いつ読むか/何の時に使うか” を frontmatter＋description に寄せられるので、ルールの肥大化に強い。([GitHub Docs][3])

---

## 2) ルートに AGENTS.md を置く（超軽量な共通入口）

「エージェント向け README」として置けるオープンフォーマット（セットアップ、テスト、規約などを集約）で、ツール間のブレを減らす“入口”として使えます。([Agents][5])

---

## 3) “正本→各ツール形式へ生成”のリポジトリ運用（実務向け）

単一フォーマット（例：Skills＋AGENTS.md）を正として、各ツールが読むファイルへ **自動生成**して配布するやり方です。

生成先の例（公式に置き場所が明確なもの）

* Claude Code: `CLAUDE.md`（プロジェクト常時コンテキスト）＋ `.claude/skills/*/SKILL.md`([Claude][6])
* GitHub Copilot: `.github/copilot-instructions.md`（常時指示）＋ `.github/prompts/*.prompt.md`（呼び出し型プロンプト）＋ `.github/skills/*/SKILL.md`([GitHub Docs][7])
* Cursor: いまの `.cursor/rules/*.mdc` を継続（生成物として扱う）([GitHub][1])

---

## 4) MCP で“ナレッジ/プロンプト配信”を外部化（中央集権にしたい場合）

MCP 対応クライアント（例：Claude Desktop / Cursor など）から、社内ルールやテンプレを「サーバ側の resources/prompts」として供給する方式です。([Model Context Protocol][8])
ファイル同期より設計は重くなりますが、「常に最新を参照」「ツール追加しても配布経路が同じ」に寄せられます。

---

## ルール/プロンプトの“品質管理”を回すツール（必要なら）

* **promptfoo**：プロンプトや指示の回帰テスト／評価を CLI＋CI で回しやすい（オープンソース）。([Promptfoo][9])
* **Langfuse / PromptLayer / Helicone**：プロンプトのバージョニングや管理（特にアプリ側でプロンプトを運用している場合に効く）。([Langfuse][10])

[1]: https://github.com/t-kuni/cursor-rules "GitHub - t-kuni/cursor-rules"
[2]: https://code.claude.com/docs/en/skills "Extend Claude with skills - Claude Code Docs"
[3]: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills "About Agent Skills - GitHub Docs"
[4]: https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/global.mdc "raw.githubusercontent.com"
[5]: https://agents.md/?utm_source=chatgpt.com "AGENTS.md"
[6]: https://claude.com/blog/using-claude-md-files "Using CLAUDE.MD files: Customizing Claude Code for your codebase | Claude"
[7]: https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot?utm_source=chatgpt.com "Adding repository custom instructions for GitHub Copilot"
[8]: https://modelcontextprotocol.io/clients?utm_source=chatgpt.com "Example Clients"
[9]: https://www.promptfoo.dev/docs/intro/?utm_source=chatgpt.com "Intro"
[10]: https://langfuse.com/docs/prompt-management/overview?utm_source=chatgpt.com "Open Source Prompt Management"
