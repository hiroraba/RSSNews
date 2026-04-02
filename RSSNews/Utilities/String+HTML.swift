//
//  String+HTML.swift
//  RSSNews
//

import Foundation

extension String {
    func decodedHTML() -> String {
        let withoutTags = replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        let normalizedWhitespace = withoutTags.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return normalizedWhitespace
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
