//
//  SettingsViewModel.swift
//  RSSNews
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var autoRefreshOnLaunch: Bool {
        didSet { UserDefaults.standard.set(autoRefreshOnLaunch, forKey: Self.autoRefreshKey) }
    }

    @Published var markAsReadOnOpen: Bool {
        didSet { UserDefaults.standard.set(markAsReadOnOpen, forKey: Self.markAsReadOnOpenKey) }
    }

    static let autoRefreshKey = "settings.autoRefreshOnLaunch"
    static let markAsReadOnOpenKey = "settings.markAsReadOnOpen"

    init() {
        autoRefreshOnLaunch = UserDefaults.standard.object(forKey: Self.autoRefreshKey) as? Bool ?? true
        markAsReadOnOpen = UserDefaults.standard.object(forKey: Self.markAsReadOnOpenKey) as? Bool ?? true
    }
}
