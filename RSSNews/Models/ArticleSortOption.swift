//
//  ArticleSortOption.swift
//  RSSNews
//

import Foundation

enum ArticleSortOption: String, CaseIterable, Identifiable {
    case newestFirst = "新しい順"
    case oldestFirst = "古い順"
    case unreadFirst = "未読優先"
    case favoritesFirst = "お気に入り優先"

    var id: String { rawValue }
}
