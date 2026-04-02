//
//  SettingsView.swift
//  RSSNews
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var articleViewModel: ArticleListViewModel
    @ObservedObject var feedViewModel: FeedManagementViewModel

    private static let fetchedAtFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

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
                        HStack(alignment: .top, spacing: 12) {
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
                                    Text(lastFetchedText(for: feed))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer(minLength: 12)

                            Button(refreshButtonTitle(for: feed)) {
                                Task {
                                    if await feedViewModel.refreshFeed(feed) {
                                        articleViewModel.loadArticles()
                                    }
                                }
                            }
                            .disabled(isRefreshDisabled(for: feed))
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
        .alert("エラー", isPresented: .constant(feedViewModel.errorMessage != nil), actions: {
            Button("OK") { feedViewModel.errorMessage = nil }
        }, message: {
            Text(feedViewModel.errorMessage ?? "")
        })
    }

    private func lastFetchedText(for feed: RSSFeed) -> String {
        guard let lastFetchedAt = feed.lastFetchedAt else {
            return "最終更新: 未取得"
        }
        return "最終更新: \(Self.fetchedAtFormatter.string(from: lastFetchedAt))"
    }

    private func isRefreshDisabled(for feed: RSSFeed) -> Bool {
        articleViewModel.isRefreshing || feedViewModel.isRefreshing(feed)
    }

    private func refreshButtonTitle(for feed: RSSFeed) -> String {
        isRefreshDisabled(for: feed) ? "更新中..." : "更新"
    }
}
