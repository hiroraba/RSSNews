# AGENTS.md

## プロジェクト概要

- `RSSNews` は SwiftUI + SwiftData で構成された、完全無料の個人用ニュースアプリ。
- 対象プラットフォームは macOS。
- 記事取得元は RSS / Atom のみ。保存・検索・既読・お気に入り管理はローカルで完結する。
- 有料API、LLM API、広告SDK、独自バックエンドは導入しない。

## ビルド手順

- Xcode: `RSSNews.xcodeproj` を開き、`RSSNews` スキームを選んで Build / Run する。
- Codex がビルド確認を行う場合、可能なら Xcode MCP の `BuildProject` を優先して使う。CLI の `xcodebuild` は代替手段とする。
- CLI:

```bash
xcodebuild -project RSSNews.xcodeproj -scheme RSSNews -configuration Debug build
```

## テスト手順

- 単体テスト / UIテストは `RSSNews` スキームから実行する。
- Codex がテストを実行する場合、可能なら Xcode MCP の `RunAllTests` または `RunSomeTests` を優先して使う。CLI の `xcodebuild test` は代替手段とする。
- CLI:

```bash
xcodebuild test -project RSSNews.xcodeproj -scheme RSSNews -destination 'platform=macOS'
```

- 機能変更時は、影響範囲に応じて既存テストの修正・追加要否を必ず確認する。
- 修正後は原則としてユニットテストを実行する。実行していない場合は、その理由を明記する。
- ビルドやテストに失敗した場合は、可能なら Xcode MCP の `GetBuildLog`、`XcodeListNavigatorIssues`、`XcodeRefreshCodeIssuesInFile` を使って原因を確認し、要点を報告する。

## アーキテクチャ上の基本方針

- `Models / Services / ViewModels / Views` の分離を維持する。
- 画面ロジックは `ViewModels`、取得・解析・分類などの処理は `Services`、データ表現は `Models` に置く。
- 永続化アクセスは既存の `Repositories` を経由し、View や Service から SwiftData 実装詳細を広げない。
- 新規実装も既存の依存方向に合わせ、責務の横断を増やさない。

## 禁止事項

- 有料API、LLM API、広告SDK、独自バックエンドの追加。
- RSS 以外のニュース取得経路の追加。
- 層をまたいだ責務混在。特に View への取得処理直書き、ViewModel へのパース処理直書き、Service への UI 状態保持追加。
- 大きなリファクタや広範囲な命名変更、無関係なファイル整理。

## 変更時のルール

- 最小差分を優先し、依頼範囲に直接必要な変更だけを入れる。
- 既存の命名、ディレクトリ構成、実装スタイルを尊重する。
- Codex は変更完了時に自動でコミットしてよいが、`git push` を行う前には必ず事前確認を取る。
- コミットメッセージは原則として日本語で記述する。
- コミットメッセージの先頭には変更種別が分かる絵文字を付ける。例: 機能追加は `✨`、バグ修正は `🐛`、リファクタリングは `♻️`、コードの見た目だけの修正は `🎨`、UI修正は `🖥️`、テスト追加・更新は `✅`、設定や運用ルール変更は `📝`。
- コード変更後は、完了前に必ず別モデルの sub-agent へコードレビューを依頼する。レビュー対象は変更差分に絞り、バグ、回帰、境界条件、テスト不足を確認する。
- review sub-agent で有意な指摘が出た場合は、可能なら修正してから完了する。未対応なら理由を明記する。
- 最終報告では、別モデル review を実施したことと、重要な指摘の有無を明記する。
- 最終報告では、上記に加えて、修正を知らない別メンバーが差分の概観をすぐ理解できる短い説明を必ず含める。
- `README.md` と `RSSNews/README.md` は、ユーザーから明示的に依頼された場合のみ更新する。
- 機能変更時は、関連テストの追加・更新要否を確認する。
- 修正後は、影響範囲に応じたユニットテストを原則実行する。
- SwiftUI の UI 変更時は、可能なら Xcode MCP の `RenderPreview` を使って対象画面の確認を行う。
- Swift / SwiftUI のコード探索や局所診断では、可能なら Xcode MCP の `XcodeRead`、`XcodeGrep`、`XcodeGlob`、`XcodeRefreshCodeIssuesInFile` を優先して使う。
- 機能変更時は、`README.md` と `RSSNews/README.md` の更新要否だけ確認し、明示依頼がない限り更新しない。
- 仕様判断に迷う場合は、無料・ローカル完結・RSS中心という前提を優先する。

## 完了条件

- ビルドが通る、または通せない理由が明確に説明されている。
- 変更内容が依頼範囲に収まり、不要な横展開がない。
- 関連テストの追加・更新、または未対応理由が明確である。
- `README` 更新要否の確認結果が明確である。
- 上記の禁止事項に抵触していない。
