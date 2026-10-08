import Foundation

/// Everything the weather card needs, already formatted as strings.
struct WeatherDisplay {
    let city: String
    let countryCode: String
    let flagEmoji: String
    let temperature: String
    let condition: String
    let feelsLike: String
    let humidity: String
    let wind: String
    let symbolName: String
    let timeZone: TimeZone
}
