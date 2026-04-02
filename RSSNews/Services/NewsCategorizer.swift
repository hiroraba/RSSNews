//
//  NewsCategorizer.swift
//  RSSNews
//

import Foundation

protocol NewsCategorizing {
    func categorize(title: String, summary: String) -> NewsCategory
}

struct NewsCategorizer: NewsCategorizing {
    private let keywordMap: [(NewsCategory, [String])] = [
        (.technology, [
            "ai", "apple", "google", "microsoft", "software", "ios", "swift", "tech", "startup",
            "テクノロジー", "技術", "生成ai", "人工知能", "半導体", "スマホ", "アプリ", "ソフトウェア", "ハードウェア",
            "クラウド", "デジタル", "it", "web", "ネット", "通信", "端末"
        ]),
        (.business, [
            "market", "stock", "finance", "earnings", "business", "economy", "investment",
            "ビジネス", "経済", "株", "株価", "市場", "決算", "金融", "投資", "円安", "円高", "企業", "業績",
            "物価", "景気", "為替", "日経", "売上"
        ]),
        (.world, [
            "election", "war", "government", "politics", "international", "global", "diplomacy",
            "国際", "海外", "世界", "外交", "戦争", "紛争", "停戦", "政権", "政府", "大統領", "首相", "選挙",
            "議会", "ロシア", "ウクライナ", "中国", "台湾", "米国", "アメリカ", "欧州", "中東"
        ]),
        (.sports, [
            "football", "soccer", "baseball", "basketball", "tennis", "olympic", "sports",
            "スポーツ", "野球", "サッカー", "バスケ", "バスケットボール", "テニス", "ゴルフ", "相撲", "五輪",
            "オリンピック", "試合", "勝利", "敗戦", "得点", "選手", "監督"
        ]),
        (.culture, [
            "movie", "music", "art", "anime", "book", "culture", "entertainment",
            "カルチャー", "文化", "映画", "音楽", "アート", "アニメ", "漫画", "まんが", "小説", "本", "舞台",
            "ドラマ", "芸能", "エンタメ", "作品", "展覧会"
        ])
    ]

    func categorize(title: String, summary: String) -> NewsCategory {
        let text = "\(title) \(summary)".lowercased()
        for (category, keywords) in keywordMap where keywords.contains(where: { text.contains($0) }) {
            return category
        }
        return .other
    }
}
