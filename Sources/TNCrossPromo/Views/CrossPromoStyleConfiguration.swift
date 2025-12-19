import SwiftUI

/// Defines the layout style for promo app cards
public enum CrossPromoCardStyle: Sendable, Equatable {
    /// Title and subtitle displayed below the image
    case standard
    /// Title and subtitle overlay the bottom of the image with a blur effect
    case overlay
}

/// Defines the size of promo app images
public enum CrossPromoImageSize: Sendable, Equatable {
    /// Image scales to fit naturally within maxWidth, maintaining aspect ratio
    case auto(maxWidth: CGFloat)
    /// Square image with equal width and height
    case square(CGFloat)
    /// Fixed width and height
    case fixed(width: CGFloat, height: CGFloat)

    /// The width to use for the card container
    public var cardWidth: CGFloat {
        switch self {
        case .auto(let maxWidth):
            return maxWidth
        case .square(let size):
            return size
        case .fixed(let width, _):
            return width
        }
    }

    /// The height of the image
    public var imageHeight: CGFloat {
        switch self {
        case .auto(let maxWidth):
            return maxWidth * 0.8 // Placeholder aspect ratio
        case .square(let size):
            return size
        case .fixed(_, let height):
            return height
        }
    }
}

/// Style configuration for cross-promo views
public struct CrossPromoStyleConfiguration: Sendable {
    /// Title displayed above the featured carousel (nil to hide)
    public let sectionTitle: String?

    /// Text for the "Show All" button
    public let showAllButtonTitle: String

    /// Size configuration for app images
    public let imageSize: CrossPromoImageSize

    /// Layout style for cards
    public let cardStyle: CrossPromoCardStyle

    /// Corner radius for app images
    public let imageCornerRadius: CGFloat

    /// Spacing between cards
    public let spacing: CGFloat

    /// Font for app titles
    public let titleFont: Font

    /// Font for app subtitles
    public let subtitleFont: Font

    /// Default style configuration
    public static let `default` = CrossPromoStyleConfiguration(
        sectionTitle: "You might also like",
        showAllButtonTitle: "Show All",
        imageSize: .fixed(width: 300, height: 240),
        cardStyle: .standard,
        imageCornerRadius: 12,
        spacing: 12,
        titleFont: .headline,
        subtitleFont: .caption
    )

    public init(
        sectionTitle: String? = "You might also like",
        showAllButtonTitle: String = "Show All",
        imageSize: CrossPromoImageSize = .fixed(width: 300, height: 240),
        cardStyle: CrossPromoCardStyle = .standard,
        imageCornerRadius: CGFloat = 12,
        spacing: CGFloat = 12,
        titleFont: Font = .headline,
        subtitleFont: Font = .caption
    ) {
        self.sectionTitle = sectionTitle
        self.showAllButtonTitle = showAllButtonTitle
        self.imageSize = imageSize
        self.cardStyle = cardStyle
        self.imageCornerRadius = imageCornerRadius
        self.spacing = spacing
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
    }
}
