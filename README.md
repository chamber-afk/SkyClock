# SkyClock

A UIKit weather app (no storyboards, no third-party libraries). Search any city to see its
weather, local time that ticks live, and country flag. The background gradient changes with
the weather and with day or night.

## Features
- Programmatic UIKit UI (Auto Layout, `UIStackView`, `UIScrollView`), animated splash screen
- City search, recent-search chips, last city restored on launch
- Live local time for the searched city (uses the timezone offset from the weather API)
- Feels like, humidity and wind; °C / °F toggle that is remembered
- Pull to refresh, loading spinner, clear error messages
- Flag image with an in-memory `NSCache` and an emoji fallback
- Dynamic Type and VoiceOver labels

## Architecture
MVVM. `WeatherViewModel` holds state and logic; view controllers only render it.
`WeatherService` and `FlagService` sit behind protocols so tests can inject mocks.
Networking uses `async/await` with a typed `AppError`.

```
App/         AppDelegate, SceneDelegate, Config (API key)
Models/      WeatherResponse (JSON), Weather (domain), WeatherDisplay (formatted for UI)
Services/    WeatherService, FlagService, ImageCache
ViewModels/  WeatherViewModel
Views/       SplashViewController, MainViewController, WeatherCardView, ChipsView, ...
Utils/       AppError, WeatherTheme, Extensions
SkyClockTests/  view model and JSON decoding tests
```

## API key
Get a free key at https://openweathermap.org/api, then paste it into `App/Config.swift`.
That file is in `.gitignore`. If you clone this repo, copy `Config.example.swift.txt`
to `App/Config.swift` first.

## Setup in Xcode
See the steps in the chat message that came with this zip.
