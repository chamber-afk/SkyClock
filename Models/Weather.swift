import Foundation

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
    let timezoneOffset: Int

    var theme: WeatherTheme {
        WeatherTheme(conditionId: conditionId)
    }
}

extension Weather {
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
            isDaytime: condition.icon.hasSuffix("d"),
            timezoneOffset: response.timezone
        )
    }
}
