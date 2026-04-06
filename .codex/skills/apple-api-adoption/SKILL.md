---
name: apple-api-adoption
description: 新しい Apple API / Framework を既存アプリへ導入するときに使う。要求整理、Apple 公式情報の確認、既存アーキテクチャとの整合確認、最小導入方針の決定、実装、検証、採用可否の要約までを一連で進める。
---

# Apple API Adoption

この skill は、`WeatherKit`、`StoreKit 2`、`BackgroundTasks`、`TipKit`、`SwiftData` など、新しい Apple API / Framework を既存アプリへ安全に導入したいときに使う。

## 目的

- 実装前に確認不足のまま API を入れない。
- Apple 公式情報を前提に、availability、capability、privacy、実装制約を整理する。
- 既存アーキテクチャに沿った最小差分の導入で終える。
- 採用可否と残課題を、実装理由つきで短く説明できる状態にする。

## 最初に整理すること

1. 何を実現したいのかを 1 文で定義する。
2. どの画面、機能、層に影響するかを洗い出す。
3. 既存の代替実装や近い責務のコードがあるか確認する。
4. 導入が調査だけでよいのか、実装まで求められているのかを明確にする。

## 公式情報の確認

- Apple 公式ドキュメントを優先する。可能なら Apple Developer Documentation、Xcode の `DocumentationSearch`、既存 SDK ヘッダや API availability を確認する。
- 次を確認してから設計に入る。
  - API / Framework の役割
  - OS / platform availability
  - entitlement、capability、privacy manifest、`Info.plist`、権限ダイアログ要否
  - main actor 制約、非同期制約、バックグラウンド制約、永続化制約
  - 推奨パターンと避けるべきパターン
- 情報が不足している場合は、推測で埋めずに「未確認事項」として切り出す。

## アーキテクチャ整合の確認

- 既存コードベースの責務分離を先に読む。新 API をどの層で受けるかを決めてから実装する。
- 基本方針:
  - `View`: 表示とイベント受け取りだけ
  - `ViewModel`: UI 状態、操作フロー、availability に応じた分岐
  - `UseCase` / `Service`: API 呼び出し、変換、副作用、外部依存との調停
  - `Repository`: 永続化や既存ストレージ境界との接続
- 新規 abstraction は、既存境界へ自然に収まらないときだけ追加する。
- API 都合で責務が崩れる場合は、まず adapter 的な薄い層で吸収できないか検討する。

## 導入方針の決め方

- まず最小導入を検討する。将来の拡張を理由に抽象化を増やしすぎない。
- 次を明示する。
  - 最小導入か、本格導入か
  - 既存 API と共存期間が必要か
  - feature flag、設定トグル、fallback が必要か
  - 非対応 OS でどう振る舞うか
  - entitlement や capability が無効な場合にどう失敗させるか
- ユーザー体験に失敗が露出する API では、成功時より失敗時の挙動を先に決める。

## 実装ルール

- 既存命名、ディレクトリ構成、依存方向に合わせる。
- 新規ライブラリは入れない。
- availability 分岐は呼び出し側に散らさず、なるべく境界でまとめる。
- entitlement / privacy / capability 変更が必要なら、コード変更とセットで最小限に入れる。
- テスト可能な境界を意識し、直接 Apple API を広範囲へ漏らさない。

## 検証

1. build を通す。
2. 影響範囲に応じた relevant test を実行する。
3. availability 分岐と非対応 OS / 設定時の挙動を確認する。
4. entitlement、capability、privacy 設定漏れがないか確認する。
5. 失敗時の UI / ログ / fallback が意図通りか確認する。

## 最終要約に含めること

- 採用可否
- なぜその設計にしたか
- 変更ファイル
- availability / capability / privacy / fallback の整理結果
- 残課題、未確認事項、将来の本格導入で追加が必要な点

## 成功条件

- Apple API の導入が「動く」だけでなく、設計理由を説明できる。
- availability / capability / privacy / fallback が整理されている。
- build が通る。
- 必要最低限の test がある、または未追加理由が明確である。
- 既存構成を壊していない。
