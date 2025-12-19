import Foundation

/// Thread-safe in-memory cache for promo apps using Swift actors
actor CrossPromoCache {
    private var cachedApps: [PromoApp]?
    private var cacheTimestamp: Date?
    private let duration: TimeInterval

    init(duration: TimeInterval) {
        self.duration = duration
    }

    /// Returns cached apps if the cache is still valid, nil otherwise
    func getCachedApps() -> [PromoApp]? {
        guard isValid else {
            cachedApps = nil
            cacheTimestamp = nil
            return nil
        }
        return cachedApps
    }

    /// Stores apps in the cache with the current timestamp
    func setCachedApps(_ apps: [PromoApp]) {
        cachedApps = apps
        cacheTimestamp = Date()
    }

    /// Clears the cache
    func invalidate() {
        cachedApps = nil
        cacheTimestamp = nil
    }

    /// Returns true if the cache has valid, non-expired data
    var isValid: Bool {
        guard let timestamp = cacheTimestamp else { return false }
        return Date().timeIntervalSince(timestamp) < duration
    }
}
