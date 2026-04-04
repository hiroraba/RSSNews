//
//  ArticleListViewModel.swift
//  RSSNews
//

import Foundation
import Combine

@MainActor
final class ArticleListViewModel: ObservableObject {
    static let allSourcesOption = "すべての配信元"

    @Published private(set) var articles: [Article] = []
    @Published private(set) var availableSources: [String] = [ArticleListViewModel.allSourcesOption]
    @Published var selectedArticle: Article?
    @Published var searchText = ""
    @Published var selectedCategory: NewsCategory = .all
    @Published var selectedSource = ArticleListViewModel.allSourcesOption
    @Published var selectedSort: ArticleSortOption = .newestFirst
    @Published var favoritesOnly = false
    @Published var unreadOnly = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published private(set) var lastRefreshDate: Date?

    private let environment: AppEnvironment

    var unreadCount: Int {
        articles.reduce(into: 0) { count, article in
            if !article.isRead {
                count += 1
            }
        }
    }

    var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedCategory != .all || selectedSource != Self.allSourcesOption || favoritesOnly || unreadOnly
        || selectedSort != .newestFirst
    }

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func loadArticles() {
        do {
            let sourceNames = try environment.articleRepository.fetchSourceNames()
            availableSources = [Self.allSourcesOption] + sourceNames
            if !availableSources.contains(selectedSource) {
                selectedSource = Self.allSourcesOption
            }
            articles = try environment.articleRepository.searchArticles(
                query: searchText,
                category: selectedCategory,
                sourceName: selectedSource == Self.allSourcesOption ? nil : selectedSource,
                favoritesOnly: favoritesOnly,
                unreadOnly: unreadOnly,
                sort: selectedSort
            )
            if let selectedArticle, !articles.contains(where: { $0.id == selectedArticle.id }) {
                self.selectedArticle = nil
            }
            if self.selectedArticle == nil {
                selectedArticle = articles.first
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshAllFeeds(reportErrors: Bool = true) async {
        do {
            let feeds = try environment.feedRepository.fetchEnabledFeeds()
            let feedURLs = feeds.map(\.url)
            guard environment.feedRefreshCoordinator.beginRefreshingAllFeeds(urls: feedURLs) else { return }

            isRefreshing = true
            defer {
                environment.feedRefreshCoordinator.endRefreshingAllFeeds(urls: feedURLs)
                isRefreshing = false
            }

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
            if reportErrors {
                errorMessage = error.localizedDescription
            }
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

    func markAsReadIfNeeded(for article: Article) {
        do {
            try environment.articleRepository.markAsRead(article)
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

    func resetFilters() {
        searchText = ""
        selectedCategory = .all
        selectedSource = Self.allSourcesOption
        selectedSort = .newestFirst
        favoritesOnly = false
        unreadOnly = false
        loadArticles()
    }
}
