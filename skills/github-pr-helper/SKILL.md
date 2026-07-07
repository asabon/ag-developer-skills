---
name: github-pr-helper
description: GitHub プルリクエスト（PR）に関連する開発サイクル（ブランチ作成、検証、PR自動作成、マージ後のクリーンアップ）を支援・自動化するスキルです。
---

# github-pr-helper

プルリクエスト（PR）を中心とした開発ライフサイクル（安全なトピックブランチ作成、事前検証、PR of 自動作成、マージ後のローカルクリーンアップ）を安全かつ円滑に進めるためのスキルです。

## 1. 運用ルールとガイドライン

* **言語**: Pull Request のタイトルおよび本文は、すべて日本語で記述してください。
* **メインブランチの保護**:
  - `main` ブランチへの直接の `git commit` および `git push` は絶対に行わないでください。
  - ローカルでの `main` ブランチへの直接のマージ（`git merge`）も禁止です。
* **マージの承認**:
  - `main` ブランチへのマージは、必ず GitHub 上のプルリクエスト（PR）を介し、ユーザー自身による承認・マージ実行のもとで行われなければなりません。AIエージェント自身が直接 `main` へのマージを完了させてはなりません。
* **コミットメッセージ**: 変更内容を簡潔に表すメッセージを指定し、適切なプレフィックス（`feat:`, `fix:`, `clean:`, `docs:`, `test:`）を付与してください。

---

## 2. 開発ライフサイクル手順

### ステップ 1: 作業ブランチの作成 (`start-branch.ps1`)
機能開発やバグ修正を開始する際、`main` から最新の変更を取り込んだ上で、新しい作業ブランチを作成します。
1. **ブランチ作成の実行**:
   - `skills/github-pr-helper/scripts/start-branch.ps1` を使用して、指定するブランチ名で作業用トピックブランチを作成します。
     ```powershell
     .\skills\github-pr-helper\scripts\start-branch.ps1 -BranchName <branch-name>
     ```
   - `main` ブランチに切り替えて最新を `pull` した後、指定された名前で新規ブランチが切られます。

### ステップ 2: 実装・検証およびPRの作成 (`submit-pr.ps1`)
実装を終えたら、下書きを生成し、それを編集した後に検証およびPRの自動作成を実行します。
1. **下書き（Draft）の生成**:
   - `skills/github-pr-helper/scripts/submit-pr.ps1` を使用して、指定するタイトルで下書きファイルを生成します。
     ```powershell
     .\skills\github-pr-helper\scripts\submit-pr.ps1 -Title "[prefix]: タイトル"
     ```
   - [pr_template.md](file:///e:/work/ag-developer-skills/skills/github-pr-helper/resources/pr_template.md) をベースにした `pr_draft.md` がカレントディレクトリに生成されます。
2. **下書きの編集**:
   - 生成された `pr_draft.md` に対し、必要な記述（目的/背景、変更内容、関連Issueなど）を行います。
3. **検証およびPRの作成**:
   - 編集完了後、`-Submit` フラグを付与し、プロジェクトに応じた `-VerifyCommand`（任意）を指定してスクリプトを実行し、PRを作成します。
     ```powershell
     # 検証コマンド（例: npm test）を実行してPR作成
     .\skills\github-pr-helper\scripts\submit-pr.ps1 -Title "[prefix]: タイトル" -Submit -VerifyCommand "npm test"

     # 検証をスキップして直接PR作成
     .\skills\github-pr-helper\scripts\submit-pr.ps1 -Title "[prefix]: タイトル" -Submit
     ```
   - PR作成に成功した場合、`pr_draft.md` は自動的に削除されます。

### ステップ 3: マージ後のクリーンアップ (`cleanup-branch.ps1`)
PR がマージされた後、不要になったローカルおよび追跡ブランチを削除して整理します。
1. **クリーンアップの実行**:
   - `skills/github-pr-helper/scripts/cleanup-branch.ps1` を使用して、不要になった作業ブランチをクリーンアップします。
     ```powershell
     .\skills\github-pr-helper\scripts\cleanup-branch.ps1 -BranchName <branch-name>
     ```
   - `main` ブランチに移動し、最新を `pull` した後、該当のローカルブランチを安全に削除してリモート追跡ブランチをクリーンアップ (`git fetch --prune`) します。

---

## 3. 開発とフィードバック

このスキルは [asabon/ag-developer-skills](https://github.com/asabon/ag-developer-skills) で開発されています。
バグ報告や機能の改善提案（スクリプトの追加など）がある場合は、以下の手順および起票ルールに従って開発元リポジトリの [Issues](https://github.com/asabon/ag-developer-skills/issues) に起票してください。

### 改善提案の手順
1. **下書き（Draft）の生成**:
   - `skills/github-pr-helper/scripts/propose-improvement.ps1` を使用して、指定するタイトルで改善提案の下書きファイルを生成します。
     ```powershell
     .\skills\github-pr-helper\scripts\propose-improvement.ps1 -Title "feat/fix: タイトル"
     ```
   - カレントディレクトリに `improvement_draft.md` が生成されます。
2. **下書きの編集と確認**:
   - 生成された `improvement_draft.md` に、修正対象ファイル、具体的な変更コード案、検証手順を記述します。
   - 編集後、ユーザーにタイトルと下書き内容を提示し、起票の最終確認を求めます。
3. **提案の実行**:
   - ユーザーの承認を得た後、`-Submit` フラグを付与してスクリプトを実行し、開発元リポジトリへ起票します。
     ```powershell
     .\skills\github-pr-helper\scripts\propose-improvement.ps1 -Title "feat/fix: タイトル" -Submit
     ```
   - 起票完了後、`improvement_draft.md` は自動的に削除されます。

### 起票時の必須ルール（AIが自動適用できるようにするため）
* **対象ファイルの明記**: 修正・追加対象となるファイルの相対パスを明記してください。
* **具体的な修正案**: 抽象的なテキストだけでなく、修正箇所の「変更前・変更後のコードスニペット」または「追加するスクリプトコード」をマークダウンのコードブロックで記述してください。
* **検証方法の提示**: 修正が正しく適用されたかを判定するための確認手順（チェックリスト）を記述してください。
