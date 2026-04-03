//
//  ContentView.swift
//  RSSNews
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        RootTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(ContentView.previewContainer)
}

private extension ContentView {
    static var previewContainer: ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: RSSFeed.self,
            Article.self,
            configurations: configuration
        )
        let context = ModelContext(container)

        let productFeed = RSSFeed(
            url: "https://example.com/product.xml",
            title: "Product Notes",
            lastFetchedAt: .now.addingTimeInterval(-1800)
        )
        let engineeringFeed = RSSFeed(
            url: "https://example.com/engineering.xml",
            title: "Engineering Weekly",
            lastFetchedAt: .now.addingTimeInterval(-7200)
        )

        let articles = [
            Article(
                link: "https://example.com/articles/liquid-glass",
                title: "ソリッドなカード設計で macOS アプリの情報密度を再設計する",
                sourceName: "Product Notes",
                publishedAt: .now.addingTimeInterval(-2400),
                summary: "ソリッドな面と控えめなアクセントラインで、一覧と詳細のコントラストを整理する設計メモです。",
                category: .technology,
                isFavorite: true,
                feed: productFeed
            ),
            Article(
                link: "https://example.com/articles/feed-ranking",
                title: "RSS の優先度制御を設計し、未読の情報取得コストを下げる",
                sourceName: "Engineering Weekly",
                publishedAt: .now.addingTimeInterval(-5400),
                summary: "カテゴリ、未読状態、更新時刻を使って、一覧の重心を崩さずに判断を速くする方法を検証しました。",
                category: .technology,
                feed: engineeringFeed
            ),
            Article(
                link: "https://example.com/articles/ui-balance",
                title: "サイドバーのカード密度を整えて読みやすさを改善する",
                sourceName: "Product Notes",
                publishedAt: .now.addingTimeInterval(-9200),
                summary: "外側と内側のカードが競合しないよう、余白とアクセントラインで階層を再構成しました。",
                category: .culture,
                isRead: true,
                feed: productFeed
            )
        ]

        context.insert(productFeed)
        context.insert(engineeringFeed)
        articles.forEach { context.insert($0) }
        try! context.save()

        return container
    }
}
