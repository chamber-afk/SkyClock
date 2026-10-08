import Foundation

/// Raw JSON returned by OpenWeatherMap's `/data/2.5/weather` endpoint.
/// Decoded with `.convertFromSnakeCase`, so `feels_like` maps to `feelsLike`.
struct WeatherResponse: Decodable {
    let name: String
    let timezone: Int
    let sys: Sys
    let main: Main
    let weather: [Condition]
    let wind: Wind?

    struct Sys: Decodable {
        let country: String?
    }

    struct Main: Decodable {
        let temp: Double
        let feelsLike: Double
        let humidity: Int
    }

    struct Condition: Decodable {
        let id: Int
        let description: String
        let icon: String
    }

    struct Wind: Decodable {
        let speed: Double
    }
}
