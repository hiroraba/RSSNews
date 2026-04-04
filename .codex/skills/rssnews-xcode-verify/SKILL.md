---
name: rssnews-xcode-verify
description: RSSNews リポジトリで修正後の検証を行うときに使う。Xcode MCP を優先してビルド、テスト、診断を進める。
---

# RSSNews Xcode 検証

この skill は、RSSNews のコード変更後に Xcode MCP を使って検証するときに使う。

## 優先手順

1. 可能なら `BuildProject` でビルドする。
2. 影響範囲が狭ければ `RunSomeTests`、広ければ `RunAllTests` を使う。
3. 失敗したら `GetBuildLog` で要点を確認する。
4. 追加の診断が必要なら `XcodeListNavigatorIssues` や `XcodeRefreshCodeIssuesInFile` を使う。
5. 最終報告では、何を実行し、何が通り、何が未実行かを明記する。

## 方針

- CLI の `xcodebuild` は、Xcode MCP が使えないときの代替とする。
- 変更範囲に対して過不足のない検証を選ぶ。
- 失敗ログは貼りすぎず、原因と影響を短く要約する。
- テスト未実行なら、未実行理由を明記する。
- 検証で merge 済み PR への follow-up が必要と分かっても、その対応は別 branch / 別 pull request で扱う。

## よく使う流れ

### 小さい変更

1. `BuildProject`
2. 必要なテストだけ `RunSomeTests`
3. 失敗時は `GetBuildLog`

### 機能追加や広い変更

1. `BuildProject`
2. `RunAllTests`
3. 失敗時は `GetBuildLog`
4. 問題ファイルごとに `XcodeRefreshCodeIssuesInFile`
