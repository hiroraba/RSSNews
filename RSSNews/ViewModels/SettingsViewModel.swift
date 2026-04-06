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

    @Published var selectedTheme: AppTheme {
        didSet { userDefaults.set(selectedTheme.rawValue, forKey: Self.selectedThemeKey) }
    }

    static let autoRefreshKey = "settings.autoRefreshOnLaunch"
    static let markAsReadOnOpenKey = "settings.markAsReadOnOpen"
    static let selectedThemeKey = "settings.selectedTheme"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        autoRefreshOnLaunch = userDefaults.object(forKey: Self.autoRefreshKey) as? Bool ?? true
        markAsReadOnOpen = userDefaults.object(forKey: Self.markAsReadOnOpenKey) as? Bool ?? true
        selectedTheme = AppTheme(rawValue: userDefaults.string(forKey: Self.selectedThemeKey) ?? "") ?? .system
    }
}
