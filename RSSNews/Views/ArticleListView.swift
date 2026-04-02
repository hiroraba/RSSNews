//
//  ArticleListView.swift
//  RSSNews
//

import SwiftUI

struct ArticleListView: View {
    @ObservedObject var viewModel: ArticleListViewModel

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 0) {
                ArticleFilterBar(viewModel: viewModel)
                    .padding(16)
                    .background(.bar)

                Divider()

                List(viewModel.articles, selection: $viewModel.selectedArticle) { article in
                    ArticleRowView(article: article)
                        .tag(article)
                        .contextMenu {
                            Button(article.isRead ? "未読に戻す" : "既読にする") {
                                viewModel.toggleRead(for: article)
                            }
                            Button(article.isFavorite ? "お気に入り解除" : "お気に入り") {
                                viewModel.toggleFavorite(for: article)
                            }
                        }
                }
                .listStyle(.sidebar)
                .overlay {
                    if viewModel.articles.isEmpty {
                        ContentUnavailableView(
                            "記事がありません",
                            systemImage: "newspaper.fill",
                            description: Text("RSSを登録して更新すると記事が表示されます。")
                        )
                    }
                }
            }
            .navigationTitle("記事")
            .navigationSplitViewColumnWidth(min: 300, ideal: 340, max: 420)
            .toolbar {
                ToolbarItemGroup {
                    Button("全件既読") {
                        viewModel.markAllAsRead()
                    }
                    Button {
                        Task { await viewModel.refreshAllFeeds() }
                    } label: {
                        if viewModel.isRefreshing {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Label("更新", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
        } detail: {
            if let article = viewModel.selectedArticle {
                ArticleDetailView(article: article, viewModel: viewModel)
            } else {
                ContentUnavailableView("記事を選択", systemImage: "sidebar.left")
            }
        }
        .navigationSplitViewStyle(.balanced)
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
}

private struct ArticleFilterBar: View {
    @ObservedObject var viewModel: ArticleListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("絞り込み")
                .font(.headline)

            Picker("カテゴリ", selection: $viewModel.selectedCategory) {
                ForEach(NewsCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("未読のみ", isOn: $viewModel.unreadOnly)
                .toggleStyle(.checkbox)

            Toggle("お気に入りのみ", isOn: $viewModel.favoritesOnly)
                .toggleStyle(.checkbox)

            if let lastRefreshDate = viewModel.lastRefreshDate {
                Text("最終更新: \(lastRefreshDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in viewModel.loadArticles() }
        .onChange(of: viewModel.unreadOnly) { _, _ in viewModel.loadArticles() }
        .onChange(of: viewModel.favoritesOnly) { _, _ in viewModel.loadArticles() }
    }
}

private struct ArticleRowView: View {
    let article: Article

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(article.title.isEmpty ? "(無題)" : article.title)
                    .font(.headline)
                    .lineLimit(2)
                if article.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                if !article.isRead {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                }
            }

            Text(article.summary.isEmpty ? "概要なし" : article.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack {
                Text(article.sourceName)
                Text(article.category.rawValue)
                Text(article.publishedAt.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
