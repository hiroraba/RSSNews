//
//  RSSFeed.swift
//  RSSNews
//

import Foundation
import SwiftData

@Model
final class RSSFeed {
    @Attribute(.unique) var url: String
    var title: String
    var createdAt: Date
    var lastFetchedAt: Date?
    var isActive: Bool
    var isEnabled: Bool {
        get { isActive }
        set { isActive = newValue }
    }

    init(
        url: String,
        title: String,
        createdAt: Date = .now,
        lastFetchedAt: Date? = nil,
        isActive: Bool = true
    ) {
        self.url = url
        self.title = title
        self.createdAt = createdAt
        self.lastFetchedAt = lastFetchedAt
        self.isActive = isActive
    }
}
