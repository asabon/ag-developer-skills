---
name: github-pr-helper
description: GitHub プルリクエスト（PR）に関連する開発サイクル（ブランチ作成、検証、PR自動作成、マージ後のクリーンアップ）を支援・自動化するスキルです。
---

# github-pr-helper

プルリクエスト（PR）を中心とした開発ライフサイクル（安全なトピックブランチ作成、事前検証、PRの自動作成、マージ後のローカルクリーンアップ）を安全かつ円滑に進めるためのスキルです。

## 1. Git運用ルールとブランチ戦略

* **メインブランチの保護**:
  - `main` ブランチへの直接の `git commit` および `git push` は絶対に行わないでください。
  - ローカルでの `main` ブランチへの直接のマージ（`git merge`）も禁止です。
* **マージの承認**:
  - `main` ブランチへのマージは、必ず GitHub 上のプルリクエスト（PR）を介し、ユーザー自身による承認・マージ実行のもとで行われなければなりません。AIエージェント自身が直接 `main` へのマージを完了させてはなりません。

### コミットメッセージのルール
変更内容を簡潔に表すメッセージを指定し、適切なプレフィックスを付与してください。
* `feat:` 新機能の実装や追加
* `fix:` バグ修正や挙動の調整
* `clean:` リファクタリングや不要になったコード/機能の削除
* `docs:` ドキュメントやルールファイルの作成・更新
* `test:` ユニットテストの追加・変更

---

## 2. 開発ライフサイクル手順

プルリクエストに関連する作業は、提供されているスクリプト群を使って自動化します。

### ステップ 1: 作業ブランチの作成 (`start-branch.ps1`)
機能開発やバグ修正を開始する際、`main` から最新の変更を取り込んだ上で、新しい作業ブランチを作成します。
```powershell
.\skills\github-pr-helper\scripts\start-branch.ps1 -BranchName <branch-name>
```
* **動作**: `main` に切り替えて最新を `pull` した後、指定された名前で新規ブランチを切ります。

### ステップ 2: 実装および検証・PRの作成 (`submit-pr.ps1`)
実装を終えたら、検証コマンド（任意）を実行し、パスした場合にのみ GitHub 上へ PR を自動作成します。
```powershell
# 検証コマンド（例: npm test）を実行してPR作成
.\skills\github-pr-helper\scripts\submit-pr.ps1 -Title "<PRタイトル>" -Body "<PR本文>" -VerifyCommand "npm test"

# 検証をスキップして直接PR作成
.\skills\github-pr-helper\scripts\submit-pr.ps1 -Title "<PRタイトル>" -Body "<PR本文>"
```
* **動作**: `-VerifyCommand` が指定されている場合、そのコマンドを内部実行し、成功した場合のみ `gh pr create` を呼び出します。指定がない場合は検証をスキップします。


### ステップ 3: マージ後のクリーンアップ (`cleanup-branch.ps1`)
PR がマージされた後、不要になったローカルおよび追跡ブランチを削除して整理します。
```powershell
.\skills\github-pr-helper\scripts\cleanup-branch.ps1 -BranchName <branch-name>
```
* **動作**: `main` ブランチに移動し、最新を `pull` した後、該当のローカルブランチを安全に削除してリモート追跡ブランチをクリーンアップ (`git fetch --prune`) します。

---

## 3. 開発とフィードバック

このスキルは [asabon/ag-developer-skills](https://github.com/asabon/ag-developer-skills) で開発されています。
バグ報告や機能の改善提案（スクリプトの追加など）がある場合は、以下のルールに従って開発元リポジトリの [Issues](https://github.com/asabon/ag-developer-skills/issues) に起票してください。

### 起票時の必須ルール（AIが自動適用できるようにするため）
* **対象ファイルの明記**: 修正・追加対象となるファイルの相対パスを明記してください。
* **具体的な修正案**: 抽象的なテキストだけでなく、修正箇所の「変更前・変更後のコードスニペット」または「追加するスクリプトコード」をマークダウンのコードブロックで記述してください。
* **検証方法の提示**: 修正が正しく適用されたかを判定するための確認手順（チェックリスト）を記述してください。
