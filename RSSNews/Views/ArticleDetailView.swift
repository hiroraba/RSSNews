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
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(article.title.isEmpty ? "(無題)" : article.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(MolokaiTheme.text)

                    HStack(spacing: 10) {
                        detailPill(article.sourceName, systemImage: "dot.radiowaves.left.and.right", tint: MolokaiTheme.secondary)
                        detailPill(article.category.rawValue, systemImage: "tag", tint: MolokaiTheme.success)
                        detailPill(article.publishedAt.formatted(date: .abbreviated, time: .shortened), systemImage: "clock", tint: MolokaiTheme.warning)
                    }
                }
                .padding(24)
                .molokaiGlassCard(tint: MolokaiTheme.text.opacity(0.05), stroke: MolokaiTheme.text.opacity(0.10))

                Text(article.summary.isEmpty ? "概要がありません。" : article.summary)
                    .textSelection(.enabled)
                    .foregroundStyle(MolokaiTheme.text)
                    .font(.system(.body, design: .rounded))
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .molokaiGlassCard(tint: MolokaiTheme.elevated.opacity(0.28), stroke: MolokaiTheme.text.opacity(0.08))

                HStack(spacing: 12) {
                    Link(destination: URL(string: article.link) ?? URL(fileURLWithPath: "/")) {
                        Label("元記事を開く", systemImage: "link")
                    }
                    .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.secondary))

                    Button(article.isRead ? "未読に戻す" : "既読にする") {
                        viewModel.toggleRead(for: article)
                    }
                    .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.textMuted))

                    Button(article.isFavorite ? "お気に入り解除" : "お気に入り") {
                        viewModel.toggleFavorite(for: article)
                    }
                    .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.accent))

                    Button("ブラウザで開く") {
                        guard let url = URL(string: article.link) else { return }
                        openURL(url)
                    }
                    .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.primary))
                }
            }
            .padding(24)
        }
        .navigationTitle("記事詳細")
        .task(id: article.link) {
            if markAsReadOnOpen, !article.isRead {
                viewModel.markAsReadIfNeeded(for: article)
            }
        }
    }

    private func detailPill(_ text: String, systemImage: String, tint: Color) -> some View {
        Label(text, systemImage: systemImage)
            .font(.system(.caption, design: .rounded, weight: .medium))
            .foregroundStyle(MolokaiTheme.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(MolokaiTheme.elevated))
            .overlay {
                Capsule().strokeBorder(tint.opacity(0.28), lineWidth: 1)
            }
    }
}
