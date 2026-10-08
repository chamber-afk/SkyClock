import UIKit

final class SplashViewController: UIViewController {

    /// Called when the user taps "Get Started". The scene delegate swaps in the main screen.
    var onGetStarted: (() -> Void)?

    private let backgroundView = GradientView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel.make(font: .scaled(.largeTitle, size: 40, weight: .bold))
    private let subtitleLabel = UILabel.make(font: .preferredFont(forTextStyle: .body),
                                             color: .secondaryWhite,
                                             lines: 0)
    private let startButton = UIButton(type: .system)
    private let contentStack = UIStackView()

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        setUpViews()
        setUpLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    // MARK: - Setup

    private func setUpViews() {
        backgroundView.apply(colors: WeatherTheme.clear.gradientColors(isDaytime: true), animated: false)

        iconView.image = UIImage(systemName: "cloud.sun.fill",
                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 110, weight: .light))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.isAccessibilityElement = false

        titleLabel.text = "SkyClock"
        titleLabel.accessibilityTraits = .header
        subtitleLabel.text = "Weather and the local time for any city in the world."

        var configuration = UIButton.Configuration.filled()
        configuration.title = "Get Started"
        configuration.baseBackgroundColor = .white
        configuration.baseForegroundColor = UIColor(hex: 0x1C7ED6)
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 40, bottom: 16, trailing: 40)
        startButton.configuration = configuration
        startButton.addAction(UIAction { [weak self] _ in self?.onGetStarted?() }, for: .touchUpInside)

        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 12
        [iconView, titleLabel, subtitleLabel, startButton].forEach { contentStack.addArrangedSubview($0) }
        contentStack.setCustomSpacing(36, after: subtitleLabel)
        contentStack.alpha = 0 // Revealed by animateIn()
    }

    private func setUpLayout() {
        [backgroundView, contentStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            contentStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16)
        ])
    }

    private func animateIn() {
        contentStack.transform = CGAffineTransform(translationX: 0, y: 24)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
            self.contentStack.alpha = 1
            self.contentStack.transform = .identity
        }
    }
}
