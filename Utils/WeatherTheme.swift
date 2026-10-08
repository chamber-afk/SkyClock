import UIKit

/// Maps an OpenWeatherMap condition id to a look: gradient colours and an SF Symbol.
/// Condition ids: https://openweathermap.org/weather-conditions
enum WeatherTheme {
    case clear, clouds, rain, storm, snow, mist

    init(conditionId: Int) {
        switch conditionId {
        case 200...232:            self = .storm
        case 300...321, 500...531: self = .rain
        case 600...622:            self = .snow
        case 701...781:            self = .mist
        case 800:                  self = .clear
        default:                   self = .clouds
        }
    }

    func symbolName(isDaytime: Bool) -> String {
        switch self {
        case .clear:  return isDaytime ? "sun.max.fill" : "moon.stars.fill"
        case .clouds: return isDaytime ? "cloud.sun.fill" : "cloud.moon.fill"
        case .rain:   return "cloud.rain.fill"
        case .storm:  return "cloud.bolt.rain.fill"
        case .snow:   return "cloud.snow.fill"
        case .mist:   return "cloud.fog.fill"
        }
    }

    func gradientColors(isDaytime: Bool) -> [UIColor] {
        let hexes: [UInt32]
        switch (self, isDaytime) {
        case (.clear, true):   hexes = [0x1C7ED6, 0x4DABF7]
        case (.clear, false):  hexes = [0x0B1026, 0x2B3A67]
        case (.clouds, true):  hexes = [0x5C7A99, 0x9FB4C7]
        case (.clouds, false): hexes = [0x1F2937, 0x4B5563]
        case (.rain, true):    hexes = [0x35495E, 0x5D7B93]
        case (.rain, false):   hexes = [0x111827, 0x2C3E50]
        case (.storm, true):   hexes = [0x2C3040, 0x59506B]
        case (.storm, false):  hexes = [0x0F0F1A, 0x2A2438]
        case (.snow, true):    hexes = [0x6D8CA8, 0xB7CBDD]
        case (.snow, false):   hexes = [0x2B3A4D, 0x5A6F85]
        case (.mist, true):    hexes = [0x6B7B8C, 0xA9B4BF]
        case (.mist, false):   hexes = [0x2A323B, 0x505B66]
        }
        return hexes.map { UIColor(hex: $0) }
    }
}
