# RSSNews

RSSNews は SwiftUI + SwiftData で作る、完全無料の個人用ニュース整理アプリのMVPです。ニュース取得は RSS のみを使い、有料API・外部LLM・独自サーバーは使いません。

## 機能

- RSS登録 / 削除
- 記事一覧
- 記事詳細
- タイトル・概要・配信元を対象にした検索
- キーワードベースの簡易カテゴリ分け
- 既読管理
- お気に入り
- 設定画面
- フィードごとの有効 / 無効切り替え
- `link` ベースの重複排除

## 構成

- `Models/`: SwiftData モデルとRSSのDTO
- `Services/`: RSS取得、XMLパース、カテゴリ分類
- `Repositories/`: SwiftData保存層
- `ViewModels/`: 画面ロジック
- `Views/`: SwiftUI画面
- `Utilities/`: 日付解析とHTML整形

MVVM相当を基本にしつつ、将来拡張しやすいように `RSS取得層`、`パース層`、`保存層`、`ViewModel`、`View` を分離しています。

## 実装メモ

- async/await で RSS を取得
- XMLParser で RSS / Atom の基本要素を解析
- `Article.link` をユニーク制約にして重複排除
- カテゴリ分けはローカルのキーワード判定
- 設定は `UserDefaults` で保持

## 今後の拡張候補

- OPMLインポート / エクスポート
- サムネイル抽出
- feed単位フィルタ
- オフラインキャッシュ改善
- テスト追加
