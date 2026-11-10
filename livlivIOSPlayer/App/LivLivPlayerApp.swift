import SwiftUI

@main
struct LivLivPlayerApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
        #if os(macOS)
        .defaultSize(width: 900, height: 900)
        #elseif os(visionOS)
        .defaultSize(width: 900, height: 1000)
        #endif
    }
}
