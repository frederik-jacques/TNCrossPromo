# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Run a single test suite
swift test --filter "CrossPromoViewModel Tests"

# Run a single test
swift test --filter "ViewModel loads apps"
```

## Project Overview

TNCrossPromo is a Swift Package library for cross-promoting apps. It fetches app data from a remote JSON endpoint and provides pre-built SwiftUI views for displaying promoted apps in settings menus.

**Requirements:** iOS 17+, macOS 14+, tvOS 17+, watchOS 10+, visionOS 1+, Swift 6.2+

## Architecture

```
Sources/TNCrossPromo/
├── Models/           # Data models (PromoApp, PromoAppDTO, Configuration, Error)
├── Networking/       # HTTPClient protocol, Cache actor, Fetcher
├── ViewModels/       # @Observable CrossPromoViewModel, URLOpener protocol
└── Views/            # SwiftUI views (FeaturedView, ListView, PromoAppCard)
```

### Key Types

- **PromoApp**: Public domain model with id, title, subtitle, imageURL, destinationURL, isFeatured, sortOrder
- **PromoAppDTO**: Internal Codable DTO matching JSON structure (snake_case keys)
- **CrossPromoConfiguration**: Feed URL, cache duration, excludeAppID, maxFeaturedItems
- **CrossPromoViewModel**: @Observable state manager with loadApps(), refresh(), openApp()
- **CrossPromoFeaturedView**: Horizontal scrolling carousel with pagination for settings screens
- **CrossPromoListView**: Full list view with pull-to-refresh
- **CrossPromoStyleConfiguration**: Styling options for views (imageSize, cardStyle, fonts, spacing)
- **CrossPromoImageSize**: Enum for image sizing (.auto, .square, .fixed)
- **CrossPromoCardStyle**: Enum for card layout (.standard, .overlay with blur)

### Design Patterns

- **DTO + Domain Model separation**: PromoAppDTO handles JSON decoding, PromoApp is the clean public API
- **Protocol-based networking**: HTTPClient and CrossPromoFetching protocols enable testing with mocks
- **Actor-based cache**: CrossPromoCache uses Swift actors for thread-safe caching
- **Dependency injection**: ViewModel accepts protocols for fetcher, cache, and URL opener
- **In-flight task coalescing**: ViewModel prevents concurrent fetches by awaiting existing tasks
- **URL scheme allowlisting**: Only `https` for images, `https`/`itms-apps` for destinations

## JSON Feed Format

```json
{
  "version": "1.0",
  "apps": [
    {
      "id": "com.example.app",
      "title": "App Name",
      "short_description": "Description",
      "image_url": "https://...",
      "destination_url": "https://apps.apple.com/...",
      "is_featured": true,
      "sort_order": 1
    }
  ]
}
```

## Testing

Tests use Swift Testing framework with `@Test` macro and `#expect()` assertions. Mock types are in `Tests/TNCrossPromoTests/Mocks/`.
