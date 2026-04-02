//
//  SettingsView.swift
//  RSSNews
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("取得") {
                Toggle("起動時にRSSを自動更新", isOn: $viewModel.autoRefreshOnLaunch)
            }

            Section("記事表示") {
                Toggle("記事詳細を開いたら既読にする", isOn: $viewModel.markAsReadOnOpen)
            }

            Section("このアプリについて") {
                Text("完全無料の個人用ニュース整理MVPです。")
                Text("取得元はRSSのみで、外部サーバーや有料APIは使用しません。")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .navigationTitle("設定")
    }
}
