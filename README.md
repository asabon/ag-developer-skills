# ag-developer-skills

Antigravity (Google's Agent-first development platform) 向けに設計された、GitHubを用いた開発ライフサイクル（Issueでのタスク管理、プルリクエストの作成、マージ後のクリーンアップなど）を支援・自動化するエージェントスキル（Agent Skills）のコレクションです。

## 提供するスキル

### 1. [github-issue-helper](skills/github-issue-helper/SKILL.md)
GitHub Issueをタスク管理の起点として使用し、起票から、成果物の報告、Issueのクローズまでのライフサイクルを自動化・支援します。
*   Issue の下書き生成・編集・自動起票
*   開発途中の Issue の更新ワークフロー
*   タスク完了時の `walkthrough.md` 紐付けと Issue の自動クローズ
*   インストール先からのスキル改善提案 Issue の起票 (`propose-improvement.ps1`)

### 2. [github-pr-helper](skills/github-pr-helper/SKILL.md)
プルリクエスト（PR）を中心としたトピックブランチの作成から、変更のコミット、事前検証、PR自動作成、マージ後のローカルクリーンアップまでを支援します。
*   `main` からの最新の取り込みと作業用トピックブランチの安全な作成
*   下書きを用いた PR 作成およびテストコード等の検証コマンド実行
*   PR マージ後のローカルブランチ削除とリモート追跡ブランチの自動クリーンアップ
*   インストール先からのスキル改善提案 Issue の起票 (`propose-improvement.ps1`)

---

## インストール方法

GitHub CLI (`gh`) を使用して、グローバル環境またはプロジェクトのワークスペースに直接インストールできます。

### 1. すべてのスキルを一括インストールする場合

リポジトリに含まれるすべてのスキルをまとめてインストールするには、リポジトリ名のみを指定します。

#### グローバルインストール

ローカル環境のすべての Antigravity セッションでこれらのスキルを有効にするには、以下を実行します。

```bash
gh skill install asabon/ag-developer-skills --agent antigravity
```
*※ `asabon` はご自身のGitHubユーザー名または組織名に置き換えてください。*

#### プロジェクトローカルへのインストール

特定のプロジェクト内のみで本スキルを有効にし、リポジトリに含めてチームで共有したい場合は、プロジェクトのルートディレクトリで以下を実行します。

```bash
gh skill install asabon/ag-developer-skills --agent antigravity --scope project
```

### 2. 特定のスキルのみを指定してインストールする場合

リポジトリ内の特定のスキルのみを指定して個別にインストールするには、リポジトリ名の後ろにスキル名（例: `github-issue-helper`）を指定します。

#### グローバルインストール

```bash
gh skill install asabon/ag-developer-skills github-issue-helper --agent antigravity
```

#### プロジェクトローカルへのインストール

```bash
gh skill install asabon/ag-developer-skills github-issue-helper --agent antigravity --scope project
```

---

## アップデート方法

インストール済みのスキルを最新バージョンに更新するには、以下のコマンドを使用します。

### すべてのスキルを一括で更新する

```bash
gh skill update --all
```

### 対話型で確認しながら更新する

```bash
gh skill update
```

### 特定のスキルを指定して更新する

```bash
gh skill update <skill-name>
```
*※ 例: `gh skill update github-issue-helper`*

---

## ライセンス

[LICENSE](LICENSE) を参照してください。