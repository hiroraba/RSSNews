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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero
                settingsCard
                feedCard
                aboutCard
            }
            .padding(20)
        }
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

    private var hero: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Control Surface")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(MolokaiTheme.text)
                Text("Molokai の彩度を抑えたネオンで、更新挙動と記事動線を調整します。")
                    .foregroundStyle(MolokaiTheme.textMuted)
            }
            Spacer()
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(MolokaiTheme.accent)
                .padding(18)
                .background(Circle().fill(MolokaiTheme.accent.opacity(0.12)))
        }
        .padding(22)
        .molokaiGlassCard(tint: MolokaiTheme.accent.opacity(0.08), stroke: MolokaiTheme.accent.opacity(0.20))
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Behavior")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(MolokaiTheme.text)

            Toggle("起動時にRSSを自動更新", isOn: $viewModel.autoRefreshOnLaunch)
            Toggle("記事詳細を開いたら既読にする", isOn: $viewModel.markAsReadOnOpen)
        }
        .toggleStyle(.switch)
        .foregroundStyle(MolokaiTheme.text)
        .padding(22)
        .molokaiGlassCard(tint: MolokaiTheme.secondary.opacity(0.08), stroke: MolokaiTheme.secondary.opacity(0.20))
    }

    private var feedCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Feed Switchboard")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(MolokaiTheme.text)

            if feedViewModel.feeds.isEmpty {
                Text("RSSフィードはまだ登録されていません。")
                    .foregroundStyle(MolokaiTheme.textMuted)
            } else {
                ForEach(feedViewModel.feeds) { feed in
                    HStack(alignment: .top, spacing: 14) {
                        Toggle(
                            isOn: Binding(
                                get: { feed.isEnabled },
                                set: { feedViewModel.setFeedEnabled(feed, isEnabled: $0) }
                            )
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(feed.title)
                                    .font(.system(.headline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(MolokaiTheme.text)
                                Text(feed.url)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(MolokaiTheme.textMuted)
                                Text(lastFetchedText(for: feed))
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(MolokaiTheme.secondary)
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
                        .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.success))
                        .disabled(isRefreshDisabled(for: feed))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(MolokaiTheme.surface.opacity(0.72))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .strokeBorder(MolokaiTheme.text.opacity(0.08), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(22)
        .molokaiGlassCard(tint: MolokaiTheme.success.opacity(0.06), stroke: MolokaiTheme.success.opacity(0.16))
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(MolokaiTheme.text)
            Text("完全無料の個人用ニュース整理MVPです。")
                .foregroundStyle(MolokaiTheme.text)
            Text("取得元はRSSのみで、外部サーバーや有料APIは使用しません。")
                .foregroundStyle(MolokaiTheme.textMuted)
        }
        .padding(22)
        .molokaiGlassCard(tint: MolokaiTheme.primary.opacity(0.07), stroke: MolokaiTheme.primary.opacity(0.16))
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
