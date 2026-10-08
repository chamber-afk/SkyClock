import UIKit

/// Holds the screen's state and business logic. Knows nothing about views.
@MainActor
final class WeatherViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded(Weather)
        case failed(AppError)
    }

    // MARK: - Outputs (the view controller binds to these)

    var onStateChange: ((State) -> Void)?
    var onFlagChange: ((UIImage?) -> Void)?
    var onRecentsChange: (([String]) -> Void)?

    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }

    private(set) var recentCities: [String] {
        didSet { onRecentsChange?(recentCities) }
    }

    /// Name of the last successfully loaded city, used for pull-to-refresh.
    private(set) var currentCity: String?

    var useFahrenheit: Bool {
        didSet { defaults.set(useFahrenheit, forKey: Keys.useFahrenheit) }
    }

    // MARK: - Private

    private enum Keys {
        static let recentCities = "recentCities"
        static let lastCity = "lastCity"
        static let useFahrenheit = "useFahrenheit"
    }

    private let maxRecentCities = 5
    private let weatherService: WeatherServicing
    private let flagService: FlagServicing
    private let defaults: UserDefaults
    private var searchTask: Task<Void, Never>?

    init(weatherService: WeatherServicing = WeatherService(),
         flagService: FlagServicing = FlagService(),
         defaults: UserDefaults = .standard) {
        self.weatherService = weatherService
        self.flagService = flagService
        self.defaults = defaults
        self.recentCities = defaults.stringArray(forKey: Keys.recentCities) ?? []
        self.useFahrenheit = defaults.bool(forKey: Keys.useFahrenheit)
    }

    // MARK: - Actions

    func loadLastCity() {
        guard let city = defaults.string(forKey: Keys.lastCity) else { return }
        search(city: city)
    }

    func refresh() {
        guard let city = currentCity else { return }
        search(city: city)
    }

    /// Starts a search. A newer search cancels the one still running.
    func search(city: String) {
        searchTask?.cancel()
        searchTask = Task { await performSearch(city: city) }
    }

    /// The async work behind `search(city:)`. Internal so tests can `await` it.
    func performSearch(city: String) async {
        let query = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            state = .failed(.emptyQuery)
            return
        }

        state = .loading
        do {
            let weather = try await weatherService.fetchWeather(for: query)
            try Task.checkCancellation()

            currentCity = weather.city
            remember(city: weather.city)
            state = .loaded(weather)

            let flag = await flagService.flagImage(for: weather.countryCode)
            guard !Task.isCancelled else { return }
            onFlagChange?(flag)
        } catch is CancellationError {
            return // A newer search replaced this one.
        } catch let error as AppError {
            state = .failed(error)
        } catch {
            state = .failed(.serverError)
        }
    }

    // MARK: - Formatting

    func display(for weather: Weather) -> WeatherDisplay {
        WeatherDisplay(
            city: weather.city,
            countryCode: weather.countryCode,
            flagEmoji: weather.countryCode.flagEmoji,
            temperature: temperatureText(for: weather.temperatureC),
            condition: weather.description.withFirstLetterCapitalized,
            feelsLike: temperatureText(for: weather.feelsLikeC),
            humidity: "\(weather.humidity)%",
            wind: windText(for: weather.windSpeed),
            symbolName: weather.theme.symbolName(isDaytime: weather.isDaytime),
            timeZone: TimeZone(secondsFromGMT: weather.timezoneOffset) ?? .current
        )
    }

    func temperatureText(for celsius: Double) -> String {
        let value = useFahrenheit ? celsius * 9 / 5 + 32 : celsius
        return "\(Int(value.rounded()))°"
    }

    func windText(for metersPerSecond: Double) -> String {
        if useFahrenheit {
            return "\(Int((metersPerSecond * 2.23694).rounded())) mph"
        }
        return "\(Int((metersPerSecond * 3.6).rounded())) km/h"
    }

    // MARK: - Persistence

    private func remember(city: String) {
        var cities = recentCities.filter { $0.caseInsensitiveCompare(city) != .orderedSame }
        cities.insert(city, at: 0)
        recentCities = Array(cities.prefix(maxRecentCities))

        defaults.set(recentCities, forKey: Keys.recentCities)
        defaults.set(city, forKey: Keys.lastCity)
    }
}
