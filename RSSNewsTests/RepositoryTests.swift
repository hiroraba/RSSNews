//
//  RepositoryTests.swift
//  RSSNewsTests
//

import Foundation
import Testing
@testable import RSSNews

@MainActor
struct RepositoryTests {

    @Test func feedRepositoryはフィード追加と有効フィード取得ができる() throws {
        let repositories = try TestSupport.makeRepositories()

        let activeFeed = try repositories.feedRepository.addFeed(
            urlString: " https://example.com/feed1.xml ",
            title: "Feed 1"
        )
        let inactiveFeed = try repositories.feedRepository.addFeed(
            urlString: "https://example.com/feed2.xml",
            title: "Feed 2"
        )
        try repositories.feedRepository.updateEnabledState(for: inactiveFeed, isEnabled: false)

        let allFeeds = try repositories.feedRepository.fetchFeeds()
        let enabledFeeds = try repositories.feedRepository.fetchEnabledFeeds()

        #expect(activeFeed.url == "https://example.com/feed1.xml")
        #expect(allFeeds.count == 2)
        #expect(enabledFeeds.map(\.url) == ["https://example.com/feed1.xml"])
    }

    @Test func feedRepositoryは重複フィードを拒否する() throws {
        let repositories = try TestSupport.makeRepositories()
        _ = try repositories.feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Feed")

        do {
            _ = try repositories.feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Duplicate")
            Issue.record("Expected duplicate feed error")
        } catch let error as RSSServiceError {
            #expect(error == .duplicateFeed)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func articleRepositoryはupsertで記事を更新できる() throws {
        let repositories = try TestSupport.makeRepositories()
        let feed = try repositories.feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Feed")

        try repositories.articleRepository.upsert(
            items: [TestSupport.makeParsedItem(title: "Old", summary: "Old Summary")],
            for: feed
        )
        try repositories.articleRepository.upsert(
            items: [TestSupport.makeParsedItem(title: "New", summary: "New Summary")],
            for: feed
        )

        let articles = try repositories.articleRepository.fetchArticles()

        #expect(articles.count == 1)
        #expect(articles[0].title == "New")
        #expect(articles[0].summary == "New Summary")
        #expect(articles[0].sourceName == "Feed")
    }

    @Test func articleRepositoryは検索条件で絞り込みできる() throws {
        let repositories = try TestSupport.makeRepositories()
        let feed = try repositories.feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Feed")

        try repositories.articleRepository.upsert(
            items: [
                ParsedRSSItem(
                    title: "Swift Release",
                    link: "https://example.com/articles/1",
                    summary: "Technology summary",
                    publishedAt: .now
                ),
                ParsedRSSItem(
                    title: "Market Update",
                    link: "https://example.com/articles/2",
                    summary: "Business summary",
                    publishedAt: .now.addingTimeInterval(-60)
                )
            ],
            for: feed
        )

        let articles = try repositories.articleRepository.fetchArticles()
        let technology = try #require(articles.first(where: { $0.link == "https://example.com/articles/1" }))
        let business = try #require(articles.first(where: { $0.link == "https://example.com/articles/2" }))
        technology.isFavorite = true
        business.isRead = true

        let unreadFavorites = try repositories.articleRepository.searchArticles(
            query: "swift",
            category: .technology,
            favoritesOnly: true,
            unreadOnly: true,
            sort: .newestFirst
        )

        #expect(unreadFavorites.count == 1)
        #expect(unreadFavorites[0].title == "Swift Release")
    }

    @Test func articleRepositoryは指定された並び順で記事を返す() throws {
        let repositories = try TestSupport.makeRepositories()
        let feed = try repositories.feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Feed")

        try repositories.articleRepository.upsert(
            items: [
                ParsedRSSItem(
                    title: "Newest",
                    link: "https://example.com/articles/1",
                    summary: "summary",
                    publishedAt: .now
                ),
                ParsedRSSItem(
                    title: "Oldest",
                    link: "https://example.com/articles/2",
                    summary: "summary",
                    publishedAt: .now.addingTimeInterval(-120)
                ),
                ParsedRSSItem(
                    title: "Middle",
                    link: "https://example.com/articles/3",
                    summary: "summary",
                    publishedAt: .now.addingTimeInterval(-60)
                )
            ],
            for: feed
        )

        let articles = try repositories.articleRepository.fetchArticles()
        try #require(articles.first(where: { $0.title == "Newest" })).isFavorite = true
        try #require(articles.first(where: { $0.title == "Oldest" })).isRead = true

        let oldestFirst = try repositories.articleRepository.searchArticles(
            query: "",
            category: .all,
            favoritesOnly: false,
            unreadOnly: false,
            sort: .oldestFirst
        )
        let unreadFirst = try repositories.articleRepository.searchArticles(
            query: "",
            category: .all,
            favoritesOnly: false,
            unreadOnly: false,
            sort: .unreadFirst
        )
        let favoritesFirst = try repositories.articleRepository.searchArticles(
            query: "",
            category: .all,
            favoritesOnly: false,
            unreadOnly: false,
            sort: .favoritesFirst
        )

        #expect(oldestFirst.map(\.title) == ["Oldest", "Middle", "Newest"])
        #expect(unreadFirst.first?.title != "Oldest")
        #expect(favoritesFirst.first?.title == "Newest")
    }

    @Test func articleRepositoryは既読とお気に入りを更新できる() throws {
        let repositories = try TestSupport.makeRepositories()
        let feed = try repositories.feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Feed")
        try repositories.articleRepository.upsert(items: [TestSupport.makeParsedItem()], for: feed)
        let article = try #require(repositories.articleRepository.fetchArticles().first)

        try repositories.articleRepository.toggleRead(for: article)
        try repositories.articleRepository.toggleFavorite(for: article)

        #expect(article.isRead)
        #expect(article.isFavorite)

        try repositories.articleRepository.markAsRead(article)
        #expect(article.isRead)
    }

    @Test func articleRepositoryは全件既読にできる() throws {
        let repositories = try TestSupport.makeRepositories()
        let feed = try repositories.feedRepository.addFeed(urlString: "https://example.com/feed.xml", title: "Feed")
        try repositories.articleRepository.upsert(
            items: [
                TestSupport.makeParsedItem(link: "https://example.com/articles/1"),
                TestSupport.makeParsedItem(link: "https://example.com/articles/2")
            ],
            for: feed
        )

        try repositories.articleRepository.markAllAsRead()
        let articles = try repositories.articleRepository.fetchArticles()

        #expect(articles.count == 2)
        #expect(!articles.contains(where: { !$0.isRead }))
    }
}
