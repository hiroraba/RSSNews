//
//  RSSNewsApp.swift
//  RSSNews
//  
//  Created by matsuohiroki on 2026/04/02.
//  
//

import SwiftUI
import SwiftData

@main
struct RSSNewsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [RSSFeed.self, Article.self])
    }
}
