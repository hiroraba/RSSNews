//
//  FeedRepository.swift
//  RSSNews
//

import Foundation
import SwiftData

@MainActor
final class FeedRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchFeeds() throws -> [RSSFeed] {
        let descriptor = FetchDescriptor<RSSFeed>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        return try modelContext.fetch(descriptor)
    }

    func fetchEnabledFeeds() throws -> [RSSFeed] {
        let descriptor = FetchDescriptor<RSSFeed>(
            predicate: #Predicate { $0.isActive == true },
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func addFeed(urlString: String, title: String) throws -> RSSFeed {
        let normalized = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { throw RSSServiceError.emptyFeedURL }

        let existing = try feed(with: normalized)
        if existing != nil {
            throw RSSServiceError.duplicateFeed
        }

        let feed = RSSFeed(url: normalized, title: title)
        modelContext.insert(feed)
        try modelContext.save()
        return feed
    }

    func deleteFeed(_ feed: RSSFeed) throws {
        modelContext.delete(feed)
        try modelContext.save()
    }

    func updateFetchedDate(for feed: RSSFeed) throws {
        feed.lastFetchedAt = .now
        try modelContext.save()
    }

    func updateEnabledState(for feed: RSSFeed, isEnabled: Bool) throws {
        feed.isEnabled = isEnabled
        try modelContext.save()
    }

    func feed(with urlString: String) throws -> RSSFeed? {
        let normalized = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        var descriptor = FetchDescriptor<RSSFeed>(
            predicate: #Predicate { $0.url == normalized }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
