import SwiftUI

enum AppTheme {
    // MARK: - Core Palette
    static let accent = Color(red: 0.38, green: 0.36, blue: 1.0)        // Indigo-violet
    static let accentLight = Color(red: 0.56, green: 0.54, blue: 1.0)
    static let accentDark = Color(red: 0.24, green: 0.22, blue: 0.8)

    static let surface = Color(red: 0.96, green: 0.96, blue: 0.98)      // Cool off-white
    static let cardBackground = Color.white
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.14)
    static let textSecondary = Color(red: 0.44, green: 0.44, blue: 0.52)

    static let gold = Color(red: 1.0, green: 0.78, blue: 0.18)
    static let success = Color(red: 0.2, green: 0.78, blue: 0.55)
    static let coinColor = Color(red: 0.98, green: 0.72, blue: 0.15)

    // MARK: - World Theme Colors
    static let gardenGreen = Color(red: 0.22, green: 0.78, blue: 0.55)
    static let houseWarm = Color(red: 0.96, green: 0.58, blue: 0.36)
    static let cityBlue = Color(red: 0.3, green: 0.56, blue: 0.98)
    static let forestPurple = Color(red: 0.6, green: 0.36, blue: 0.9)
    static let bonusPink = Color(red: 0.96, green: 0.38, blue: 0.62)

    // MARK: - Gradients
    static let heroGradient = LinearGradient(
        colors: [accent, Color(red: 0.5, green: 0.3, blue: 0.9)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let premiumGradient = LinearGradient(
        colors: [Color(red: 0.96, green: 0.72, blue: 0.15), Color(red: 0.98, green: 0.5, blue: 0.2)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static func worldGradient(for theme: WorldTheme) -> LinearGradient {
        let color = worldColor(for: theme)
        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    static func worldColor(for theme: WorldTheme) -> Color {
        switch theme {
        case .garden: return gardenGreen
        case .house: return houseWarm
        case .city: return cityBlue
        case .enchanted: return forestPurple
        case .bonus: return bonusPink
        }
    }

    // MARK: - World SF Symbol Icons
    static func worldIcon(for theme: WorldTheme) -> String {
        switch theme {
        case .garden: return "leaf.fill"
        case .house: return "house.fill"
        case .city: return "building.2.fill"
        case .enchanted: return "moon.stars.fill"
        case .bonus: return "sparkles"
        }
    }

    // MARK: - Card Styles
    static let cardRadius: CGFloat = 18
    static let cardShadow: Color = .black.opacity(0.06)
    static let cardShadowRadius: CGFloat = 8
}

// MARK: - Reusable View Modifiers

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                    .fill(.ultraThinMaterial)
                    .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, y: 4)
            )
    }
}

struct SolidCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, y: 4)
            )
    }
}

struct AccentButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.heroGradient)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

extension View {
    func glassCard() -> some View { modifier(GlassCard()) }
    func solidCard() -> some View { modifier(SolidCard()) }
    func accentButton() -> some View { modifier(AccentButton()) }
}
