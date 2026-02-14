## 1. Cursor Project Rules（`.mdc`）とAgent Skills（`SKILL.md`）の構造比較と変換方針

* 調査結果の要約

  * `.mdc`は「YAML frontmatter + Markdown本文」で、`description / globs / alwaysApply`で適用条件を表す形式として紹介されています。([Cursor][1])
  * Agent Skillsは「スキル=ディレクトリ（最低限 `SKILL.md`）」「`SKILL.md`は必須frontmatter（`name`,`description`）+ Markdown本文」「追加メタは`metadata`等」で定義されています。([agentskills.io][2])
  * 変換の基本は **1ファイル=1スキル**で、本文は可能な限りそのまま移植し、`.mdc`の適用条件（`alwaysApply`,`globs`）は **Skills側の`metadata`に保持**して「情報落ち」を防ぐ方針が最も安全です（Skills仕様は任意キーの`metadata`を許容）。([agentskills.io][2])
  * Claude Code/Kiroは、スキルの自動発火判断に`description`を強く使う前提が明記されています（`name`はスラッシュコマンドにもなる）。([Claude Code][3])

* ⚠ 意思決定が必要です

  * 選択肢A（推奨）: **1:1変換 + `metadata`に元frontmatterを完全保持**

    * 目的（「内容を可能な限り維持」「将来の再生成」）に最も合致。([agentskills.io][2])
  * 選択肢B: ガイドライン系を統合して少数スキル化

    * コンテキスト量削減はしやすいが、元ルールの粒度が崩れて差分管理が難化。
  * 選択肢C: タスク系だけSkills化し、ガイドラインは別形式（後述のAGENTS/Steering）へ

    * 発火の確実性は上がるが、「`.mdc`内容をSkillsに維持」という要件と一部トレードオフ。

* 技術的な制約や注意点

  * Skills仕様の`name`は **ディレクトリ名と一致・小文字英数と`-`のみ**等の制約があり、`.mdc`ファイル名からの機械変換は相性が良い一方で、命名揺れがあると変換で詰まります。([agentskills.io][2])
  * Skillsは「起動時に全スキルの`name/description`だけ読む→必要時に本文を読む」という前提なので、`.mdc`の“参照条件”は **`description`に寄せる**のが実装上の近道です。([agentskills.io][2])

* 参考URL

```text
https://agentskills.io/specification
```

---

## 2. 複数AIコーディングツールでの汎用的な共有方法

* 調査結果の要約

  * **Agent Skills（SKILL.md）**は、Claude Codeが「Agent Skillsのオープン標準に準拠」と明言し、`.claude/skills/<skill-name>/SKILL.md`で扱います。([Claude Code][3])
  * Kiroも「Agent Skills標準に準拠するポータブルな指示パッケージ」としてSkillsを説明しています。([kiro.dev][4])
  * **AGENTS.md**は、Codexが「作業前に読み、グローバル→プロジェクト→現在ディレクトリまでを連結・後勝ちで上書き」と仕様を公開しています。([OpenAI Developers][5])
  * KiroもAGENTS.mdを取り込み（Kiro側ではinclusion modeなしで常時取り込み）と明記しています。([kiro.dev][6])
  * Gemini CLIはコンテキストファイル名を設定で差し替え可能で、単体文字列または配列で指定できる（=AGENTS.md併用も可能）ことがドキュメントにあります。([Gemini CLI][7])
  * Antigravityはドキュメント上でAgent SkillsやAGENTS.mdを扱う旨が示されています（取得できたのは検索スニペットの範囲）。([Google Antigravity][8])
  * Cursorは`.mdc`ルール（`description / globs / alwaysApply`）の枠組みがあり、Rules/Skillsを使い分ける導線が案内されています。([Cursor][1])

* ⚠ 意思決定が必要です

  * 選択肢A（推奨）: **「Skillsを正本」+「AGENTS.mdを入口（目次/ブリッジ）」+「各ツール形式へ生成」**

    * Skillsを“中身の正”にしつつ、AGENTS.mdで「常時適用」や「ツール非対応時の読み込み」を補完しやすい。([agentskills.io][2])
  * 選択肢B: **AGENTS.mdを正本**

    * Codex/Kiroでは強いが、Skillsの“パッケージ性”やツール間移植性（scripts/assets等）を捨てやすい。([agentskills.io][2])
  * 選択肢C: **ツール別に並列管理（現状維持）**

    * 短期は楽だが、更新コストが最も高い。

* 技術的な制約や注意点

  * Claude Codeは「スキルは`.claude/skills/`に置く」「`--add-dir`配下のスキルも自動ロード」等、配置前提が明確です。([Claude Code][3])
  * CodexはAGENTSの結合サイズに上限（`project_doc_max_bytes`既定32KiB）を持ち、巨大な“常時ルール”を単一ファイルにすると切り捨てリスクがあります。([OpenAI Developers][5])

* 参考URL

```text
https://code.claude.com/docs/en/skills
https://developers.openai.com/codex/guides/agents-md/
https://kiro.dev/docs/skills/
https://kiro.dev/docs/steering/
https://geminicli.com/docs/get-started/configuration/
```

---

## 3. `global.mdc`（常時適用）の扱い方（Skillsとして扱うべきか否か）

* 調査結果の要約

  * Skills仕様自体には`.mdc`の`alwaysApply`に相当する「常時注入」のフィールドはありません（`name/description`で発火→本文ロード）。([agentskills.io][2])
  * Codexは **グローバル指示（`~/.codex/AGENTS(.override).md`）+ プロジェクト階層のAGENTS** を“常時適用”の中核として設計しています。([OpenAI Developers][5])
  * Kiroも **Steeringの`inclusion: always`** と **AGENTS.md（常時取り込み）** を別枠で持っています。([kiro.dev][6])

* ⚠ 意思決定が必要です

  * 選択肢A（推奨）: **global.mdcはSkills化しない（=“常時枠”へ移す）**

    * 具体: `remake/AGENTS.md`（または各ツールの“常時ファイル”）を正として置き、Skillsから参照する。
    * 理由: Skillsは「必要時に本文ロード」であり、発火しない限りglobal本文が効かない設計だから。([agentskills.io][2])
  * 選択肢B: global.mdcもSkills化して“広めのdescription”で実質常時発火を狙う

    * 発火の確実性がツール実装依存で、品質保証が難しい。
  * 選択肢C: global.mdcを **二重管理（AGENTS/Steering + Skills複製）**

    * 最も安全だが「1事実1箇所」原則と衝突しやすい。

* 技術的な制約や注意点

  * Codexは「各ディレクトリで`AGENTS.override.md`→`AGENTS.md`→fallback名の順に最大1つを取り込み、ルート→カレントへ連結し、後ろ（近い方）が上書き」と明記されています。([OpenAI Developers][5])
  * KiroのAGENTS.mdは「inclusion modesをサポートしないが常時取り込み」と明記されています。([kiro.dev][6])

* 参考URL

```text
https://developers.openai.com/codex/guides/agents-md/
https://kiro.dev/docs/steering/
https://agentskills.io/specification
```

---

## 4. ツール固有ファイル（`init-worktree.md`, `worktree-init.sh`, `おまけのルール.md`）の除外方針の妥当性

* 調査結果の要約

  * Agent Skillsは「instructions +（任意で）scripts/references/assets」まで含められるため、スクリプト類を“入れる”選択肢自体は仕様上可能です。([agentskills.io][2])
  * 一方で、特定ツール（Cursor worktree）専用の初期化フローは、他ツール利用時にノイズ化しやすく、汎用共有の目的と衝突します（“複数ツールで汎用”が主目的の場合）。

* ⚠ 意思決定が必要です

  * 選択肢A（推奨）: **変換対象外のまま維持し、必要ならSkills側から「参照リンク」だけ置く**

    * “内容の維持”と“汎用性”の両立。Skills仕様は相対パス参照を推奨しており、参照だけなら混線しにくい。([agentskills.io][2])
  * 選択肢B: `worktree-init.sh`等をSkillsの`scripts/`へ移し、ツール非依存に再設計する

    * 将来の統一には効くが、「既存内容を可能な限り維持」とは方向が変わる。
  * 選択肢C: そのままSkillsに同梱（scripts/）

    * 汎用ツールで誤実行の誘因になりやすい。

* 技術的な制約や注意点

  * Skills仕様は「参照はスキルルートからの相対パス」「深い参照チェーンは避ける」など、参照運用のガイドがあります。([agentskills.io][2])

* 参考URL

```text
https://agentskills.io/specification
```

---

## 5. 変換スクリプト・ツールの必要性（手動 vs 自動、CI/CD）

* 調査結果の要約

  * Skills仕様には検証ツール（`skills-ref validate`）が案内されており、機械変換+CIでの形式保証に寄せやすいです。([agentskills.io][2])
  * CodexはAGENTS結合に上限があり、生成物のサイズ検査（超過検知）を自動化しやすいです。([OpenAI Developers][5])

* ⚠ 意思決定が必要です

  * 選択肢A（推奨）: **自動変換スクリプト（正本→生成物）+ CIでバリデーション**

    * 目的（複数ツールでの共有、内容維持、将来拡張）に対して最も事故が少ない。([agentskills.io][2])
  * 選択肢B: 手動変換

    * 初回は早いが、更新が入った瞬間に破綻しやすい。
  * 選択肢C: MCP等で外部化（中央集権）

    * “ファイルで管理”の良さは減る（設計変更が大きい）。

* 技術的な制約や注意点

  * Claude Code/KiroはSkillsの配置場所が固定的で、`remake/`に正本を置くなら **各ツールが読む場所への生成（コピー/シンボリックリンク）**が必要になりやすいです。([Claude Code][3])

* 参考URL

```text
https://agentskills.io/specification
https://code.claude.com/docs/en/skills
https://developers.openai.com/codex/guides/agents-md/
```

---

## 6. 内容の維持と品質保証（冒頭出力指示、リンク変換、動作確認）

* 調査結果の要約

  * Claude Codeは`name`が`/slash-command`になり、`description`が自動ロード判断に使われるため、「冒頭に特定テキストを出力」系は **本文先頭の“必須出力”としてそのまま残す**のが挙動一致に近いです。([Claude Code][3])
  * Skills仕様は「本文は自由形式」「参照ファイルは相対パス」「必要なら`references/`等に分割」という前提があるため、リンク変換は **“スキルルート基準の相対パス”へ寄せる**のが仕様適合です。([agentskills.io][2])
  * Codexは「どのinstructionソースを読んだか確認する」ための実行例・検証項目を公開しており、生成物テストに使えます。([OpenAI Developers][5])
  * Kiroは「リクエストがdescriptionにマッチすると自動activate」「UI上で管理」と説明しています。([kiro.dev][4])
  * Gemini CLIはコンテキストファイル名を設定で複数指定できるため、AGENTS.md/GEMINI.mdの併用検証が可能です（階層探索の詳細は非公式記事側の記述もあり）。([Gemini CLI][7])

* ⚠ 意思決定が必要です

  * 選択肢A（推奨）: **`.mdc`本文は原則無加工で移植し、差分が必要な箇所だけ“変換注記”を最小限付与**
  * 選択肢B: 変換後に“ツールごとに最適化した書き換え”を行う

    * 品質は上げられるが、「可能な限り維持」から離れやすい。

* 技術的な制約や注意点

  * Codexは「`AGENTS.override.md`があると同階層の`AGENTS.md`が無視される」など、上書き規則が明確なので、global/override運用を混ぜる場合は生成ルールを固定しないと事故りやすいです。([OpenAI Developers][5])
  * Skillsは「起動時に全スキルの`name/description`が載る」前提のため、descriptionが長すぎる/曖昧だと誤発火・未発火の原因になります。([agentskills.io][2])

* 参考URL

```text
https://agentskills.io/specification
https://developers.openai.com/codex/guides/agents-md/
https://geminicli.com/docs/get-started/configuration/
https://code.claude.com/docs/en/skills
https://kiro.dev/docs/skills/
```

[1]: https://cursor.com/ja/docs/context/rules?utm_source=chatgpt.com "Rules | Cursor Docs"
[2]: https://agentskills.io/specification "Specification - Agent Skills"
[3]: https://code.claude.com/docs/en/skills "Extend Claude with skills - Claude Code Docs"
[4]: https://kiro.dev/docs/skills/ "Agent Skills - IDE - Docs - Kiro"
[5]: https://developers.openai.com/codex/guides/agents-md/ "Custom instructions with AGENTS.md"
[6]: https://kiro.dev/docs/steering/ "Steering - IDE - Docs - Kiro"
[7]: https://geminicli.com/docs/get-started/configuration/ "Gemini CLI configuration | Gemini CLI"
[8]: https://antigravity.google/docs/skills?utm_source=chatgpt.com "Agent Skills - Google Antigravity Documentation"
