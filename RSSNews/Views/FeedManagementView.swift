//
//  FeedManagementView.swift
//  RSSNews
//

import SwiftUI

struct FeedManagementView: View {
    @ObservedObject var viewModel: FeedManagementViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RSS登録")
                .font(.title2)
                .fontWeight(.semibold)

            HStack {
                TextField("https://example.com/feed.xml", text: $viewModel.newFeedURL)
                    .textFieldStyle(.roundedBorder)
                Button("登録") {
                    Task { await viewModel.addFeed() }
                }
                .disabled(viewModel.isLoading)
            }

            if viewModel.isLoading {
                ProgressView("フィード確認中...")
            }

            List {
                ForEach(viewModel.feeds) { feed in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(feed.title)
                            .font(.headline)
                        Text(feed.url)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let lastFetchedAt = feed.lastFetchedAt {
                            Text("最終取得: \(lastFetchedAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: viewModel.removeFeeds)
            }
            .overlay {
                if viewModel.feeds.isEmpty {
                    ContentUnavailableView(
                        "RSS未登録",
                        systemImage: "dot.radiowaves.left.and.right",
                        description: Text("RSS URLを追加すると一覧に表示されます。")
                    )
                }
            }
        }
        .padding()
        .navigationTitle("RSS管理")
        .onAppear {
            viewModel.loadFeeds()
        }
        .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }
}
