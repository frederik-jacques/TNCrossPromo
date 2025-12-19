import Foundation
@testable import TNCrossPromo

extension PromoApp {
    static func mock(
        id: String = "test-id",
        title: String = "Test App",
        subtitle: String = "Test description",
        imageURL: URL = URL(string: "https://example.com/image.png")!,
        destinationURL: URL = URL(string: "https://apps.apple.com/app/123")!,
        isFeatured: Bool = false,
        sortOrder: Int = 0
    ) -> PromoApp {
        PromoApp(
            id: id,
            title: title,
            subtitle: subtitle,
            imageURL: imageURL,
            destinationURL: destinationURL,
            isFeatured: isFeatured,
            sortOrder: sortOrder
        )
    }
}

extension CrossPromoConfiguration {
    static func mock(
        feedURL: URL = URL(string: "https://test.com/promo.json")!,
        cacheDuration: TimeInterval = 3600,
        excludeAppID: String? = nil,
        maxFeaturedItems: Int = 5
    ) -> CrossPromoConfiguration {
        CrossPromoConfiguration(
            feedURL: feedURL,
            cacheDuration: cacheDuration,
            excludeAppID: excludeAppID,
            maxFeaturedItems: maxFeaturedItems
        )
    }
}

enum TestData {
    static let validJSON = """
    {
        "version": "1.0",
        "apps": [
            {
                "id": "com.example.app1",
                "title": "Test App 1",
                "short_description": "First test app",
                "image_url": "https://example.com/image1.png",
                "destination_url": "https://apps.apple.com/app/1",
                "is_featured": true,
                "sort_order": 1
            },
            {
                "id": "com.example.app2",
                "title": "Test App 2",
                "short_description": "Second test app",
                "image_url": "https://example.com/image2.png",
                "destination_url": "https://apps.apple.com/app/2",
                "is_featured": false,
                "sort_order": 2
            }
        ]
    }
    """.data(using: .utf8)!

    static let jsonWithInvalidURL = """
    {
        "version": "1.0",
        "apps": [
            {
                "id": "valid",
                "title": "Valid App",
                "short_description": "Valid",
                "image_url": "https://example.com/image.png",
                "destination_url": "https://apps.apple.com/app/1"
            },
            {
                "id": "invalid",
                "title": "Invalid App",
                "short_description": "Invalid",
                "image_url": "not a url",
                "destination_url": "https://apps.apple.com/app/2"
            }
        ]
    }
    """.data(using: .utf8)!

    static let minimalJSON = """
    {
        "apps": [
            {
                "id": "minimal",
                "title": "Minimal App",
                "short_description": "No optional fields",
                "image_url": "https://example.com/image.png",
                "destination_url": "https://apps.apple.com/app/1"
            }
        ]
    }
    """.data(using: .utf8)!
}
