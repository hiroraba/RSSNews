//
//  RSSNewsTests.swift
//  RSSNewsTests
//

import Testing
@testable import RSSNews

@MainActor
struct FeedRefreshCoordinatorTests {

    @Test func 単一フィード更新の開始と終了を追跡できる() {
        let coordinator = FeedRefreshCoordinator()

        #expect(coordinator.beginRefreshingFeed("https://example.com/feed.xml"))
        #expect(coordinator.isRefreshingFeed("https://example.com/feed.xml"))

        coordinator.endRefreshingFeed("https://example.com/feed.xml")

        #expect(!coordinator.isRefreshingFeed("https://example.com/feed.xml"))
    }

    @Test func 同じフィードの二重更新を防げる() {
        let coordinator = FeedRefreshCoordinator()

        #expect(coordinator.beginRefreshingFeed("https://example.com/feed.xml"))
        #expect(!coordinator.beginRefreshingFeed("https://example.com/feed.xml"))

        coordinator.endRefreshingFeed("https://example.com/feed.xml")

        #expect(coordinator.beginRefreshingFeed("https://example.com/feed.xml"))
    }

    @Test func 全件更新中は個別更新を開始できない() {
        let coordinator = FeedRefreshCoordinator()
        let urls = [
            "https://example.com/feed1.xml",
            "https://example.com/feed2.xml"
        ]

        #expect(coordinator.beginRefreshingAllFeeds(urls: urls))
        #expect(coordinator.isRefreshingFeed(urls[0]))
        #expect(coordinator.isRefreshingFeed(urls[1]))
        #expect(!coordinator.beginRefreshingFeed("https://example.com/feed3.xml"))

        coordinator.endRefreshingAllFeeds(urls: urls)

        #expect(!coordinator.isRefreshingFeed(urls[0]))
        #expect(coordinator.beginRefreshingFeed("https://example.com/feed3.xml"))
    }

    @Test func 個別更新中は全件更新を開始できない() {
        let coordinator = FeedRefreshCoordinator()
        let urls = [
            "https://example.com/feed1.xml",
            "https://example.com/feed2.xml"
        ]

        #expect(coordinator.beginRefreshingFeed(urls[0]))
        #expect(!coordinator.beginRefreshingAllFeeds(urls: urls))

        coordinator.endRefreshingFeed(urls[0])

        #expect(coordinator.beginRefreshingAllFeeds(urls: urls))
    }
}
