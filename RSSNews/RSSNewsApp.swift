//
//  RSSNewsApp.swift
//  RSSNews
//  
//  Created by matsuohiroki on 2026/04/02.
//  
//

import SwiftUI
import SwiftData
import TipKit

@main
struct RSSNewsApp: App {
    init() {
        do {
            try Tips.configure()
        } catch {
            assertionFailure("TipKit initialization failed: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [RSSFeed.self, Article.self])
    }
}
