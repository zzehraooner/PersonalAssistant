import SwiftUI

struct AppTheme {
    static let primaryColor = Color("PrimaryColor") // Define in Assets
    static let secondaryColor = Color("SecondaryColor")
    static let backgroundColor = Color("BackgroundColor")
    
    // Fallback colors for preview/development without Assets
    static let fallbackPrimary = Color(hex: "6C63FF") // Modern Purple
    static let fallbackSecondary = Color(hex: "FF6584") // Soft Red/Pink
    static let fallbackBackground = Color(hex: "F8F9FD") // Off-white
    static let darkBackground = Color(hex: "1A1B26") // Deep Blue/Black
    
    static let gradientMain = LinearGradient(
        colors: [fallbackPrimary, fallbackSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
