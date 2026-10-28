import UIKit

final class WeatherCardView: UIView {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let cityLabel = UILabel.make(font: .scaled(.title1, size: 30, weight: .semibold), lines: 2)
    private let flagView = UIImageView()
    private let countryLabel = UILabel.make(font: .preferredFont(forTextStyle: .subheadline), color: .secondaryWhite)
    private let timeLabel = UILabel.make(
        font: UIFontMetrics(forTextStyle: .callout)
            .scaledFont(for: .monospacedDigitSystemFont(ofSize: 16, weight: .regular)),
        color: .secondaryWhite)
    private let iconView = UIImageView()
    private let temperatureLabel = UILabel.make(font: .scaled(.largeTitle, size: 80, weight: .thin))
    private let conditionLabel = UILabel.make(font: .scaled(.title3, size: 20, weight: .medium), lines: 2)
    private let feelsLikeItem = DetailItemView(symbolName: "thermometer", title: "Feels like")
    private let humidityItem = DetailItemView(symbolName: "drop.fill", title: "Humidity")
    private let windItem = DetailItemView(symbolName: "wind", title: "Wind")

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEdMMMjms")
        return formatter
    }()
    private var clockTimer: Timer?
    private var hasContent = false
    private var countryCode = ""
    private var flagImage: UIImage?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setUpLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used; views are created in code")
    }

    func configure(with display: WeatherDisplay) {
        if display.countryCode != countryCode {
            countryCode = display.countryCode
            flagImage = nil
        }

        cityLabel.text = display.city
        temperatureLabel.text = display.temperature
        conditionLabel.text = display.condition
        feelsLikeItem.setValue(display.feelsLike)
        humidityItem.setValue(display.humidity)
        windItem.setValue(display.wind)
        iconView.image = UIImage(systemName: display.symbolName,
                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 88, weight: .light))
        updateCountryRow(flagEmoji: display.flagEmoji)

        timeFormatter.timeZone = display.timeZone
        hasContent = true
        startClock()
    }

    func setFlag(_ image: UIImage?) {
        flagImage = image
        updateCountryRow(flagEmoji: countryCode.flagEmoji)
    }

    // MARK: - Clock

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopClock()
        } else if hasContent {
            startClock()
        }
    }

    private func startClock() {
        stopClock()
        updateTime()
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }

    private func stopClock() {
        clockTimer?.invalidate()
        clockTimer = nil
    }

    private func updateTime() {
        timeLabel.text = timeFormatter.string(from: Date())
    }

    // MARK: - Private helpers

    private func updateCountryRow(flagEmoji: String) {
        if let flagImage {
            flagView.image = flagImage
            flagView.isHidden = false
            countryLabel.text = countryCode
        } else {
            flagView.isHidden = true
            countryLabel.text = countryCode.isEmpty ? nil : "\(flagEmoji) \(countryCode)"
        }
    }

    private func setUpView() {
        layer.cornerRadius = 28
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        clipsToBounds = true

        flagView.contentMode = .scaleAspectFill
        flagView.layer.cornerRadius = 3
        flagView.clipsToBounds = true
        flagView.isHidden = true
        flagView.isAccessibilityElement = false

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.isAccessibilityElement = false 

        timeLabel.accessibilityTraits = .updatesFrequently
        temperatureLabel.adjustsFontSizeToFitWidth = true
        temperatureLabel.minimumScaleFactor = 0.6
    }

    private func setUpLayout() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        let countryRow = UIStackView(arrangedSubviews: [flagView, countryLabel])
        countryRow.axis = .horizontal
        countryRow.alignment = .center
        countryRow.spacing = 8

        let detailsRow = UIStackView(arrangedSubviews: [feelsLikeItem, humidityItem, windItem])
        detailsRow.axis = .horizontal
        detailsRow.distribution = .fillEqually
        detailsRow.spacing = 8

        let stack = UIStackView(arrangedSubviews: [
            cityLabel, countryRow, timeLabel, iconView, temperatureLabel, conditionLabel, detailsRow
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.setCustomSpacing(16, after: timeLabel)
        stack.setCustomSpacing(20, after: conditionLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stack.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -20),

            flagView.widthAnchor.constraint(equalToConstant: 30),
            flagView.heightAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 100),
            cityLabel.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor),
            conditionLabel.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor),
            detailsRow.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
    }
}
