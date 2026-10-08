import Foundation

protocol WeatherServicing {
    func fetchWeather(for city: String) async throws -> Weather
}

struct WeatherService: WeatherServicing {

    private static let placeholderKey = "YOUR_API_KEY_HERE"
    private static let endpoint = "https://api.openweathermap.org/data/2.5/weather"

    private let session: URLSession
    private let apiKey: String

    init(session: URLSession = .shared, apiKey: String = Config.openWeatherAPIKey) {
        self.session = session
        self.apiKey = apiKey
    }

    func fetchWeather(for city: String) async throws -> Weather {
        guard !apiKey.isEmpty, apiKey != Self.placeholderKey else {
            throw AppError.missingAPIKey
        }

        // URLComponents percent-encodes the city, so "New York" works.
        var components = URLComponents(string: Self.endpoint)
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        guard let url = components?.url else { throw AppError.cityNotFound }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch let error as CancellationError {
            throw error
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw AppError.noInternet
        }

        guard let http = response as? HTTPURLResponse else { throw AppError.serverError }
        switch http.statusCode {
        case 200:      break
        case 401:      throw AppError.invalidAPIKey
        case 404:      throw AppError.cityNotFound
        default:       throw AppError.serverError
        }

        return try Self.decodeWeather(from: data)
    }

    /// Separated from the network call so it can be unit tested with sample JSON.
    static func decodeWeather(from data: Data) throws -> Weather {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard
            let response = try? decoder.decode(WeatherResponse.self, from: data),
            let weather = Weather(response: response)
        else {
            throw AppError.decodingFailed
        }
        return weather
    }
}
