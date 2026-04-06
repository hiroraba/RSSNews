//
//  FeedManagementViewModel.swift
//  RSSNews
//

import Foundation
import Combine

@MainActor
final class FeedManagementViewModel: ObservableObject {
    @Published private(set) var feeds: [RSSFeed] = []
    @Published private(set) var refreshingFeedURLs: Set<String> = []
    @Published var newFeedURL = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let environment: AppEnvironment

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    var recommendedFeeds: [RecommendedFeed] {
        let registeredURLs = Set(feeds.map(\.url))
        return RecommendedFeed.catalog.filter { !registeredURLs.contains($0.url) }
    }

    func loadFeeds() {
        do {
            feeds = try environment.feedRepository.fetchFeeds()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addFeed() async {
        _ = await addFeed(urlString: newFeedURL, shouldClearInput: true)
    }

    func addRecommendedFeed(_ feed: RecommendedFeed) async -> Bool {
        await addFeed(urlString: feed.url, shouldClearInput: false)
    }

    func removeFeeds(at offsets: IndexSet) {
        for index in offsets {
            let feed = feeds[index]
            do {
                try environment.feedRepository.deleteFeed(feed)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        loadFeeds()
    }

    func setFeedEnabled(_ feed: RSSFeed, isEnabled: Bool) {
        do {
            try environment.feedRepository.updateEnabledState(for: feed, isEnabled: isEnabled)
            loadFeeds()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshFeed(_ feed: RSSFeed) async -> Bool {
        guard let url = URL(string: feed.url) else {
            errorMessage = RSSServiceError.invalidURL.localizedDescription
            return false
        }
        guard environment.feedRefreshCoordinator.beginRefreshingFeed(feed.url) else { return false }

        refreshingFeedURLs.insert(feed.url)
        defer {
            refreshingFeedURLs.remove(feed.url)
            environment.feedRefreshCoordinator.endRefreshingFeed(feed.url)
        }

        do {
            let data = try await environment.rssFetcher.fetch(from: url)
            let parsedFeed = try environment.rssParser.parse(data: data)
            feed.title = parsedFeed.title
            try environment.articleRepository.upsert(items: parsedFeed.items, for: feed)
            try environment.feedRepository.updateFetchedDate(for: feed)
            loadFeeds()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func isRefreshing(_ feed: RSSFeed) -> Bool {
        environment.feedRefreshCoordinator.isRefreshingFeed(feed.url)
    }

    private func addFeed(urlString: String, shouldClearInput: Bool) async -> Bool {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = RSSServiceError.emptyFeedURL.localizedDescription
            return false
        }

        guard let url = URL(string: trimmed) else {
            errorMessage = RSSServiceError.invalidURL.localizedDescription
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let data = try await environment.rssFetcher.fetch(from: url)
            let parsedFeed = try environment.rssParser.parse(data: data)
            let feed = try environment.feedRepository.addFeed(urlString: trimmed, title: parsedFeed.title)
            try environment.articleRepository.upsert(items: parsedFeed.items, for: feed)
            try environment.feedRepository.updateFetchedDate(for: feed)
            loadFeeds()
            if shouldClearInput {
                newFeedURL = ""
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
