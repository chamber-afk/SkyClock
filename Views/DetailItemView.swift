import UIKit

/// One small stat: icon, value and title (e.g. drop icon, "64%", "Humidity").
final class DetailItemView: UIView {

    private let title: String
    private let iconView = UIImageView()
    private let valueLabel = UILabel.make(font: .scaled(.headline, size: 18, weight: .semibold))
    private let titleLabel = UILabel.make(font: .scaled(.caption1, size: 12, weight: .regular),
                                          color: .secondaryWhite)

    init(symbolName: String, title: String) {
        self.title = title
        super.init(frame: .zero)

        iconView.image = UIImage(systemName: symbolName)
        iconView.tintColor = .secondaryWhite
        iconView.contentMode = .scaleAspectFit
        iconView.isAccessibilityElement = false

        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        valueLabel.text = "–"
        titleLabel.text = title

        let stack = UIStackView(arrangedSubviews: [iconView, valueLabel, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: 22),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // VoiceOver reads the whole item as one phrase, e.g. "Humidity, 64%".
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used; views are created in code")
    }

    func setValue(_ value: String) {
        valueLabel.text = value
        accessibilityLabel = "\(title), \(value)"
    }
}
