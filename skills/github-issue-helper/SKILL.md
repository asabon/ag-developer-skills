---
name: github-issue-helper
description: GitHub Issueを用いたタスク起票、およびタスク完了時の報告・クローズを行うスキルです。
---

# github-issue-helper

GitHub Issueをタスク管理の起点として使用し、起票から、成果物の報告、Issueのクローズまでのライフサイクルを自動化・支援するためのスキルです。

## 1. GitHub Issue起票ルール

* **言語**: Issue のタイトルおよび本文は、すべて日本語で記述してください。
* **自動化**: `gh` CLI を使用して、正確かつ省力で起票します。
* **タイミング**: `implementation_plan.md` が承認された後、または新機能の実装を開始する直前に実行します。

### 起票手順
1. **プランの承認と情報確認**:
   - `implementation_plan.md` の内容から、必須項目（目的、実装概要、完了条件）を埋めるための情報が十分に揃っているか確認します。不足している場合は、起票プロセスに進む前にユーザーに質問して補完します。
2. **下書き（Draft）の生成**:
   - `skills/github-issue-helper/scripts/create-issue.ps1` を使用して、指定するタイトルで下書きファイルを生成します。
     ```powershell
     .\skills\github-issue-helper\scripts\create-issue.ps1 -Title "[prefix]: タイトル"
     ```
   - プレフィックスが `fix` の場合は [bug_template.md](file:///e:/work/ag-developer-skills/skills/github-issue-helper/resources/bug_template.md)、それ以外の場合は [feature_template.md](file:///e:/work/ag-developer-skills/skills/github-issue-helper/resources/feature_template.md) をベースにした `issue_draft.md` がカレントディレクトリに生成されます。
3. **下書きの編集と確認**:
   - 生成された `issue_draft.md` に、プランから抽出した「目的」「実装概要」「完了条件（Checklist）」を記述します。
   - 編集後、ユーザーにタイトルと下書きの内容を提示し、起票の最終確認を求めます。
4. **起票の実行**:
   - ユーザーの承認を得た後、`-Submit` フラグを付与してスクリプトを実行し、起票します。
     ```powershell
     .\skills\github-issue-helper\scripts\create-issue.ps1 -Title "[prefix]: タイトル" -Submit
     ```
5. **タスクへの紐付け**:
   - 出力された Issue 番号を `task.md` (またはそれに準ずる進捗管理ファイル) に追記し、作成された `issue_draft.md` が削除されていることを確認します。

### Issueフォーマット
* **タイトル**: `[prefix]: タイトル` (例: `feat: 学習結果のデータベース保存`, `fix: ログインエラーの修正`)
* **本文**: 起票の種類に応じて以下のテンプレートをベースに作成します。
  - 新機能実装 (`feat` 等): [resources/feature_template.md](file:///e:/work/ag-developer-skills/skills/github-issue-helper/resources/feature_template.md)
  - バグ修正 (`fix`): [resources/bug_template.md](file:///e:/work/ag-developer-skills/skills/github-issue-helper/resources/bug_template.md)

---

## 2. Issue の更新ワークフロー

開発途中で仕様変更や完了条件（チェックリスト）の変更、または進捗状況の更新が発生した場合は、以下の手順で Issue 本文を更新します。

1. **下書き（Draft）の生成**:
   - `skills/github-issue-helper/scripts/update-issue.ps1` を使用して、現在のIssue本文を下書きファイルとしてダウンロードします。
     ```powershell
     .\skills\github-issue-helper\scripts\update-issue.ps1 -IssueNumber <issue-number>
     ```
   - カレントディレクトリに `issue_draft.md` が生成されます。
2. **下書きの編集**:
   - 生成された `issue_draft.md` に対して、必要な変更（仕様変更の追記、完了チェックリストの更新など）を行います。
3. **更新の実行**:
   - `-Submit` フラグを付与してスクリプトを実行し、GitHub上のIssue本文を更新します。
     ```powershell
     .\skills\github-issue-helper\scripts\update-issue.ps1 -IssueNumber <issue-number> -Submit
     ```
   - 更新完了後、`issue_draft.md` は自動的に削除されます。

---

## 3. 完了報告ワークフロー

タスク完了時は、以下の手順で Issue への完了報告とクローズを行います。

1. **`walkthrough.md` の作成/更新**:
   - 実装した内容やテスト結果をまとめた `walkthrough.md` を作成または最新化します。
2. **スクリプトの実行**:
   - `skills/github-issue-helper/scripts/close-issue.ps1` を使用して、完了報告コメントの投稿と Issue のクローズを自動実行します。
     ```powershell
     .\skills\github-issue-helper\scripts\close-issue.ps1 -IssueNumber <issue-number>
     ```
   - これにより、`walkthrough.md` の内容が Issue にコメント投稿され、対象の Issue が自動的にクローズされます。

---

## 4. 開発とフィードバック

このスキルは [asabon/ag-developer-skills](https://github.com/asabon/ag-developer-skills) で開発されています。
バグ報告や機能の改善提案（スクリプトの追加など）がある場合は、以下のルールに従って開発元リポジトリの [Issues](https://github.com/asabon/ag-developer-skills/issues) に起票してください。

### 起票時の必須ルール（AIが自動適用できるようにするため）
* **対象ファイルの明記**: 修正・追加対象となるファイルの相対パスを明記してください。
* **具体的な修正案**: 抽象的なテキストだけでなく、修正箇所の「変更前・変更後のコードスニペット」または「追加するスクリプトコード」をマークダウンのコードブロックで記述してください。
* **検証方法の提示**: 修正が正しく適用されたかを判定するための確認手順（チェックリスト）を記述してください。
