//
//  NewsCategory.swift
//  RSSNews
//

import Foundation

enum NewsCategory: String, CaseIterable, Codable, Identifiable {
    case all = "すべて"
    case technology = "テクノロジー"
    case business = "ビジネス"
    case world = "国際"
    case sports = "スポーツ"
    case culture = "カルチャー"
    case other = "その他"

    var id: String { rawValue }
}
