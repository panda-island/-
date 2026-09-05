import SwiftUI

@main
struct LedgerGlassApp: App {
    @StateObject private var ledger = LedgerStore.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(ledger)
        }
    }
}
