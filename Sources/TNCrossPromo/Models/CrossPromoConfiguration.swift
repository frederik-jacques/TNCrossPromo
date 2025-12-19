import Foundation

/// Configuration for the cross-promotion system
public struct CrossPromoConfiguration: Sendable {
    /// URL to fetch the JSON feed from
    public let feedURL: URL

    /// Cache duration in seconds (default: 1 hour)
    public let cacheDuration: TimeInterval

    /// Optional app ID to exclude from the list (typically the current app)
    public let excludeAppID: String?

    /// Maximum number of featured items to display in the carousel
    public let maxFeaturedItems: Int

    public init(
        feedURL: URL,
        cacheDuration: TimeInterval = 3600,
        excludeAppID: String? = nil,
        maxFeaturedItems: Int = 5
    ) {
        self.feedURL = feedURL
        self.cacheDuration = cacheDuration
        self.excludeAppID = excludeAppID
        self.maxFeaturedItems = maxFeaturedItems
    }

    /// Convenience initializer with string URL
    public init?(
        feedURLString: String,
        cacheDuration: TimeInterval = 3600,
        excludeAppID: String? = nil,
        maxFeaturedItems: Int = 5
    ) {
        guard let url = URL(string: feedURLString) else {
            return nil
        }
        self.init(
            feedURL: url,
            cacheDuration: cacheDuration,
            excludeAppID: excludeAppID,
            maxFeaturedItems: maxFeaturedItems
        )
    }
}
