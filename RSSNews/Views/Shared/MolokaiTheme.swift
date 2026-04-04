//
//  MolokaiTheme.swift
//  RSSNews
//

import SwiftUI

enum MolokaiTheme {
    static let background = Color(red: 0.08, green: 0.09, blue: 0.11)
    static let surface = Color(red: 0.13, green: 0.15, blue: 0.17)
    static let elevated = Color(red: 0.18, green: 0.20, blue: 0.23)
    static let primary = Color(red: 0.65, green: 0.89, blue: 0.18)
    static let secondary = Color(red: 0.90, green: 0.86, blue: 0.45)
    static let accent = Color(red: 0.98, green: 0.59, blue: 0.12)
    static let success = Color(red: 0.54, green: 0.78, blue: 0.26)
    static let warning = Color(red: 0.99, green: 0.74, blue: 0.26)
    static let text = Color(red: 0.97, green: 0.97, blue: 0.95)
    static let textMuted = Color(red: 0.79, green: 0.82, blue: 0.79)
    static let borderStrong = Color.white.opacity(0.18)

    static let pagePadding: CGFloat = 24
    static let cardPadding: CGFloat = 24
    static let controlMinHeight: CGFloat = 44

    static let chromeGradient = LinearGradient(
        colors: [
            background,
            Color(red: 0.11, green: 0.12, blue: 0.15),
            Color(red: 0.07, green: 0.08, blue: 0.10)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let spotlightGradient = RadialGradient(
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
