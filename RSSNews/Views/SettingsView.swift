//
//  SettingsView.swift
//  RSSNews
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var feedViewModel: FeedManagementViewModel

    var body: some View {
        Form {
            Section("取得") {
                Toggle("起動時にRSSを自動更新", isOn: $viewModel.autoRefreshOnLaunch)
            }

            Section("フィード") {
                if feedViewModel.feeds.isEmpty {
                    Text("RSSフィードはまだ登録されていません。")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(feedViewModel.feeds) { feed in
                        Toggle(
                            isOn: Binding(
                                get: { feed.isEnabled },
                                set: { feedViewModel.setFeedEnabled(feed, isEnabled: $0) }
                            )
                        ) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(feed.title)
                                Text(feed.url)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
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
        .onAppear {
            feedViewModel.loadFeeds()
        }
    }
}
