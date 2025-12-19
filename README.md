# TNCrossPromo

A Swift Package for cross-promoting your apps. Because your other apps deserve some love too.

## What is this?

You know that "You might also like" section in apps? The one that shows off the developer's other creations? This package lets you add exactly that to your app with minimal effort.

Host a simple JSON file somewhere, point this package at it, and boom — your apps are now networking with each other like they're at a cocktail party.

## Requirements

- iOS 17+ / macOS 14+ / tvOS 17+ / watchOS 10+ / visionOS 1+
- Swift 6.2+
- A JSON file hosted somewhere (GitHub Pages works great, and it's free!)

## Installation

### Swift Package Manager

Add this to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/YourUsername/TNCrossPromo.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → paste the URL → done.

## Quick Start

### 1. Create your JSON feed

Host this somewhere accessible:

```json
{
  "version": "1.0",
  "apps": [
    {
      "id": "com.yourcompany.amazingapp",
      "title": "Amazing App",
      "short_description": "It's amazing. Trust us.",
      "image_url": "https://yoursite.com/images/amazing-app.png",
      "destination_url": "https://apps.apple.com/app/id123456789",
      "is_featured": true,
      "sort_order": 1
    },
    {
      "id": "com.yourcompany.anotherone",
      "title": "Another One",
      "short_description": "DJ Khaled would be proud.",
      "image_url": "https://yoursite.com/images/another-one.png",
      "destination_url": "https://apps.apple.com/app/id987654321",
      "is_featured": false,
      "sort_order": 2
    }
  ]
}
```

### 2. Add the view to your settings screen

```swift
import TNCrossPromo
import SwiftUI

struct SettingsView: View {
    @State private var viewModel = TNCrossPromo.createViewModel(
        configuration: CrossPromoConfiguration(
            feedURL: URL(string: "https://yoursite.com/promo.json")!,
            excludeAppID: "com.yourcompany.thisapp" // Don't promote yourself to yourself
        )
    )
    @State private var showingAllApps = false

    var body: some View {
        Form {
            // ... your other settings ...

            Section {
                CrossPromoFeaturedView(
                    viewModel: viewModel,
                    onShowAll: { showingAllApps = true }
                )
            }
        }
        .sheet(isPresented: $showingAllApps) {
            NavigationStack {
                CrossPromoListView(viewModel: viewModel)
            }
        }
    }
}
```

That's it. Seriously. Your users can now discover your other apps.

## Customization

### Styling

Don't like our defaults? No problem:

```swift
let style = CrossPromoStyleConfiguration(
    sectionTitle: "More from Us",        // or nil to hide it
    showAllButtonTitle: "See All Apps",
    imageSize: .fixed(width: 280, height: 200),
    cardStyle: .standard,
    imageCornerRadius: 16,
    spacing: 16,
    titleFont: .title3.bold(),
    subtitleFont: .footnote
)

CrossPromoFeaturedView(
    viewModel: viewModel,
    style: style,
    onShowAll: { /* ... */ }
)
```

### Image Sizes

```swift
// Fixed dimensions (default: 300x240)
.fixed(width: 300, height: 240)

// Square images
.square(150)

// Auto-scaling within a max width
.auto(maxWidth: 280)
```

### Card Styles

```swift
// Text below the image (default)
.standard

// Text overlays the image with a blur effect
.overlay
```

### Configuration Options

```swift
let config = CrossPromoConfiguration(
    feedURL: URL(string: "https://...")!,
    cacheDuration: 3600,        // Cache for 1 hour (default)
    excludeAppID: "com.you.app", // Don't show the current app
    maxFeaturedItems: 5          // Limit featured carousel
)
```

### Going Custom

Want to build your own UI? The view model gives you everything you need:

```swift
@State private var viewModel = TNCrossPromo.createViewModel(configuration: config)

var body: some View {
    ForEach(viewModel.apps) { app in
        // app.id, app.title, app.subtitle
        // app.imageURL, app.destinationURL
        // app.isFeatured, app.sortOrder

        MyCustomAppRow(app: app) {
            viewModel.openApp(app) // Opens the App Store
        }
    }
    .task {
        await viewModel.loadApps()
    }
}
```

## JSON Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Unique identifier (bundle ID works well) |
| `title` | String | Yes | App name |
| `short_description` | String | Yes | Brief description |
| `image_url` | String | Yes | URL to promotional image (must be `https`) |
| `destination_url` | String | Yes | App Store link (`https` or `itms-apps` scheme) |
| `is_featured` | Boolean | No | Show in featured carousel (default: false) |
| `sort_order` | Integer | No | Lower numbers appear first |

The `version` field in the root object is optional and currently unused, but it's there for future compatibility. You're welcome, future you.

> **Note:** URLs are validated for security. Only `https` is allowed for images, and only `https` or `itms-apps` for destinations. Apps with other URL schemes (like `http`, `file`, `tel`) are silently dropped.

## Features

- **Horizontal carousel** with pagination snapping (perfect for settings screens)
- **Two card styles**: standard (text below) or overlay (text over image with blur)
- **Flexible image sizing**: fixed, square, or auto-scaling
- **Full list view** with pull-to-refresh
- **Smart caching** so you're not hammering your server
- **URL scheme validation** to prevent malicious redirects (only https/itms-apps allowed)
- **Graceful error handling** (no crashes if your JSON goes on vacation)
- **Full async/await support** because it's not 2015 anymore
- **Thoroughly tested** with 40 unit tests

## FAQ

**Q: Why not just hardcode the apps?**
A: Because then you'd have to ship an app update every time you release something new. With a JSON feed, you update once and all your apps see the changes.

**Q: Can I use this for apps that aren't mine?**
A: Technically yes, but that would be weird. And possibly against App Store guidelines. Don't be weird.

**Q: What happens if the JSON fails to load?**
A: The views gracefully show nothing. No crashes, no error alerts screaming at your users. It just... doesn't show up.

**Q: Is this production ready?**
A: It has 40 passing tests, proper error handling, and actor-based thread-safe caching. So... yes? But also, test it yourself. Trust no one. Not even this README.

## Credits

Created by [Frederik Jacques](https://the-nerd.be) • Follow on [X](https://x.com/thenerd_be)

### Used in apps

- [Capitalia](https://apps.apple.com/us/app/capitalia-world-capitals-quiz/id6754272202) — Learn the capitals & flags of the world
- [Peek-a-Doodle](https://apps.apple.com/be/app/peekadoodle-friends-widget/id6753864958) — Send doodles to your friends' homescreen widget
- [Mimi](https://apps.apple.com/us/app/mimi-the-best-meme-maker/id6748402643) — Create your next viral meme

## License

MIT. Do whatever you want with it. Credit is appreciated but not required. A star on the repo would make our day though.

---

Made with caffeine and mass amounts of mass amounts of mass amounts of `@Observable`.
