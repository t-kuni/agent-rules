# 🟦 Cursor Rules

SDD(仕様駆動開発)のためのcursor用のルールのテンプレートです

# 🟦 ダウンロード

本リポジトリのルールファイル郡をまとめてダウンロードします。  
コマンドを実行したフォルダから見て `.cursor/rules` フォルダに配置されます。

```
mkdir -p ./.cursor/rules
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/global.mdc -o ./.cursor/rules/global.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/guideline-code.mdc -o ./.cursor/rules/guideline-code.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/guideline-research.mdc -o ./.cursor/rules/guideline-research.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/guideline-specs.mdc -o ./.cursor/rules/guideline-specs.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/guideline-tasks.mdc -o ./.cursor/rules/guideline-tasks.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/guideline-test.mdc -o ./.cursor/rules/guideline-test.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/tasks-bug-fix.mdc -o ./.cursor/rules/tasks-bug-fix.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/tasks-exec-research.mdc -o ./.cursor/rules/tasks-exec-research.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/tasks-exec-tasks.mdc -o ./.cursor/rules/tasks-exec-tasks.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/tasks-make-research-prompt.mdc -o ./.cursor/rules/tasks-make-research-prompt.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/tasks-make-spec.mdc -o ./.cursor/rules/tasks-make-spec.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/tasks-make-task-list.mdc -o ./.cursor/rules/tasks-make-task-list.mdc
curl -L https://raw.githubusercontent.com/t-kuni/cursor-rules/refs/heads/main/tasks-test-error.mdc -o ./.cursor/rules/tasks-test-error.mdc
```


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

# 🟦 運用フロー

以下のフローに従って前述のプロンプト郡を活用する

* 青い破線を跨ぐタイミングでコンテキストをリセットする

![運用フローチャート](./flowchart.png)