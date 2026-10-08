import Foundation

/// Clean model used by the rest of the app. Temperatures are always stored in Celsius
/// and wind in metres per second; the view model converts them for display.
struct Weather: Equatable {
    let city: String
    let countryCode: String
    let temperatureC: Double
    let feelsLikeC: Double
    let humidity: Int
    let windSpeed: Double
    let description: String
    let conditionId: Int
    let isDaytime: Bool
    /// Offset from UTC, in seconds, for the searched city.
    let timezoneOffset: Int

    var theme: WeatherTheme {
        WeatherTheme(conditionId: conditionId)
    }
}

extension Weather {
    /// Returns nil if the response has no weather condition.
    init?(response: WeatherResponse) {
        guard let condition = response.weather.first else { return nil }
        self.init(
            city: response.name,
            countryCode: response.sys.country ?? "",
            temperatureC: response.main.temp,
            feelsLikeC: response.main.feelsLike,
            humidity: response.main.humidity,
            windSpeed: response.wind?.speed ?? 0,
            description: condition.description,
            conditionId: condition.id,
            // OpenWeatherMap icon codes end in "d" (day) or "n" (night), e.g. "10d".
            isDaytime: condition.icon.hasSuffix("d"),
            timezoneOffset: response.timezone
        )
    }
}
