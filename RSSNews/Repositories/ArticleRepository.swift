//
//  ArticleRepository.swift
//  RSSNews
//

import Foundation
import SwiftData

@MainActor
final class ArticleRepository {
    private let modelContext: ModelContext
    private let categorizer: NewsCategorizing

    init(modelContext: ModelContext, categorizer: NewsCategorizing) {
        self.modelContext = modelContext
        self.categorizer = categorizer
    }

    func fetchArticles() throws -> [Article] {
        let descriptor = FetchDescriptor<Article>(sortBy: [SortDescriptor(\.publishedAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }

    func searchArticles(
        query: String,
        category: NewsCategory,
        sourceName: String?,
        favoritesOnly: Bool,
        unreadOnly: Bool,
        sort: ArticleSortOption
    ) throws -> [Article] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedSourceName = sourceName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredArticles = try fetchArticles().filter { article in
            let categoryMatch = category == .all || article.category == category
            let sourceMatch = trimmedSourceName?.isEmpty != false || article.sourceName == trimmedSourceName
            let favoriteMatch = !favoritesOnly || article.isFavorite
            let unreadMatch = !unreadOnly || !article.isRead
            let queryMatch: Bool

            if trimmedQuery.isEmpty {
                queryMatch = true
            } else {
                let haystack = "\(article.title) \(article.summary) \(article.sourceName)".lowercased()
                queryMatch = haystack.contains(trimmedQuery)
            }

            return categoryMatch && sourceMatch && favoriteMatch && unreadMatch && queryMatch
        }

        switch sort {
        case .newestFirst:
            return filteredArticles.sorted { lhs, rhs in
                lhs.publishedAt > rhs.publishedAt
            }
        case .oldestFirst:
            return filteredArticles.sorted { lhs, rhs in
                lhs.publishedAt < rhs.publishedAt
            }
        case .unreadFirst:
            return filteredArticles.sorted { lhs, rhs in
                if lhs.isRead != rhs.isRead {
                    return !lhs.isRead && rhs.isRead
                }
                return lhs.publishedAt > rhs.publishedAt
            }
        case .favoritesFirst:
            return filteredArticles.sorted { lhs, rhs in
                if lhs.isFavorite != rhs.isFavorite {
                    return lhs.isFavorite && !rhs.isFavorite
                }
                return lhs.publishedAt > rhs.publishedAt
            }
        }
    }

    func fetchSourceNames() throws -> [String] {
        Array(
            Set(
                try fetchArticles()
                    .map(\.sourceName)
                    .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            )
        )
        .sorted { lhs, rhs in
            lhs.localizedCaseInsensitiveCompare(rhs) == .orderedAscending
        }
    }

    func upsert(items: [ParsedRSSItem], for feed: RSSFeed) throws {
        for item in items {
            try upsert(item: item, for: feed)
        }
        try modelContext.save()
    }

    func toggleRead(for article: Article) throws {
        article.isRead.toggle()
        article.updatedAt = .now
        try modelContext.save()
    }

    func markAsRead(_ article: Article) throws {
        guard !article.isRead else { return }
        article.isRead = true
        article.updatedAt = .now
        try modelContext.save()
    }

    func toggleFavorite(for article: Article) throws {
        article.isFavorite.toggle()
        article.updatedAt = .now
        try modelContext.save()
    }

    func markAllAsRead() throws {
        let articles = try fetchArticles()
        for article in articles where !article.isRead {
            article.isRead = true
            article.updatedAt = .now
        }
        try modelContext.save()
    }

    private func upsert(item: ParsedRSSItem, for feed: RSSFeed) throws {
        if let existing = try article(with: item.link) {
            existing.title = item.title
            existing.summary = item.summary
            existing.publishedAt = item.publishedAt
            existing.sourceName = feed.title
            existing.category = categorizer.categorize(title: item.title, summary: item.summary)
            existing.updatedAt = .now
            existing.feed = feed
        } else {
            let article = Article(
                link: item.link,
                title: item.title,
                sourceName: feed.title,
                publishedAt: item.publishedAt,
                summary: item.summary,
                category: categorizer.categorize(title: item.title, summary: item.summary),
                feed: feed
            )
            modelContext.insert(article)
        }
    }

    private func article(with link: String) throws -> Article? {
        var descriptor = FetchDescriptor<Article>(predicate: #Predicate { $0.link == link })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
