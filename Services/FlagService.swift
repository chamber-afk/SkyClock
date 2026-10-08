import UIKit

protocol FlagServicing {
    func flagImage(for countryCode: String) async -> UIImage?
}

/// Downloads a flag PNG from flagcdn.com using the ISO country code returned by the weather API.
/// Returns nil on any failure; the UI then falls back to an emoji flag.
struct FlagService: FlagServicing {

    private let session: URLSession
    private let cache: ImageCache

    init(session: URLSession = .shared, cache: ImageCache = .shared) {
        self.session = session
        self.cache = cache
    }

    func flagImage(for countryCode: String) async -> UIImage? {
        guard countryCode.count == 2,
              let url = URL(string: "https://flagcdn.com/w160/\(countryCode.lowercased()).png")
        else { return nil }

        if let cached = cache.image(for: url) { return cached }

        guard let result = try? await session.data(from: url),
              (result.1 as? HTTPURLResponse)?.statusCode == 200,
              let image = UIImage(data: result.0)
        else { return nil }

        cache.insert(image, for: url)
        return image
    }
}
