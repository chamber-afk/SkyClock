import UIKit

/// Horizontally scrolling row of tappable chips (used for recent searches).
final class ChipsView: UIView {

    var onSelect: ((String) -> Void)?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),

            // The row is as tall as its chips.
            heightAnchor.constraint(equalTo: stackView.heightAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used; views are created in code")
    }

    func update(cities: [String]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        cities.forEach { stackView.addArrangedSubview(makeChip(for: $0)) }
        isHidden = cities.isEmpty
    }

    private func makeChip(for city: String) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = city
        configuration.baseBackgroundColor = UIColor.white.withAlphaComponent(0.2)
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)

        let button = UIButton(configuration: configuration,
                              primaryAction: UIAction { [weak self] _ in self?.onSelect?(city) })
        button.accessibilityHint = "Shows the weather for \(city)"
        return button
    }
}
