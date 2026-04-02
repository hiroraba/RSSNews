//
//  ModelUtilityServiceTests.swift
//  RSSNewsTests
//

import Foundation
import Testing
@testable import RSSNews

struct ModelUtilityServiceTests {

    @Test func articleCategoryのgetterとsetterが連動する() {
        let article = Article(
            link: "https://example.com/articles/1",
            title: "Article",
            sourceName: "Feed",
            publishedAt: .now,
            summary: "Summary",
            category: .technology
        )

        #expect(article.category == .technology)

        article.category = .business

        #expect(article.categoryRawValue == NewsCategory.business.rawValue)
        #expect(article.category == .business)
    }

    @Test func rssFeedのisEnabledはisActiveに反映される() {
        let feed = RSSFeed(url: "https://example.com/feed.xml", title: "Feed", isActive: true)

        feed.isEnabled = false

        #expect(feed.isActive == false)
        #expect(feed.isEnabled == false)
    }

    @Test func dateParserはrss形式とiso8601形式を解釈できる() {
        let rssDate = DateParser.parse("Tue, 02 Apr 2024 12:34:56 +0900")
        let isoDate = DateParser.parse("2024-04-02T03:34:56Z")

        #expect(rssDate != nil)
        #expect(isoDate != nil)
    }

    @Test func decodedHTMLはタグ除去と基本エンティティの復元を行う() {
        let decoded = "<p>Hello &amp; <b>Swift</b></p>".decodedHTML()

        #expect(decoded == "Hello & Swift")
    }

    @Test func newsCategorizerはキーワードからカテゴリを判定する() {
        let categorizer = NewsCategorizer()

        let technology = categorizer.categorize(title: "Apple releases new Swift tools", summary: "")
        let business = categorizer.categorize(title: "Market earnings jump", summary: "")
        let other = categorizer.categorize(title: "Completely unrelated", summary: "No keyword here")

        #expect(technology == .technology)
        #expect(business == .business)
        #expect(other == .other)
    }

    @Test func rssParserはrss形式を解析できる() throws {
        let parser = RSSParser()
        let xml = """
        <rss version="2.0">
          <channel>
            <title>Example Feed</title>
            <item>
              <title>First Item</title>
              <link>https://example.com/items/1</link>
              <description><![CDATA[<p>Hello &amp; Swift</p>]]></description>
              <pubDate>Tue, 02 Apr 2024 12:34:56 +0900</pubDate>
            </item>
          </channel>
        </rss>
        """

        let feed = try parser.parse(data: Data(xml.utf8))

        #expect(feed.title == "Example Feed")
        #expect(feed.items.count == 1)
        #expect(feed.items[0].title == "First Item")
        #expect(feed.items[0].summary == "Hello & Swift")
        #expect(feed.items[0].link == "https://example.com/items/1")
    }

    @Test func rssParserはatom形式を解析できる() throws {
        let parser = RSSParser()
        let xml = """
        <feed xmlns="http://www.w3.org/2005/Atom">
          <title>Atom Feed</title>
          <entry>
            <title>Atom Item</title>
            <link href="https://example.com/atom/1" />
            <summary>Atom Summary</summary>
            <updated>2024-04-02T03:34:56Z</updated>
          </entry>
        </feed>
        """

        let feed = try parser.parse(data: Data(xml.utf8))

        #expect(feed.title == "Atom Feed")
        #expect(feed.items.count == 1)
        #expect(feed.items[0].link == "https://example.com/atom/1")
        #expect(feed.items[0].summary == "Atom Summary")
    }

    @Test func rssParserは不正なxmlでparsingFailedを返す() {
        let parser = RSSParser()

        do {
            _ = try parser.parse(data: Data("<rss>".utf8))
            Issue.record("Expected parsing to fail")
        } catch let error as RSSServiceError {
            #expect(error == .parsingFailed)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
