import SwiftUI

/// Individual app card view for the horizontal carousel
public struct PromoAppCard: View {
    let app: PromoApp
    let style: CrossPromoStyleConfiguration
    let onTap: () -> Void

    public init(
        app: PromoApp,
        style: CrossPromoStyleConfiguration = .default,
        onTap: @escaping () -> Void
    ) {
        self.app = app
        self.style = style
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            switch style.cardStyle {
            case .standard:
                standardCard
            case .overlay:
                overlayCard
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Standard Card Style

    @ViewBuilder
    private var standardCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            imageView
                .clipShape(RoundedRectangle(cornerRadius: style.imageCornerRadius))

            Text(app.title)
                .font(style.titleFont)
                .lineLimit(1)
                .foregroundStyle(.primary)

            Text(app.subtitle)
                .font(style.subtitleFont)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(width: style.imageSize.cardWidth)
    }

    // MARK: - Overlay Card Style

    @ViewBuilder
    private var overlayCard: some View {
        imageView
            .overlay(alignment: .bottom) {
                overlayTextContent
            }
            .clipShape(RoundedRectangle(cornerRadius: style.imageCornerRadius))
            .frame(width: style.imageSize.cardWidth)
    }

    @ViewBuilder
    private var overlayTextContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(app.title)
                .font(style.titleFont)
                .lineLimit(1)
                .foregroundStyle(.white)

            Text(app.subtitle)
                .font(style.subtitleFont)
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background {
            overlayBlurBackground
        }
    }

    @ViewBuilder
    private var overlayBlurBackground: some View {
        ZStack {
            // Blur layer
            Rectangle()
                .fill(.ultraThinMaterial)
            // Darkening layer for text contrast
            Rectangle()
                .fill(.black.opacity(0.7))                
        }
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black.opacity(0.5), location: 0.4),
                    .init(color: .black, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Image View

    @ViewBuilder
    private var imageView: some View {
        switch style.imageSize {
        case .auto(let maxWidth):
            AsyncImage(url: app.imageURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: style.imageCornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: maxWidth, height: maxWidth * 0.8)
                        .overlay { ProgressView() }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    placeholderView(width: maxWidth, height: maxWidth * 0.8)
                @unknown default:
                    placeholderView(width: maxWidth, height: maxWidth * 0.8)
                }
            }
            .frame(maxWidth: maxWidth)

        case .square(let size):
            fixedSizeImage(width: size, height: size)

        case .fixed(let width, let height):
            fixedSizeImage(width: width, height: height)
        }
    }

    @ViewBuilder
    private func fixedSizeImage(width: CGFloat, height: CGFloat) -> some View {
        AsyncImage(url: app.imageURL) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: style.imageCornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .overlay { ProgressView() }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                placeholderView(width: width, height: height)
            @unknown default:
                placeholderView(width: width, height: height)
            }
        }
        .frame(width: width, height: height)
    }

    @ViewBuilder
    private func placeholderView(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: style.imageCornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
    }
}
