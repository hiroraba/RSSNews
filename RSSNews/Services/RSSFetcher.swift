//
//  RSSFetcher.swift
//  RSSNews
//

import Foundation

protocol RSSFetching {
    func fetch(from url: URL) async throws -> Data
}

struct RSSFetcher: RSSFetching {
    func fetch(from url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("RSSNews/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw RSSServiceError.invalidResponse
        }
        return data
    }
}
