//
//  RootTabView.swift
//  RSSNews
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var articleViewModel: ArticleListViewModel?
    @State private var feedViewModel: FeedManagementViewModel?
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some View {
        let palette = settingsViewModel.selectedTheme.palette(for: colorScheme)
        let _ = MolokaiTheme.setCurrentPalette(palette)

        MolokaiCanvas {
            if let articleViewModel, let feedViewModel {
                TabView {
                    ArticleListView(viewModel: articleViewModel)
                        .tabItem {
                            Label("記事", systemImage: "newspaper")
                        }

                    FeedManagementView(viewModel: feedViewModel)
                        .tabItem {
                            Label("RSS管理", systemImage: "dot.radiowaves.left.and.right")
                        }

                    SettingsView(
                        viewModel: settingsViewModel,
                        articleViewModel: articleViewModel,
                        feedViewModel: feedViewModel
                    )
                        .tabItem {
                            Label("設定", systemImage: "gearshape")
                        }
                }
                .frame(minWidth: 980, minHeight: 640)
                .tint(MolokaiTheme.secondary)
            } else {
                ProgressView()
                    .tint(MolokaiTheme.secondary)
                    .task {
                        let environment = AppEnvironment(modelContext: modelContext)
                        let articleVM = ArticleListViewModel(environment: environment)
                        let feedVM = FeedManagementViewModel(environment: environment)
                        articleViewModel = articleVM
                        feedViewModel = feedVM
                        feedVM.loadFeeds()
                        articleVM.loadArticles()
                        if settingsViewModel.autoRefreshOnLaunch {
                            await articleVM.refreshAllFeeds(reportErrors: false)
                            feedVM.loadFeeds()
                        }
                    }
            }
        }
    }
}
