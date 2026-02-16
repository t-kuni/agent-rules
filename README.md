# 🟦 Agent Rules

SDD(仕様駆動開発)のための各種AIツール用のルール・スキルのテンプレートです。

### 🟠 サポートツール

- **Cursor IDE**
- **Claude Code**
- **Codex CLI**
- **Gemini CLI**

# 🟦 使い方

対象プロジェクトのルートディレクトリで、以下のコマンドを実行してください：

### 🟠 基本的な使い方

`TOOL` 環境変数でツール名を指定して実行します：

**Cursor IDE の場合:**
```bash
TOOL=cursor bash -c "curl -sSL https://raw.githubusercontent.com/t-kuni/agent-rules/refs/heads/main/setup.sh | bash"
```

**Claude Code の場合:**
```bash
TOOL=claude bash -c "curl -sSL https://raw.githubusercontent.com/t-kuni/agent-rules/refs/heads/main/setup.sh | bash"
```

**Codex CLI の場合:**
```bash
TOOL=codex bash -c "curl -sSL https://raw.githubusercontent.com/t-kuni/agent-rules/refs/heads/main/setup.sh | bash"
```

**Gemini CLI の場合:**
```bash
TOOL=gemini bash -c "curl -sSL https://raw.githubusercontent.com/t-kuni/agent-rules/refs/heads/main/setup.sh | bash"
```

### 🟠 別のディレクトリに展開する場合

引数でターゲットディレクトリを指定できます：

```bash
TOOL=cursor bash -c "curl -sSL https://raw.githubusercontent.com/t-kuni/agent-rules/refs/heads/main/setup.sh | bash -s -- path/to/target/project"
```

### 🟠 注意事項

- セットアップスクリプトは既存ファイルを上書きします
- カスタマイズした設定は、ツールごとの個人用設定ファイル（例: `CLAUDE.local.md`）に保存してください

# 🟦 特徴

- タスク洗い出し時に「仕様書の差分」を読ませる
    - git diffを活用する
    - 理由：どの仕様が追加されて、どの仕様が削除されたかをAIに伝えられタスク洗い出しの品質が上がる。（diffを使わない場合、なにが変更されたのがわからない）
- キリの良い所でコンテキストを切る（適度に細かく切る）
    - 例： 実装方針検討（リサーチ）→仕様書更新 → タスク洗い出し → 実装（複数フェーズ）
        - 実装で大量のファイルを編集する場合はフェーズ分けし、フェーズ毎にコンテキストを切る
    - 理由：コンテキストの肥大化による品質低下を避ける
- auto-compact を無効にする
    - 圧縮させないことにより出力の品質を高める（前述の「キリの良い所でコンテキストを切る」と併用する）
- 作業を進める上での障害はすべてALERT.mdに書かせる（ALERT.mdが作られない場合は遂行可能と判断）
    - 理由：進行の障害を見落としにくくする（通常の出力と混ぜると見落とす）
- 仕様書の書き方
    - システムに求める振る舞いだけを記述する
        - 理由：実装をそのまま説明するような記述は二重管理になり修正コストが増える
    - １事実１箇所とする
        - 重複する記述はリンクを貼ることで回避する
        - 理由：矛盾や重複による実装のブレを回避するため
- 実装は「仕様書の写像」
    - 人間が見るのは仕様書が中心。先に仕様書を修正してから実装を修正する
- Thinking Model や Deep Research を活用する
    - 実装の大方針やアーキテクチャ設計、フォルダ設計、ライブラリ選定などに用いる
    - 手順
        1. AIにプロジェクトの背景を含めたリサーチプロンプトを書かせる
        2. 書かせたリサーチプロンプトを Thinking Model や Deep Researchに投げる
            - ネットの最新情報も参照させる
    - 理由
        - ここで決める内容は、将来の開発効率や品質に大きく影響するため。
        - 要件にマッチしたライブラリやフレームワークが選定できればそれがガードレールになる
        - テストコードの効果を最大化する事でデグレを減らせる
- 同一レイヤーの似ているコードを参考にさせる
    - メリット：コーディングスタイルが揃う
- 復唱テクニック
    - 詳細：https://zenn.dev/sesere/articles/0420ecec9526dc
    - 「絶対厳守ルール」としてこのテクニックを利用している

# 🟦 運用フロー

以下のフローに従って前述のプロンプト郡を活用する

* 青い破線を跨ぐタイミングでコンテキストをリセットする

![運用フローチャート](./flowchart.png)

# 🟦 タスクをトリガーするプロンプトの一覧

### 🟠 リサーチプロンプト

```
以下についてリサーチしてください

* ここに調査内容を列挙
```

### 🟠 外部のLLMに投げる時の要件整理プロンプト

```
以下のリサーチプロンプトを作成して

* 要件
```

### 🟠 仕様検討プロンプト

```
以下を満たせる仕様を検討してください

* 達成したいこと
```

### 🟠 タスク洗い出しプロンプト

```markdown
以下を実装するタスクを洗い出してください

* ここに仕様を列挙
```

### 🟠 仕様書の変更からタスク洗い出しプロンプト

```
仕様書を更新してます。直前のコミットの差分を確認して、タスクを洗い出してください
```

### 🟠 タスク遂行プロンプト

```
タスクを遂行して下さい
```

```
差分確認： `git add -A && GIT_PAGER=cat git diff HEAD`

テスト実行： `make test`
```

### 🟠 バグの原因調査プロンプト

```
以下のバグの原因を調査してください

* バグの挙動
```

### 🟠 テストエラー解析プロンプト

```
テストのエラーの原因を調査してください
```