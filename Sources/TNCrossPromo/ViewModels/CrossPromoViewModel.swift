import Foundation
import SwiftUI

/// Observable view model managing cross-promotion state
@MainActor
@Observable
public final class CrossPromoViewModel {
    // MARK: - Published State

    /// All apps loaded from the feed (excluding the current app if configured)
    public private(set) var apps: [PromoApp] = []

    /// Featured apps for the horizontal carousel
    public private(set) var featuredApps: [PromoApp] = []

    /// Whether a fetch is currently in progress
    public private(set) var isLoading: Bool = false

    /// The last error that occurred, if any
    public private(set) var error: CrossPromoError?

    // MARK: - Private Properties

    private let configuration: CrossPromoConfiguration
    private let fetcher: CrossPromoFetching
    private let cache: CrossPromoCache
    private let urlOpener: URLOpening

    /// In-flight fetch task to prevent concurrent requests
    private var fetchTask: Task<Void, Never>?

    // MARK: - Initialization

    /// Creates a view model with the given configuration
    public init(configuration: CrossPromoConfiguration) {
        self.configuration = configuration
        self.fetcher = CrossPromoFetcher()
        self.cache = CrossPromoCache(duration: configuration.cacheDuration)
        self.urlOpener = SystemURLOpener()
    }

    /// Internal initializer for testing with dependency injection
    init(
        configuration: CrossPromoConfiguration,
        fetcher: CrossPromoFetching,
        cache: CrossPromoCache,
        urlOpener: URLOpening
    ) {
        self.configuration = configuration
        self.fetcher = fetcher
        self.cache = cache
        self.urlOpener = urlOpener
    }

    // MARK: - Public Methods

    /// Fetches apps from the feed, using cache if valid
    public func loadApps() async {
        // Return cached data if valid
        if let cached = await cache.getCachedApps() {
            applyApps(cached)
            return
        }

        // If a fetch is already in progress, wait for it
        if let existingTask = fetchTask {
            await existingTask.value
            return
        }

        await performFetch()
    }

    /// Forces a fresh fetch, ignoring cache
    public func refresh() async {
        // Cancel any existing fetch
        fetchTask?.cancel()
        fetchTask = nil

        await cache.invalidate()
        await performFetch()
    }

    /// Opens the destination URL for an app
    public func openApp(_ app: PromoApp) {
        urlOpener.open(app.destinationURL)
    }

    /// Clears the cache
    public func clearCache() async {
        await cache.invalidate()
    }

    // MARK: - Private Methods

    private func performFetch() async {
        isLoading = true
        error = nil

        let task = Task {
            do {
                let fetchedApps = try await fetcher.fetchApps(from: configuration.feedURL)
                if !Task.isCancelled {
                    await cache.setCachedApps(fetchedApps)
                    applyApps(fetchedApps)
                }
            } catch let fetchError as CrossPromoError {
                if !Task.isCancelled {
                    error = fetchError
                }
            } catch {
                if !Task.isCancelled {
                    self.error = .networkError(underlying: error)
                }
            }
        }

        fetchTask = task
        await task.value
        fetchTask = nil
        isLoading = false
    }

    private func applyApps(_ fetchedApps: [PromoApp]) {
        // Filter out the current app if configured
        let filteredApps: [PromoApp]
        if let excludeID = configuration.excludeAppID {
            filteredApps = fetchedApps.filter { $0.id != excludeID }
        } else {
            filteredApps = fetchedApps
        }

        apps = filteredApps

        // Extract featured apps, limited by maxFeaturedItems
        featuredApps = Array(
            filteredApps
                .filter { $0.isFeatured }
                .prefix(configuration.maxFeaturedItems)
        )
    }
}
