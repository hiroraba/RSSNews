//
//  FeedManagementView.swift
//  RSSNews
//

import SwiftUI

struct FeedManagementView: View {
    @ObservedObject var viewModel: FeedManagementViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("RSS管理")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(MolokaiTheme.text)
                Text("RSS フィードの追加、確認、削除を行います。")
                    .foregroundStyle(MolokaiTheme.textMuted)
            }

            HStack(spacing: 12) {
                TextField("https://example.com/feed.xml", text: $viewModel.newFeedURL)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(MolokaiTheme.surface.opacity(0.70))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(MolokaiTheme.text.opacity(0.08), lineWidth: 1)
                            )
                    )
                    .foregroundStyle(MolokaiTheme.text)

                Button("登録") {
                    Task { await viewModel.addFeed() }
                }
                .buttonStyle(MolokaiChromeButtonStyle(tint: MolokaiTheme.primary))
                .disabled(viewModel.isLoading)
            }

            if viewModel.isLoading {
                Label("フィード確認中...", systemImage: "rays")
                    .foregroundStyle(MolokaiTheme.warning)
            }

            List {
                ForEach(viewModel.feeds) { feed in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(feed.title)
                                .font(.system(.headline, design: .rounded, weight: .semibold))
                                .foregroundStyle(MolokaiTheme.text)
                            Spacer()
                            Text(feed.isEnabled ? "有効" : "停止中")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(feed.isEnabled ? MolokaiTheme.success : MolokaiTheme.warning)
                        }

                        Text(feed.url)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(MolokaiTheme.textMuted)

                        if let lastFetchedAt = feed.lastFetchedAt {
                            Text("最終取得: \(lastFetchedAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(MolokaiTheme.secondary)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(MolokaiTheme.surface.opacity(0.56))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(MolokaiTheme.text.opacity(0.05), lineWidth: 1)
                            )
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 6)
                }
                .onDelete(perform: viewModel.removeFeeds)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .overlay {
                if viewModel.feeds.isEmpty {
                    ContentUnavailableView(
                        "RSS未登録",
                        systemImage: "dot.radiowaves.left.and.right",
                        description: Text("RSS URLを追加すると一覧に表示されます。")
                    )
                    .foregroundStyle(MolokaiTheme.text)
                }
            }
            .molokaiGlassCard(
                tint: MolokaiTheme.text.opacity(0.05),
                stroke: MolokaiTheme.text.opacity(0.10)
            )
        }
        .padding(20)
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
