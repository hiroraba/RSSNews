//
//  TestSupport.swift
//  RSSNewsTests
//

import Foundation
import SwiftData
@testable import RSSNews

@MainActor
enum TestSupport {
    static func makeModelContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: RSSFeed.self, Article.self, configurations: configuration)
    }

    static func makeRepositories() throws -> (feedRepository: FeedRepository, articleRepository: ArticleRepository) {
        let container = try makeModelContainer()
        let context = ModelContext(container)
        let categorizer = NewsCategorizer()
        return (
            feedRepository: FeedRepository(modelContext: context),
            articleRepository: ArticleRepository(modelContext: context, categorizer: categorizer)
        )
    }

    static func makeParsedItem(
        title: String = "Swift News",
        link: String = "https://example.com/articles/1",
        summary: String = "Swift release",
        publishedAt: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) -> ParsedRSSItem {
        ParsedRSSItem(title: title, link: link, summary: summary, publishedAt: publishedAt)
    }
}

final class MockRSSFetcher: RSSFetching {
    var result: Result<Data, Error>
    private(set) var fetchedURLs: [URL] = []

    init(result: Result<Data, Error>) {
        self.result = result
    }

    func fetch(from url: URL) async throws -> Data {
        fetchedURLs.append(url)
        return try result.get()
    }
}

final class MockRSSParser: RSSParsing {
    var result: Result<ParsedRSSFeed, Error>
    private(set) var parsedPayloads: [Data] = []

    init(result: Result<ParsedRSSFeed, Error>) {
        self.result = result
    }

    func parse(data: Data) throws -> ParsedRSSFeed {
        parsedPayloads.append(data)
        return try result.get()
    }
}

struct StubCategorizer: NewsCategorizing {
    let category: NewsCategory

    func categorize(title: String, summary: String) -> NewsCategory {
        category
    }
}
