import UIKit

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: alpha)
    }

    static let secondaryWhite = UIColor.white.withAlphaComponent(0.75)
}

extension UIFont {
    /// A system font that grows with the user's Dynamic Type setting.
    static func scaled(_ style: UIFont.TextStyle, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        UIFontMetrics(forTextStyle: style).scaledFont(for: .systemFont(ofSize: size, weight: weight))
    }
}

extension UILabel {
    static func make(font: UIFont,
                     color: UIColor = .white,
                     lines: Int = 1,
                     alignment: NSTextAlignment = .center) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.numberOfLines = lines
        label.textAlignment = alignment
        label.adjustsFontForContentSizeCategory = true
        return label
    }
}

extension String {
    /// "IN" -> 🇮🇳. Built from regional indicator symbols, so it needs no network.
    var flagEmoji: String {
        let regionalIndicatorBase: UInt32 = 127_397
        return uppercased().unicodeScalars
            .compactMap { UnicodeScalar(regionalIndicatorBase + $0.value) }
            .map { String($0) }
            .joined()
    }

    var withFirstLetterCapitalized: String {
        String(prefix(1)).uppercased() + String(dropFirst())
    }
}
