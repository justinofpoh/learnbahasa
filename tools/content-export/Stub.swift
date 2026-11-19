import SwiftUI

// The app's Theme imports UIKit; the exporter only needs the colour names.
extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255, opacity: 1)
    }
}

enum Theme {
    static let paper = Color(hex: 0xF6F1E8), card = Color(hex: 0xFFFCF6), ink = Color(hex: 0x1D1A16)
    static let inkSoft = Color(hex: 0x6B645A), line = Color(hex: 0xE6DDCD)
    static let sambal = Color(hex: 0xD4512A), indigo = Color(hex: 0x2F3E6B), kunyit = Color(hex: 0xE3A126)
    static let sawah = Color(hex: 0x2E7D5B), jambu = Color(hex: 0xB7385E), laut = Color(hex: 0x1F7A8C)
    static let kopi = Color(hex: 0x6F4E37), benar = Color(hex: 0x2E7D5B), salah = Color(hex: 0xC0392B)
}

enum Accent: String, Codable, CaseIterable {
    case sambal, indigo, kunyit, sawah, jambu, laut, kopi
    var color: Color { Theme.sambal }
}

/// Mirrors `Access` in PurchaseManager.swift (free on the web = free in the app).
enum Access {
    static let freeSceneIDs: Set<String> = ["id.warung.lunch", "id.jalan.ojek"]
    static let freeUnitNumbers: Set<Int> = [1, 2]
}
