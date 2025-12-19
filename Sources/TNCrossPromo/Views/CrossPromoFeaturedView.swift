import SwiftUI

/// Horizontal scrolling carousel of featured apps
public struct CrossPromoFeaturedView: View {
    @Bindable var viewModel: CrossPromoViewModel
    let style: CrossPromoStyleConfiguration
    let onShowAll: (() -> Void)?

    public init(
        viewModel: CrossPromoViewModel,
        style: CrossPromoStyleConfiguration = .default,
        onShowAll: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.style = style
        self.onShowAll = onShowAll
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: style.spacing) {
            // Header with optional title and "Show All" button
            if style.sectionTitle != nil || onShowAll != nil {
                headerView
            }

            // Content
            contentView
        }
        .task {
            await viewModel.loadApps()
        }
    }

    @ViewBuilder
    private var headerView: some View {
        HStack {
            if let title = style.sectionTitle {
                Text(title)
                    .font(.headline)
            }

            Spacer()

            if let onShowAll, !viewModel.apps.isEmpty {
                Button(style.showAllButtonTitle) {
                    onShowAll()
                }
                .font(.subheadline)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.featuredApps.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
                .frame(height: style.imageSize.imageHeight + 60)
        } else if viewModel.featuredApps.isEmpty {
            // Show nothing if no featured apps (graceful degradation)
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: style.spacing) {
                    ForEach(viewModel.featuredApps) { app in
                        PromoAppCard(app: app, style: style) {
                            viewModel.openApp(app)
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollClipDisabled()
        }
    }
}
