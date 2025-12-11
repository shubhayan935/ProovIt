//
//  Theme.swift
//  SrivastavaShubhayanFinal
//
//  Design System - Colors
//

import SwiftUI

struct AppColors {
    static let primaryGreen = Color(hex: "#3C6E47")
    static let sageGreen = Color(hex: "#A7C4A0")
    static let sand = Color(hex: "#D2B47C")
    static let beige = Color(hex: "#F4EEDC")

    static let textDark = Color(hex: "#2C2C28")
    static let textMedium = Color(hex: "#6A6A5B")
    static let cardWhite = Color(hex: "#FAFAFA")
    static let background = beige
}

// Hex initializer
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
