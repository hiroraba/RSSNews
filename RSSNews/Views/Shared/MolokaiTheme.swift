//
//  MolokaiTheme.swift
//  RSSNews
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case molokai
    case light
    case darkNeutral

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system:
            return "システム"
        case .molokai:
            return "Molokai"
        case .light:
            return "ライト"
        case .darkNeutral:
            return "ダーク"
        }
    }

    func palette(for colorScheme: ColorScheme) -> AppThemePalette {
        switch self {
        case .system:
            return colorScheme == .light ? .light : .darkNeutral
        case .molokai:
            return .molokai
        case .light:
            return .light
        case .darkNeutral:
            return .darkNeutral
        }
    }
}

struct AppThemePalette: Equatable {
    let background: Color
    let surface: Color
    let elevated: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let success: Color
    let warning: Color
    let text: Color
    let textMuted: Color
    let borderStrong: Color

    static let molokai = AppThemePalette(
        background: Color(red: 0.08, green: 0.09, blue: 0.11),
        surface: Color(red: 0.13, green: 0.15, blue: 0.17),
        elevated: Color(red: 0.18, green: 0.20, blue: 0.23),
        primary: Color(red: 0.65, green: 0.89, blue: 0.18),
        secondary: Color(red: 0.90, green: 0.86, blue: 0.45),
        accent: Color(red: 0.98, green: 0.59, blue: 0.12),
        success: Color(red: 0.54, green: 0.78, blue: 0.26),
        warning: Color(red: 0.99, green: 0.74, blue: 0.26),
        text: Color(red: 0.97, green: 0.97, blue: 0.95),
        textMuted: Color(red: 0.79, green: 0.82, blue: 0.79),
        borderStrong: Color.white.opacity(0.18)
    )

    static let light = AppThemePalette(
        background: Color(red: 0.95, green: 0.96, blue: 0.98),
        surface: Color(red: 0.99, green: 0.99, blue: 1.00),
        elevated: Color(red: 0.91, green: 0.93, blue: 0.96),
        primary: Color(red: 0.34, green: 0.60, blue: 0.13),
        secondary: Color(red: 0.67, green: 0.54, blue: 0.18),
        accent: Color(red: 0.84, green: 0.39, blue: 0.00),
        success: Color(red: 0.29, green: 0.58, blue: 0.24),
        warning: Color(red: 0.82, green: 0.55, blue: 0.10),
        text: Color(red: 0.10, green: 0.12, blue: 0.15),
        textMuted: Color(red: 0.37, green: 0.42, blue: 0.47),
        borderStrong: Color.black.opacity(0.10)
    )

    static let darkNeutral = AppThemePalette(
        background: Color(red: 0.10, green: 0.11, blue: 0.13),
        surface: Color(red: 0.15, green: 0.16, blue: 0.19),
        elevated: Color(red: 0.20, green: 0.22, blue: 0.26),
        primary: Color(red: 0.42, green: 0.71, blue: 0.88),
        secondary: Color(red: 0.62, green: 0.75, blue: 0.82),
        accent: Color(red: 0.91, green: 0.54, blue: 0.32),
        success: Color(red: 0.40, green: 0.72, blue: 0.50),
        warning: Color(red: 0.94, green: 0.69, blue: 0.28),
        text: Color(red: 0.94, green: 0.95, blue: 0.97),
        textMuted: Color(red: 0.69, green: 0.72, blue: 0.76),
        borderStrong: Color.white.opacity(0.14)
    )
}

enum MolokaiTheme {
    private static var currentPalette = AppThemePalette.darkNeutral

    static func setCurrentPalette(_ palette: AppThemePalette) {
        currentPalette = palette
    }

    static var background: Color { currentPalette.background }
    static var surface: Color { currentPalette.surface }
    static var elevated: Color { currentPalette.elevated }
    static var primary: Color { currentPalette.primary }
    static var secondary: Color { currentPalette.secondary }
    static var accent: Color { currentPalette.accent }
    static var success: Color { currentPalette.success }
    static var warning: Color { currentPalette.warning }
    static var text: Color { currentPalette.text }
    static var textMuted: Color { currentPalette.textMuted }
    static var borderStrong: Color { currentPalette.borderStrong }

    static let pagePadding: CGFloat = 24
    static let cardPadding: CGFloat = 24
    static let controlMinHeight: CGFloat = 44

    static var chromeGradient: LinearGradient {
        LinearGradient(
            colors: [
                background,
                surface,
                elevated
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var spotlightGradient: RadialGradient {
        RadialGradient(
            colors: [
                primary.opacity(0.15),
                accent.opacity(0.08),
                .clear
            ],
            center: .topTrailing,
            startRadius: 40,
            endRadius: 420
        )
    }
}

struct MolokaiCanvas<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            MolokaiTheme.chromeGradient
                .ignoresSafeArea()

            MolokaiTheme.spotlightGradient
                .ignoresSafeArea()

            Circle()
                .fill(MolokaiTheme.success.opacity(0.08))
                .frame(width: 360, height: 360)
                .blur(radius: 20)
                .offset(x: -360, y: 260)

            content
        }
    }
}

struct MolokaiGlassCard: ViewModifier {
    var tint: Color = MolokaiTheme.text.opacity(0.06)
    var stroke: Color = MolokaiTheme.text.opacity(0.12)

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(MolokaiTheme.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(tint)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(stroke, lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .shadow(color: .black.opacity(0.16), radius: 16, x: 0, y: 10)
    }
}

struct MolokaiChromeButtonStyle: ButtonStyle {
    var tint: Color = MolokaiTheme.secondary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .semibold))
            .multilineTextAlignment(.center)
            .foregroundStyle(MolokaiTheme.text)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(minHeight: MolokaiTheme.controlMinHeight)
            .background {
                Capsule(style: .continuous)
                    .fill(MolokaiTheme.elevated)
            }
            .overlay {
                Capsule(style: .continuous)
                    .fill(tint.opacity(configuration.isPressed ? 0.20 : 0.12))
                    .allowsHitTesting(false)
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(tint.opacity(0.45), lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .shadow(color: .black.opacity(configuration.isPressed ? 0.10 : 0.16), radius: 10, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct MolokaiInputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: MolokaiTheme.controlMinHeight)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(MolokaiTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(MolokaiTheme.borderStrong, lineWidth: 1)
                    )
            )
            .foregroundStyle(MolokaiTheme.text)
    }
}

extension View {
    func molokaiGlassCard(
        tint: Color = MolokaiTheme.text.opacity(0.06),
        stroke: Color = MolokaiTheme.text.opacity(0.12)
    ) -> some View {
        modifier(MolokaiGlassCard(tint: tint, stroke: stroke))
    }

    func molokaiInputField() -> some View {
        modifier(MolokaiInputFieldStyle())
    }
}
