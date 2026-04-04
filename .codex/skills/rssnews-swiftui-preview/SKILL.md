---
name: rssnews-swiftui-preview
description: RSSNews リポジトリで SwiftUI 画面変更を確認するときに使う。Xcode MCP の Preview と診断機能を優先して使う。
---

# RSSNews SwiftUI Preview

この skill は、SwiftUI の見た目や状態変化を確認したいときに使う。

## 優先手順

1. 変更した View を `XcodeRead` や `XcodeGrep` で確認する。
2. 対象ファイルに Preview があれば `RenderPreview` を使って確認する。
3. Preview がない、または壊れている場合は `BuildProject` と `XcodeRefreshCodeIssuesInFile` で診断する。
4. UI 変更後は、レイアウト崩れ、文言、省略表示、状態反映を確認する。

## 確認観点

- トグル、ボタン、リスト行などの操作要素が自然に配置されているか
- 既存ラベルやアクセシビリティ上の意味づけを壊していないか
- 読み込み中、空状態、エラー表示などの分岐が崩れていないか
- macOS の画面幅で極端に崩れないか

## 方針

- UI 変更でも責務分離は維持する。View の確認と、ViewModel / Service の責務混在は別問題として見る。
- Preview が使えるなら、実装後の確認に積極的に使う。
- Preview だけで十分でない場合は、ビルドやテスト結果も合わせて判断する。
- merge 済み PR に対する UI follow-up は既存 PR を編集せず、別 branch / 別 pull request として扱う。
