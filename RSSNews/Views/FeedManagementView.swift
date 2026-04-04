//
//  FeedManagementView.swift
//  RSSNews
//

import SwiftUI
import SwiftData

struct FeedManagementView: View {
    @ObservedObject var viewModel: FeedManagementViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("RSS管理")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(MolokaiTheme.text)
                Text("RSS フィードの追加、確認、削除を行います。")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(MolokaiTheme.textMuted)
                    .lineSpacing(4)
            }

            recommendedFeedsSection

            HStack(spacing: 12) {
                TextField("https://example.com/feed.xml", text: $viewModel.newFeedURL)
                    .textFieldStyle(.plain)
                    .molokaiInputField()

                Button("登録") {
                    Task { await viewModel.addFeed() }
                }
                .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.primary))
                .disabled(viewModel.isLoading)
            }

            if viewModel.isLoading {
                Label("フィード確認中...", systemImage: "rays")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(MolokaiTheme.warning)
            }

            List {
                ForEach(viewModel.feeds) { feed in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(feed.title)
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundStyle(MolokaiTheme.text)
                            Spacer()
                            Text(feed.isEnabled ? "有効" : "停止中")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundStyle(feed.isEnabled ? MolokaiTheme.success : MolokaiTheme.warning)
                        }

                        Text(feed.url)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(MolokaiTheme.textMuted)

                        if let lastFetchedAt = feed.lastFetchedAt {
                            Text("最終取得: \(lastFetchedAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(MolokaiTheme.secondary)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(MolokaiTheme.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(MolokaiTheme.text.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 6)
                }
                .onDelete(perform: viewModel.removeFeeds)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .overlay {
                if viewModel.feeds.isEmpty {
                    ContentUnavailableView(
                        "RSS未登録",
                        systemImage: "dot.radiowaves.left.and.right",
                        description: Text("RSS URLを追加すると一覧に表示されます。")
                    )
                    .foregroundStyle(MolokaiTheme.text)
                }
            }
            .molokaiGlassCard(
                tint: MolokaiTheme.text.opacity(0.05),
                stroke: MolokaiTheme.text.opacity(0.10)
            )
        }
        .padding(MolokaiTheme.pagePadding)
        .navigationTitle("RSS管理")
        .onAppear {
            viewModel.loadFeeds()
        }
        .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    private var recommendedFeedsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("おすすめのRSS")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(MolokaiTheme.text)
                    Text("すぐ読める定番ソースを未登録分だけ表示します。")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(MolokaiTheme.textMuted)
                        .lineSpacing(4)
                }

                Spacer()
            }

            if viewModel.recommendedFeeds.isEmpty {
                Text("おすすめ候補はすべて登録済みです。")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(MolokaiTheme.textMuted)
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(viewModel.recommendedFeeds) { feed in
                            RecommendedFeedCard(feed: feed, isLoading: viewModel.isLoading) {
                                Task { await viewModel.addRecommendedFeed(feed) }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(MolokaiTheme.cardPadding)
        .molokaiGlassCard(
            tint: MolokaiTheme.secondary.opacity(0.08),
            stroke: MolokaiTheme.secondary.opacity(0.16)
        )
    }
}

private struct RecommendedFeedCard: View {
    let feed: RecommendedFeed
    let isLoading: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Image(systemName: feed.symbolName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(MolokaiTheme.secondary)
                    .padding(10)
                    .background(Circle().fill(MolokaiTheme.secondary.opacity(0.12)))

                Spacer(minLength: 12)

                Text(feed.categoryLabel)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(MolokaiTheme.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(MolokaiTheme.elevated))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(feed.title)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .foregroundStyle(MolokaiTheme.text)

                Text(feed.summary)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(MolokaiTheme.textMuted)
                    .lineSpacing(4)
                    .lineLimit(3)

                Text(feed.url)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(MolokaiTheme.textMuted)
                    .lineLimit(1)
                    .textSelection(.enabled)
            }

            Button(isLoading ? "追加中..." : "このRSSを追加") {
                onAdd()
            }
            .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.primary))
            .disabled(isLoading)
        }
        .frame(width: 320, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(MolokaiTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(MolokaiTheme.text.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

#Preview {
    FeedManagementView(viewModel: FeedManagementView.previewViewModel)
}

private extension FeedManagementView {
    @MainActor
    static var previewViewModel: FeedManagementViewModel {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: RSSFeed.self,
            Article.self,
            configurations: configuration
        )
        let context = ModelContext(container)

        let firstFeed = RSSFeed(
            url: "https://www.publickey1.jp/atom.xml",
            title: "Publickey",
            lastFetchedAt: .now.addingTimeInterval(-900)
        )
        let secondFeed = RSSFeed(
            url: "https://gigazine.net/news/rss_2.0/",
            title: "GIGAZINE",
            lastFetchedAt: .now.addingTimeInterval(-3600),
            isActive: false
        )
        context.insert(firstFeed)
        context.insert(secondFeed)
        try! context.save()

        return FeedManagementViewModel(environment: AppEnvironment(modelContext: context))
    }
}
