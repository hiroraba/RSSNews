//
//  ArticleListView.swift
//  RSSNews
//

import SwiftUI

struct ArticleListView: View {
    @ObservedObject var viewModel: ArticleListViewModel
    @State private var isSidebarVisible = true

    var body: some View {
        NavigationStack {
            HSplitView {
                if isSidebarVisible {
                    sidebarPane
                        .frame(minWidth: 400, idealWidth: 470, maxWidth: 560)
                }

                detailPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            isSidebarVisible.toggle()
                        }
                    } label: {
                        Label(
                            isSidebarVisible ? "記事一覧を隠す" : "記事一覧を表示",
                            systemImage: "sidebar.leading"
                        )
                    }

                    Button("全件既読") {
                        viewModel.markAllAsRead()
                    }
                    .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.warning))

                    Button {
                        Task { await viewModel.refreshAllFeeds() }
                    } label: {
                        if viewModel.isRefreshing {
                            Label("更新中...", systemImage: "hourglass")
                        } else {
                            Label("更新", systemImage: "arrow.clockwise")
                        }
                    }
                    .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.secondary))
                }
            }
        }
        .navigationTitle("記事")
        .searchable(text: $viewModel.searchText, prompt: "タイトル・本文・配信元で検索")
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.loadArticles()
        }
        .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    private var sidebarPane: some View {
        VStack(alignment: .leading, spacing: 18) {
            ArticleFilterBar(viewModel: viewModel)

            articleListPanel
        }
        .padding(20)
    }

    private var detailPane: some View {
        Group {
            if let article = viewModel.selectedArticle {
                ArticleDetailView(article: article, viewModel: viewModel)
            } else {
                articlePlaceholder
            }
        }
    }

    private var articleListPanel: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.articles) { article in
                    Button {
                        viewModel.selectedArticle = article
                    } label: {
                        ArticleRowView(
                            article: article,
                            isSelected: viewModel.selectedArticle?.id == article.id
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(article.isRead ? "未読に戻す" : "既読にする") {
                            viewModel.toggleRead(for: article)
                        }
                        Button(article.isFavorite ? "お気に入り解除" : "お気に入り") {
                            viewModel.toggleFavorite(for: article)
                        }
                    }
                }
            }
            .padding(10)
        }
        .overlay {
            if viewModel.articles.isEmpty {
                ContentUnavailableView(
                    "記事がありません",
                    systemImage: "newspaper.fill",
                    description: Text("RSSを登録して更新すると記事が表示されます。")
                )
                .foregroundStyle(MolokaiTheme.text)
            }
        }
        .molokaiGlassCard(
            tint: MolokaiTheme.elevated.opacity(0.40),
            stroke: MolokaiTheme.secondary.opacity(0.18)
        )
    }

    private var articlePlaceholder: some View {
        VStack(spacing: 18) {
            Image(systemName: "newspaper.circle")
                .font(.system(size: 46))
                .foregroundStyle(MolokaiTheme.secondary)
            Text("記事を選択")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(MolokaiTheme.text)
            Text("左側のリストから記事を選ぶと、本文とメタデータをここに表示します。")
                .foregroundStyle(MolokaiTheme.textMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .molokaiGlassCard(
            tint: MolokaiTheme.primary.opacity(0.08),
            stroke: MolokaiTheme.primary.opacity(0.18)
        )
        .padding(20)
    }
}

private struct ArticleFilterBar: View {
    @ObservedObject var viewModel: ArticleListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Text("記事")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(MolokaiTheme.text)

                        unreadBadge
                    }
                    Text("未読やお気に入りを絞り込みながら、更新順に一覧できます。")
                        .foregroundStyle(MolokaiTheme.textMuted)
                }

                Spacer()

                if let lastRefreshDate = viewModel.lastRefreshDate {
                    Label(lastRefreshDate.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(MolokaiTheme.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(MolokaiTheme.elevated))
                        .overlay {
                            Capsule().strokeBorder(MolokaiTheme.secondary.opacity(0.28), lineWidth: 1)
                        }
                }
            }

            HStack(alignment: .center, spacing: 14) {
                Picker("カテゴリ", selection: $viewModel.selectedCategory) {
                    ForEach(NewsCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.menu)

                Toggle("未読のみ", isOn: $viewModel.unreadOnly)
                    .toggleStyle(.switch)

                Toggle("お気に入りのみ", isOn: $viewModel.favoritesOnly)
                    .toggleStyle(.switch)

                Spacer(minLength: 0)

                if viewModel.hasActiveFilters {
                    Button("条件クリア") {
                        viewModel.resetFilters()
                    }
                    .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.textMuted))
                }
            }
            .foregroundStyle(MolokaiTheme.text)
        }
        .padding(20)
        .molokaiGlassCard(
            tint: MolokaiTheme.text.opacity(0.05),
            stroke: MolokaiTheme.text.opacity(0.10)
        )
        .onChange(of: viewModel.selectedCategory) { _, _ in viewModel.loadArticles() }
        .onChange(of: viewModel.unreadOnly) { _, _ in viewModel.loadArticles() }
        .onChange(of: viewModel.favoritesOnly) { _, _ in viewModel.loadArticles() }
    }

    private var unreadBadge: some View {
        Text("未読 \(viewModel.unreadCount)")
            .font(.system(.caption, design: .rounded, weight: .bold))
            .foregroundStyle(MolokaiTheme.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(MolokaiTheme.elevated))
            .overlay {
                Capsule().strokeBorder(MolokaiTheme.primary.opacity(0.28), lineWidth: 1)
            }
    }
}

private struct ArticleRowView: View {
    let article: Article
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(article.isRead ? MolokaiTheme.text.opacity(0.10) : MolokaiTheme.primary)
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 10) {
                    Text(article.title.isEmpty ? "(無題)" : article.title)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(MolokaiTheme.text)
                        .lineLimit(2)

                    Spacer(minLength: 8)

                    HStack(spacing: 8) {
                        if article.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(MolokaiTheme.accent)
                        }
                        if !article.isRead {
                            Circle()
                                .fill(MolokaiTheme.primary)
                                .frame(width: 10, height: 10)
                        }
                    }
                }

                Text(article.summary.isEmpty ? "概要なし" : article.summary)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(MolokaiTheme.textMuted)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    tag(article.sourceName, tint: MolokaiTheme.secondary)
                    tag(article.category.rawValue, tint: MolokaiTheme.success)

                    Spacer(minLength: 8)

                    Text(article.publishedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(MolokaiTheme.textMuted)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isSelected ? MolokaiTheme.elevated : MolokaiTheme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            isSelected ? MolokaiTheme.primary.opacity(0.55) : MolokaiTheme.text.opacity(0.08),
                            lineWidth: isSelected ? 1.2 : 1
                        )
                }
        }
    }

    private func tag(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(.caption, design: .rounded, weight: .medium))
            .foregroundStyle(MolokaiTheme.text)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(MolokaiTheme.elevated))
            .overlay {
                Capsule().strokeBorder(tint.opacity(0.28), lineWidth: 1)
            }
    }
}
