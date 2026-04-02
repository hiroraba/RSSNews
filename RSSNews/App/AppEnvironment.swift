//
//  AppEnvironment.swift
//  RSSNews
//

import Foundation
import SwiftData

@MainActor
final class FeedRefreshCoordinator {
    private var activeFeedURLs: Set<String> = []
    private var isRefreshingAllFeeds = false

    func beginRefreshingFeed(_ url: String) -> Bool {
        guard !isRefreshingAllFeeds, !activeFeedURLs.contains(url) else { return false }
        activeFeedURLs.insert(url)
        return true
    }

    func endRefreshingFeed(_ url: String) {
        activeFeedURLs.remove(url)
    }

    func beginRefreshingAllFeeds(urls: [String]) -> Bool {
        guard !isRefreshingAllFeeds, activeFeedURLs.isEmpty else { return false }
        isRefreshingAllFeeds = true
        activeFeedURLs.formUnion(urls)
        return true
    }

    func endRefreshingAllFeeds(urls: [String]) {
        activeFeedURLs.subtract(urls)
        isRefreshingAllFeeds = false
    }

    func isRefreshingFeed(_ url: String) -> Bool {
        isRefreshingAllFeeds || activeFeedURLs.contains(url)
    }
}

struct AppEnvironment {
    let rssFetcher: RSSFetching
    let rssParser: RSSParsing
    let categorizer: NewsCategorizing
    let feedRepository: FeedRepository
    let articleRepository: ArticleRepository
    let feedRefreshCoordinator: FeedRefreshCoordinator

    init(modelContext: ModelContext) {
        rssFetcher = RSSFetcher()
        rssParser = RSSParser()
        categorizer = NewsCategorizer()
        feedRepository = FeedRepository(modelContext: modelContext)
        articleRepository = ArticleRepository(modelContext: modelContext, categorizer: categorizer)
        feedRefreshCoordinator = FeedRefreshCoordinator()
    }
}
