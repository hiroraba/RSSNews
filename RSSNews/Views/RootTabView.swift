//
//  RootTabView.swift
//  RSSNews
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var articleViewModel: ArticleListViewModel?
    @State private var feedViewModel: FeedManagementViewModel?
    @State private var settingsViewModel = SettingsViewModel()

    var body: some View {
        Group {
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
            } else {
                ProgressView()
                    .task {
                        let environment = AppEnvironment(modelContext: modelContext)
                        let articleVM = ArticleListViewModel(environment: environment)
                        let feedVM = FeedManagementViewModel(environment: environment)
                        articleViewModel = articleVM
                        feedViewModel = feedVM
                        feedVM.loadFeeds()
                        articleVM.loadArticles()
                        if settingsViewModel.autoRefreshOnLaunch {
                            await articleVM.refreshAllFeeds()
                            feedVM.loadFeeds()
                        }
                    }
            }
        }
    }
}
