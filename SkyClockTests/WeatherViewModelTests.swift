import XCTest
@testable import SkyClock

// MARK: - Test doubles

private struct MockWeatherService: WeatherServicing {
    let result: Result<Weather, AppError>
    func fetchWeather(for city: String) async throws -> Weather { try result.get() }
}

private struct MockFlagService: FlagServicing {
    func flagImage(for countryCode: String) async -> UIImage? { nil }
}

private extension Weather {
    static func sample(city: String = "Paris") -> Weather {
        Weather(city: city, countryCode: "FR", temperatureC: 20, feelsLikeC: 19,
                humidity: 50, windSpeed: 10, description: "clear sky",
                conditionId: 800, isDaytime: true, timezoneOffset: 7200)
    }
}

// MARK: - Tests

@MainActor
final class WeatherViewModelTests: XCTestCase {

    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "SkyClockTests")
        defaults.removePersistentDomain(forName: "SkyClockTests")
    }

    private func makeViewModel(_ result: Result<Weather, AppError>) -> WeatherViewModel {
        WeatherViewModel(weatherService: MockWeatherService(result: result),
                         flagService: MockFlagService(),
                         defaults: defaults)
    }

    func testSuccessfulSearchLoadsWeatherAndSavesRecent() async {
        let viewModel = makeViewModel(.success(.sample()))
        await viewModel.performSearch(city: "Paris")
        XCTAssertEqual(viewModel.state, .loaded(.sample()))
        XCTAssertEqual(viewModel.recentCities, ["Paris"])
    }

    func testEmptyQueryFails() async {
        let viewModel = makeViewModel(.success(.sample()))
        await viewModel.performSearch(city: "   ")
        XCTAssertEqual(viewModel.state, .failed(.emptyQuery))
    }

    func testCityNotFoundFails() async {
        let viewModel = makeViewModel(.failure(.cityNotFound))
        await viewModel.performSearch(city: "Nowhereville")
        XCTAssertEqual(viewModel.state, .failed(.cityNotFound))
        XCTAssertTrue(viewModel.recentCities.isEmpty)
    }

    func testRecentCitiesHaveNoDuplicatesAndAreCappedAtFive() async {
        for name in ["A", "B", "C", "D", "E", "F", "c"] {
            let viewModel = WeatherViewModel(
                weatherService: MockWeatherService(result: .success(.sample(city: name))),
                flagService: MockFlagService(),
                defaults: defaults)
            await viewModel.performSearch(city: name)
        }
        let viewModel = makeViewModel(.success(.sample()))
        XCTAssertEqual(viewModel.recentCities.count, 5)
        XCTAssertEqual(viewModel.recentCities.first, "c")
        XCTAssertEqual(viewModel.recentCities.filter { $0.lowercased() == "c" }.count, 1)
    }

    func testFahrenheitConversion() {
        let viewModel = makeViewModel(.success(.sample()))
        viewModel.useFahrenheit = true
        XCTAssertEqual(viewModel.temperatureText(for: 100), "212°")
        viewModel.useFahrenheit = false
        XCTAssertEqual(viewModel.temperatureText(for: 20.4), "20°")
    }
}

final class WeatherDecodingTests: XCTestCase {

    func testDecodesSampleResponse() throws {
        let json = """
        {"weather":[{"id":500,"main":"Rain","description":"light rain","icon":"10n"}],
         "main":{"temp":12.4,"feels_like":11.0,"humidity":80},
         "wind":{"speed":4.5},"sys":{"country":"GB"},"timezone":3600,"name":"London"}
        """
        let weather = try WeatherService.decodeWeather(from: Data(json.utf8))
        XCTAssertEqual(weather.city, "London")
        XCTAssertEqual(weather.countryCode, "GB")
        XCTAssertEqual(weather.conditionId, 500)
        XCTAssertFalse(weather.isDaytime)
        XCTAssertEqual(weather.timezoneOffset, 3600)
    }

    func testInvalidJSONThrowsDecodingError() {
        XCTAssertThrowsError(try WeatherService.decodeWeather(from: Data("{}".utf8))) { error in
            XCTAssertEqual(error as? AppError, .decodingFailed)
        }
    }
}
