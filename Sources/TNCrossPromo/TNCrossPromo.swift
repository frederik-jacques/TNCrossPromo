import SwiftUI

/// Main entry point for the TNCrossPromo library
public enum TNCrossPromo {
    /// Creates a configured view model for cross-promotion
    @MainActor
    public static func createViewModel(
        configuration: CrossPromoConfiguration
    ) -> CrossPromoViewModel {
        CrossPromoViewModel(configuration: configuration)
    }

    /// Convenience method to create a featured view with a new view model
    @MainActor
    public static func featuredView(
        configuration: CrossPromoConfiguration,
        style: CrossPromoStyleConfiguration = .default,
        onShowAll: (() -> Void)? = nil
    ) -> some View {
        let viewModel = createViewModel(configuration: configuration)
        return CrossPromoFeaturedView(
            viewModel: viewModel,
            style: style,
            onShowAll: onShowAll
        )
    }

    /// Convenience method to create a list view with a new view model
    @MainActor
    public static func listView(
        configuration: CrossPromoConfiguration,
        style: CrossPromoStyleConfiguration = .default
    ) -> some View {
        let viewModel = createViewModel(configuration: configuration)
        return CrossPromoListView(
            viewModel: viewModel,
            style: style
        )
    }
}
