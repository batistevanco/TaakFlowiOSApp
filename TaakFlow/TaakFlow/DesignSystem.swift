// DesignSystem.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

// MARK: - Adaptive color helper

private func adaptive(light: String, dark: String) -> Color {
    Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
        ? UIColor(hex: dark)
        : UIColor(hex: light)
    })
}

// MARK: - Colors

extension Color {
    // Primary accent (same in both modes)
    static let tfAccent       = Color(hex: "#5B6EF5")
    static let tfAccent2      = Color(hex: "#7C3AED")

    // Priority (same in both modes)
    static let tfPriorityHigh = Color(hex: "#EF4444")
    static let tfPriorityMed  = Color(hex: "#F97316")
    static let tfPriorityLow  = Color(hex: "#22C55E")
    static let tfPriorityNone = Color(hex: "#D1D5DB")

    // Backgrounds — adaptive
    static let tfBgPrimary    = adaptive(light: "#F5F6FA", dark: "#1C1C1E")
    static let tfBgCard       = adaptive(light: "#FFFFFF", dark: "#2C2C2E")
    static let tfBgSubtle     = adaptive(light: "#F0F0F5", dark: "#3A3A3C")

    // Text — adaptive
    static let tfTextPrimary   = adaptive(light: "#111827", dark: "#F2F2F7")
    static let tfTextSecondary = adaptive(light: "#9CA3AF", dark: "#8E8E93")
    static let tfTextOnAccent  = Color.white

    // Borders — adaptive
    static let tfBorderLight   = adaptive(light: "#F0F0F5", dark: "#3A3A3C")
    static let tfBorderMedium  = adaptive(light: "#E5E7EB", dark: "#48484A")

    // Tag colors
    static let tagIndigo  = Color(hex: "#5B6EF5")
    static let tagPurple  = Color(hex: "#7C3AED")
    static let tagRed     = Color(hex: "#EF4444")
    static let tagOrange  = Color(hex: "#F97316")
    static let tagGreen   = Color(hex: "#22C55E")
    static let tagBlue    = Color(hex: "#0EA5E9")
    static let tagPink    = Color(hex: "#EC4899")
    static let tagYellow  = Color(hex: "#EAB308")

    static let tfTagColors: [Color] = [
        .tagIndigo, .tagPurple, .tagRed, .tagOrange,
        .tagGreen, .tagBlue, .tagPink, .tagYellow
    ]
    static let tfTagHexColors: [String] = [
        "#5B6EF5", "#7C3AED", "#EF4444", "#F97316",
        "#22C55E", "#0EA5E9", "#EC4899", "#EAB308"
    ]
}

// MARK: - Gradients

extension LinearGradient {
    static let tfHero = LinearGradient(
        colors: [.tfAccent, .tfAccent2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let tfButton = LinearGradient(
        colors: [.tfAccent, .tfAccent2],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Spacing

enum TFSpacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - Corner Radii

enum TFRadius {
    static let tag:      CGFloat = 99
    static let input:    CGFloat = 12
    static let card:     CGFloat = 18
    static let cardLg:   CGFloat = 22
    static let sheet:    CGFloat = 28
    static let projectIcon: CGFloat = 14
}

// MARK: - Shadows

extension View {
    func cardShadow() -> some View {
        self.shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 2)
    }
    func elevatedCardShadow() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 4)
    }
    func heroGlowShadow() -> some View {
        self.shadow(color: Color.tfAccent.opacity(0.30), radius: 32, x: 0, y: 12)
    }
    func fabGlowShadow() -> some View {
        self.shadow(color: Color.tfAccent.opacity(0.40), radius: 24, x: 0, y: 8)
    }
    func accentGlowShadow() -> some View {
        self.shadow(color: Color.tfAccent.opacity(0.20), radius: 8, x: 0, y: 0)
    }
    func buttonGlowShadow(color: Color) -> some View {
        self.shadow(color: color.opacity(0.35), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Typography helpers

extension Font {
    static func tfLargeTitle() -> Font {
        .system(size: 34, weight: .heavy, design: .default)
    }
    static func tfTitle2() -> Font {
        .system(size: 22, weight: .bold, design: .default)
    }
    static func tfHeadline() -> Font {
        .system(size: 17, weight: .bold, design: .default)
    }
    static func tfSubheadline() -> Font {
        .system(size: 15, weight: .semibold, design: .default)
    }
    static func tfCaption() -> Font {
        .system(size: 11, weight: .bold, design: .default)
    }
    static func tfCaption2() -> Font {
        .system(size: 10, weight: .semibold, design: .default)
    }
    static func tfBody() -> Font {
        .system(size: 14, weight: .semibold, design: .default)
    }
}

// MARK: - Emoji helpers for Projects

let kProjectEmojis: [String] = [
    "💼", "🗂️", "🚀", "🎯", "💡", "📱", "🌐", "🎨",
    "📊", "🔧", "📝", "🏠", "🎓", "💰", "🌱", "⚡",
    "🔬", "🎵", "🏃", "🤝", "📸", "🍕", "✈️", "🌟"
]
