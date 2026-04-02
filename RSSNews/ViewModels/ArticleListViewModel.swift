//
//  ArticleListViewModel.swift
//  RSSNews
//

import Foundation
import Combine

@MainActor
final class ArticleListViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published var selectedArticle: Article?
    @Published var searchText = ""
    @Published var selectedCategory: NewsCategory = .all
    @Published var favoritesOnly = false
    @Published var unreadOnly = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published private(set) var lastRefreshDate: Date?

    private let environment: AppEnvironment

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func loadArticles() {
        do {
            articles = try environment.articleRepository.searchArticles(
                query: searchText,
                category: selectedCategory,
                favoritesOnly: favoritesOnly,
                unreadOnly: unreadOnly
            )
            if selectedArticle == nil {
                selectedArticle = articles.first
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshAllFeeds() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let feeds = try environment.feedRepository.fetchEnabledFeeds()
            for feed in feeds {
                guard let url = URL(string: feed.url) else { continue }
                let data = try await environment.rssFetcher.fetch(from: url)
                let parsed = try environment.rssParser.parse(data: data)
                feed.title = parsed.title
                try environment.articleRepository.upsert(items: parsed.items, for: feed)
                try environment.feedRepository.updateFetchedDate(for: feed)
            }

            lastRefreshDate = .now
            loadArticles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleRead(for article: Article) {
        do {
            try environment.articleRepository.toggleRead(for: article)
            loadArticles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite(for article: Article) {
        do {
            try environment.articleRepository.toggleFavorite(for: article)
            loadArticles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllAsRead() {
        do {
            try environment.articleRepository.markAllAsRead()
            loadArticles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
