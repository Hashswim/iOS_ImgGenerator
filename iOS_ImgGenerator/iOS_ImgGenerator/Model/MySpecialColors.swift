
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

enum MySpecialColors {
    //hex code
    static let backgroundIndigo  = Color(hex: "#2B2F3B")
    static let accentDeepRed     = Color(hex: "#F65036")
    static let progressBarRed    = Color(hex: "#FF8A77")
    static let guideTextGray     = Color(hex: "#D9D9D9")

    //color asset
    static let customColor  = Color("")
}

