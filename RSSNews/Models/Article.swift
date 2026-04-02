//
//  Article.swift
//  RSSNews
//

import Foundation
import SwiftData

@Model
final class Article {
    @Attribute(.unique) var link: String
    var title: String
    var sourceName: String
    var publishedAt: Date
    var summary: String
    var categoryRawValue: String
    var isRead: Bool
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    var feed: RSSFeed?

    init(
        link: String,
        title: String,
        sourceName: String,
        publishedAt: Date,
        summary: String,
        category: NewsCategory,
        isRead: Bool = false,
        isFavorite: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        feed: RSSFeed? = nil
    ) {
        self.link = link
        self.title = title
        self.sourceName = sourceName
        self.publishedAt = publishedAt
        self.summary = summary
        self.categoryRawValue = category.rawValue
        self.isRead = isRead
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.feed = feed
    }

    var category: NewsCategory {
        get { NewsCategory(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }
}
