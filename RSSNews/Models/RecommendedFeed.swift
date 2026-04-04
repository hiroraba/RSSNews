//
//  RecommendedFeed.swift
//  RSSNews
//

import Foundation

struct RecommendedFeed: Identifiable, Equatable {
    let title: String
    let url: String
    let categoryLabel: String
    let summary: String
    let symbolName: String

    var id: String { url }

    static let catalog: [RecommendedFeed] = [
        RecommendedFeed(
            title: "Publickey",
            url: "https://www.publickey1.jp/atom.xml",
            categoryLabel: "開発・クラウド",
            summary: "国内のエンタープライズIT、クラウド、Web技術の動きを追いやすい定番フィードです。",
            symbolName: "server.rack"
        ),
        RecommendedFeed(
            title: "GIGAZINE",
            url: "https://gigazine.net/news/rss_2.0/",
            categoryLabel: "テクノロジー",
            summary: "テック、プロダクト、ネット話題を広めに拾いたいときに向いています。",
            symbolName: "bolt.circle"
        ),
        RecommendedFeed(
            title: "ASCII.jp",
            url: "https://www.ascii.jp/cate/1/rss.xml",
            categoryLabel: "ITニュース",
            summary: "国内 IT の新製品、業界動向、開発トピックをまとめて確認できます。",
            symbolName: "dot.radiowaves.left.and.right"
        )
    ]
}
