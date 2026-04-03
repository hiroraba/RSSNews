//
//  ViewModelTests.swift
//  RSSNewsTests
//

import Foundation
import SwiftData
import Testing
@testable import RSSNews

@MainActor
struct ViewModelTests {

    @Test func settingsViewModelはuserDefaultsに設定を保存する() {
        let suiteName = "RSSNewsTests.SettingsViewModelTests"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let viewModel = SettingsViewModel(userDefaults: defaults)
        viewModel.autoRefreshOnLaunch = false
        viewModel.markAsReadOnOpen = false

        let reloaded = SettingsViewModel(userDefaults: defaults)

        #expect(reloaded.autoRefreshOnLaunch == false)
        #expect(reloaded.markAsReadOnOpen == false)

        defaults.removePersistentDomain(forName: suiteName)
    }

    @Test func articleListViewModelは全件更新で記事を取り込む() async throws {
        let container = try TestSupport.makeModelContainer()
        let context = ModelContext(container)
        let feedRepository = FeedRepository(modelContext: context)
        let articleRepository = ArticleRepository(modelContext: context, categorizer: NewsCategorizer())
        _ = try feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Before")

        let environment = AppEnvironment(
            rssFetcher: MockRSSFetcher(result: .success(Data("rss".utf8))),
            rssParser: MockRSSParser(result: .success(
                ParsedRSSFeed(title: "After", items: [TestSupport.makeParsedItem()])
            )),
            categorizer: NewsCategorizer(),
            feedRepository: feedRepository,
            articleRepository: articleRepository,
            feedRefreshCoordinator: FeedRefreshCoordinator()
        )
        let viewModel = ArticleListViewModel(environment: environment)

        await viewModel.refreshAllFeeds()

        #expect(viewModel.lastRefreshDate != nil)
        #expect(viewModel.articles.count == 1)
        #expect(viewModel.articles.first?.sourceName == "After")
    }

    @Test func articleListViewModelは共有コーディネータで全件更新を抑止できる() async throws {
        let container = try TestSupport.makeModelContainer()
        let context = ModelContext(container)
        let feedRepository = FeedRepository(modelContext: context)
        let articleRepository = ArticleRepository(modelContext: context, categorizer: NewsCategorizer())
        let coordinator = FeedRefreshCoordinator()
        _ = try feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Feed")
        #expect(coordinator.beginRefreshingFeed("https://example.com/feed.xml"))

        let environment = AppEnvironment(
            rssFetcher: MockRSSFetcher(result: .success(Data("rss".utf8))),
            rssParser: MockRSSParser(result: .success(
                ParsedRSSFeed(title: "Feed", items: [TestSupport.makeParsedItem()])
            )),
            categorizer: NewsCategorizer(),
            feedRepository: feedRepository,
            articleRepository: articleRepository,
            feedRefreshCoordinator: coordinator
        )
        let viewModel = ArticleListViewModel(environment: environment)

        await viewModel.refreshAllFeeds()

        #expect(viewModel.lastRefreshDate == nil)
        #expect(viewModel.articles.isEmpty)
    }

    @Test func articleListViewModelは起動時自動更新の失敗をアラート用エラーにしない() async throws {
        let container = try TestSupport.makeModelContainer()
        let context = ModelContext(container)
        let feedRepository = FeedRepository(modelContext: context)
        let articleRepository = ArticleRepository(modelContext: context, categorizer: NewsCategorizer())
        _ = try feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Feed")

        let environment = AppEnvironment(
            rssFetcher: MockRSSFetcher(result: .failure(RSSServiceError.invalidResponse)),
            rssParser: MockRSSParser(result: .success(
                ParsedRSSFeed(title: "Feed", items: [TestSupport.makeParsedItem()])
            )),
            categorizer: NewsCategorizer(),
            feedRepository: feedRepository,
            articleRepository: articleRepository,
            feedRefreshCoordinator: FeedRefreshCoordinator()
        )
        let viewModel = ArticleListViewModel(environment: environment)

        await viewModel.refreshAllFeeds(reportErrors: false)

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.lastRefreshDate == nil)
    }

    @Test func articleListViewModelは現在の一覧に対する未読件数を返す() throws {
        let container = try TestSupport.makeModelContainer()
        let context = ModelContext(container)
        let feed = RSSFeed(url: "https://example.com/feed.xml", title: "Feed")
        context.insert(feed)
        context.insert(
            Article(
                link: "https://example.com/articles/1",
                title: "Unread",
                sourceName: "Feed",
                publishedAt: .now,
                summary: "Unread summary",
                category: .technology,
                isRead: false,
                feed: feed
            )
        )
        context.insert(
            Article(
                link: "https://example.com/articles/2",
                title: "Read",
                sourceName: "Feed",
                publishedAt: .now.addingTimeInterval(-60),
                summary: "Read summary",
                category: .technology,
                isRead: true,
                feed: feed
            )
        )
        try context.save()

        let environment = AppEnvironment(
            rssFetcher: MockRSSFetcher(result: .success(Data())),
            rssParser: MockRSSParser(result: .success(
                ParsedRSSFeed(title: "Feed", items: [TestSupport.makeParsedItem()])
            )),
            categorizer: NewsCategorizer(),
            feedRepository: FeedRepository(modelContext: context),
            articleRepository: ArticleRepository(modelContext: context, categorizer: NewsCategorizer()),
            feedRefreshCoordinator: FeedRefreshCoordinator()
        )
        let viewModel = ArticleListViewModel(environment: environment)

        viewModel.loadArticles()

        #expect(viewModel.unreadCount == 1)
    }

    @Test func articleListViewModelは条件クリアで検索と絞り込みを初期状態へ戻す() throws {
        let container = try TestSupport.makeModelContainer()
        let context = ModelContext(container)
        let feed = RSSFeed(url: "https://example.com/feed.xml", title: "Feed")
        context.insert(feed)
        context.insert(
            Article(
                link: "https://example.com/articles/1",
                title: "Swift",
                sourceName: "Feed",
                publishedAt: .now,
                summary: "favorite unread",
                category: .technology,
                isRead: false,
                isFavorite: true,
                feed: feed
            )
        )
        context.insert(
            Article(
                link: "https://example.com/articles/2",
                title: "Culture",
                sourceName: "Feed",
                publishedAt: .now.addingTimeInterval(-60),
                summary: "read item",
                category: .culture,
                isRead: true,
                isFavorite: false,
                feed: feed
            )
        )
        try context.save()

        let environment = AppEnvironment(
            rssFetcher: MockRSSFetcher(result: .success(Data())),
            rssParser: MockRSSParser(result: .success(
                ParsedRSSFeed(title: "Feed", items: [TestSupport.makeParsedItem()])
            )),
            categorizer: NewsCategorizer(),
            feedRepository: FeedRepository(modelContext: context),
            articleRepository: ArticleRepository(modelContext: context, categorizer: NewsCategorizer()),
            feedRefreshCoordinator: FeedRefreshCoordinator()
        )
        let viewModel = ArticleListViewModel(environment: environment)

        viewModel.searchText = "Swift"
        viewModel.selectedCategory = .technology
        viewModel.selectedSort = .favoritesFirst
        viewModel.favoritesOnly = true
        viewModel.unreadOnly = true
        viewModel.loadArticles()

        #expect(viewModel.hasActiveFilters)
        #expect(viewModel.articles.count == 1)

        viewModel.resetFilters()

        #expect(!viewModel.hasActiveFilters)
        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.selectedCategory == .all)
        #expect(viewModel.selectedSort == .newestFirst)
        #expect(viewModel.favoritesOnly == false)
        #expect(viewModel.unreadOnly == false)
        #expect(viewModel.articles.count == 2)
    }

    @Test func feedManagementViewModelはフィード追加時に取得結果を保存する() async throws {
        let container = try TestSupport.makeModelContainer()
        let context = ModelContext(container)
        let feedRepository = FeedRepository(modelContext: context)
        let articleRepository = ArticleRepository(modelContext: context, categorizer: NewsCategorizer())

        let environment = AppEnvironment(
            rssFetcher: MockRSSFetcher(result: .success(Data("rss".utf8))),
            rssParser: MockRSSParser(result: .success(
                ParsedRSSFeed(title: "Feed Title", items: [TestSupport.makeParsedItem()])
            )),
            categorizer: NewsCategorizer(),
            feedRepository: feedRepository,
            articleRepository: articleRepository,
            feedRefreshCoordinator: FeedRefreshCoordinator()
        )
        let viewModel = FeedManagementViewModel(environment: environment)
        viewModel.newFeedURL = "https://example.com/feed.xml"

        await viewModel.addFeed()

        #expect(viewModel.feeds.count == 1)
        #expect(viewModel.feeds.first?.title == "Feed Title")
        #expect(viewModel.newFeedURL.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func feedManagementViewModelは単一フィード更新後に更新状態を解放する() async throws {
        let container = try TestSupport.makeModelContainer()
        let context = ModelContext(container)
        let feedRepository = FeedRepository(modelContext: context)
        let articleRepository = ArticleRepository(modelContext: context, categorizer: NewsCategorizer())
        let feed = try feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Before")

        let environment = AppEnvironment(
            rssFetcher: MockRSSFetcher(result: .success(Data("rss".utf8))),
            rssParser: MockRSSParser(result: .success(
                ParsedRSSFeed(title: "After", items: [TestSupport.makeParsedItem()])
            )),
            categorizer: NewsCategorizer(),
            feedRepository: feedRepository,
            articleRepository: articleRepository,
            feedRefreshCoordinator: FeedRefreshCoordinator()
        )
        let viewModel = FeedManagementViewModel(environment: environment)

        let refreshed = await viewModel.refreshFeed(feed)

        #expect(refreshed)
        #expect(feed.title == "After")
        #expect(viewModel.refreshingFeedURLs.isEmpty)
        #expect(!viewModel.isRefreshing(feed))
    }
}
