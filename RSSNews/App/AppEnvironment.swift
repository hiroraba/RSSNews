//
//  AppEnvironment.swift
//  RSSNews
//

import Foundation
import SwiftData

struct AppEnvironment {
    let rssFetcher: RSSFetching
    let rssParser: RSSParsing
    let categorizer: NewsCategorizing
    let feedRepository: FeedRepository
    let articleRepository: ArticleRepository

    init(modelContext: ModelContext) {
        rssFetcher = RSSFetcher()
        rssParser = RSSParser()
        categorizer = NewsCategorizer()
        feedRepository = FeedRepository(modelContext: modelContext)
        articleRepository = ArticleRepository(modelContext: modelContext, categorizer: categorizer)
    }
}
