import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Protocol for URL opening, enabling testability
protocol URLOpening: Sendable {
    @MainActor
    func open(_ url: URL)
}

/// Platform-specific implementation for opening URLs
final class SystemURLOpener: URLOpening {
    @MainActor
    func open(_ url: URL) {
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #elseif canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }
}
