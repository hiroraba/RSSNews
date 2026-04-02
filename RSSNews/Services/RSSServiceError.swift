//
//  RSSServiceError.swift
//  RSSNews
//

import Foundation

enum RSSServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case parsingFailed
    case duplicateFeed
    case emptyFeedURL

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "RSS URLが不正です。"
        case .invalidResponse:
            return "RSSの取得に失敗しました。"
        case .parsingFailed:
            return "RSSの解析に失敗しました。"
        case .duplicateFeed:
            return "同じRSSフィードはすでに登録されています。"
        case .emptyFeedURL:
            return "RSS URLを入力してください。"
        }
    }
}
