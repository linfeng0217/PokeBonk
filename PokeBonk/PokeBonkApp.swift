import SwiftUI

@main
struct PokeBonkApp: App {
    var body: some Scene {
        WindowGroup {
            WebGameView()
                .ignoresSafeArea()
                .statusBarHidden(true)
        }
    }
}
