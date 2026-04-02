//
//  ContentView.swift
//  RSSNews
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        RootTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [RSSFeed.self, Article.self], inMemory: true)
}
