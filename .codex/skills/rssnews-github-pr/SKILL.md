---
name: rssnews-github-pr
description: RSSNews リポジトリで GitHub 向けプルリクエストを作るときに使う。.github/pull_request_template.md に沿って title と body を組み立て、可能なら gh pr create まで進める skill。
---

# RSSNews GitHub PR

この skill は、RSSNews で GitHub 向けの pull request を作成するときに使う。

## 使うもの

- PR テンプレートは [.github/pull_request_template.md](/Users/matsuohiroki/ghq/github.com/hiroraba/RSSNews/.github/pull_request_template.md) を使う。
- 変更内容、検証結果、review 結果、README 更新有無を差分から拾う。

## 手順

1. `git status --short` と `git log --oneline` で対象コミットと作業ツリーを確認する。
2. `git diff`, `git diff --stat`, `git log --stat origin/...HEAD` などで PR の要点をまとめる。
3. テンプレートの各欄を埋める。
4. title は変更の主目的が分かる短い文にする。
5. `Verification` には実行済みの build、test、Preview だけを書く。未実行ならその旨を書く。
6. `Review Focus` には reviewer に特に見てほしい点だけを書く。
7. `gh` が使えるなら `gh pr create --title ... --body-file ...` を使う。使えないなら title と body をそのまま提示する。
8. 対象の pull request が既に merge 済みなら、その pull request は編集せず、別 branch / 別 pull request を作る。

## 書き方

- `Summary` は 1-3 行で目的と結果を書く。
- `Changes` はユーザー価値ごとに短く分ける。
- `Verification` は実行コマンドや MCP 実行結果ベースで事実だけを書く。
- `Checklist` はテンプレートの項目に合わせて更新する。
- 絵文字、過剰な装飾、長い changelog は避ける。

## title の目安

- bugfix: `Fix <what broke>`
- feature: `Add <user-visible capability>`
- mixed change: 主目的を 1 つ選び、それに寄せる

## 補足

- push 前なら先に push の確認を取る。
- PR 作成前に別モデル review がまだなら、先に review を終える。
- merge 済み PR の title / body / branch を流用して修正を積み増さない。必要なら follow-up PR として切り出す。
- このリポジトリの AGENTS.md と矛盾する場合は、そちらを優先する。
