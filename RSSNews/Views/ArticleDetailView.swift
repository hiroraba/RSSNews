//
//  ArticleDetailView.swift
//  RSSNews
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @ObservedObject var viewModel: ArticleListViewModel
    @Environment(\.openURL) private var openURL
    @AppStorage(SettingsViewModel.markAsReadOnOpenKey) private var markAsReadOnOpen = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title.isEmpty ? "(無題)" : article.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                HStack {
                    Label(article.sourceName, systemImage: "dot.radiowaves.left.and.right")
                    Label(article.category.rawValue, systemImage: "tag")
                    Label(article.publishedAt.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                }
                .foregroundStyle(.secondary)

                Divider()

                Text(article.summary.isEmpty ? "概要がありません。" : article.summary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Link(destination: URL(string: article.link) ?? URL(fileURLWithPath: "/")) {
                    Label("元記事を開く", systemImage: "link")
                }

                HStack {
                    Button(article.isRead ? "未読に戻す" : "既読にする") {
                        viewModel.toggleRead(for: article)
                    }
                    Button(article.isFavorite ? "お気に入り解除" : "お気に入り") {
                        viewModel.toggleFavorite(for: article)
                    }
                    Button("ブラウザで開く") {
                        guard let url = URL(string: article.link) else { return }
                        openURL(url)
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("記事詳細")
        .onAppear {
            if markAsReadOnOpen, !article.isRead {
                viewModel.toggleRead(for: article)
            }
        }
    }
}
