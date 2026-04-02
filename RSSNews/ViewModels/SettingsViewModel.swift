//
//  SettingsViewModel.swift
//  RSSNews
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    private let userDefaults: UserDefaults

    @Published var autoRefreshOnLaunch: Bool {
        didSet { userDefaults.set(autoRefreshOnLaunch, forKey: Self.autoRefreshKey) }
    }

    @Published var markAsReadOnOpen: Bool {
        didSet { userDefaults.set(markAsReadOnOpen, forKey: Self.markAsReadOnOpenKey) }
    }

    static let autoRefreshKey = "settings.autoRefreshOnLaunch"
    static let markAsReadOnOpenKey = "settings.markAsReadOnOpen"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        autoRefreshOnLaunch = userDefaults.object(forKey: Self.autoRefreshKey) as? Bool ?? true
        markAsReadOnOpen = userDefaults.object(forKey: Self.markAsReadOnOpenKey) as? Bool ?? true
    }
}
