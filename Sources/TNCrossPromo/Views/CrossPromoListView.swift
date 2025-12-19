import SwiftUI

/// Full list view of all promoted apps
public struct CrossPromoListView: View {
    @Bindable var viewModel: CrossPromoViewModel
    let style: CrossPromoStyleConfiguration

    public init(
        viewModel: CrossPromoViewModel,
        style: CrossPromoStyleConfiguration = .default
    ) {
        self.viewModel = viewModel
        self.style = style
    }

    public var body: some View {
        List {
            ForEach(viewModel.apps) { app in
                Button {
                    viewModel.openApp(app)
                } label: {
                    appRow(app)
                }
                .buttonStyle(.plain)
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.apps.isEmpty {
                ProgressView()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadApps()
        }
    }

    @ViewBuilder
    private func appRow(_ app: PromoApp) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: app.imageURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: style.imageCornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: style.imageCornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                @unknown default:
                    RoundedRectangle(cornerRadius: style.imageCornerRadius)
                        .fill(Color.gray.opacity(0.2))
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: style.imageCornerRadius))

            VStack(alignment: .leading, spacing: 4) {
                Text(app.title)
                    .font(style.titleFont)
                    .foregroundStyle(.primary)

                Text(app.subtitle)
                    .font(style.subtitleFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}
