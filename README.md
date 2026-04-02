# RSSNews

SwiftUI + SwiftData で構築した、完全無料の個人用ニュース整理アプリMVPです。RSSのみを使って記事を取得し、ローカル保存・検索・既読管理・お気に入り管理を行います。

## 要件対応

- RSS登録 / 削除
- 記事一覧 / 記事詳細
- 検索
- 簡易カテゴリ分け
- 既読管理
- お気に入り
- 設定画面
- `link` ベースの重複排除
- async/await
- MVVM相当の責務分離

## ディレクトリ

- `RSSNews/Models`
- `RSSNews/Services`
- `RSSNews/Repositories`
- `RSSNews/ViewModels`
- `RSSNews/Views`
- `RSSNews/Utilities`

## 動作概要

1. `RSS管理` タブでRSS URLを登録
2. `記事` タブで更新を実行
3. 一覧から記事を選び、詳細確認・既読・お気に入り操作
4. 検索とカテゴリ絞り込みで整理

## 制約

- RSS / Atom の基本形式を対象にしたMVPです
- LLM分類や外部サーバー同期は未実装です
- 設定はローカル保存のみです
