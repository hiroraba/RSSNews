//
//  ParsedRSSItem.swift
//  RSSNews
//

import Foundation

struct ParsedRSSFeed {
    let title: String
    let items: [ParsedRSSItem]
}

struct ParsedRSSItem: Identifiable {
    let id = UUID()
    let title: String
    let link: String
    let summary: String
    let publishedAt: Date
}
