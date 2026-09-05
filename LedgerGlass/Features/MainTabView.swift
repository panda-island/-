import SwiftUI

struct MainTabView: View {
    @State private var showingNewEntry = false

    var body: some View {
        TabView {
            DashboardView(showingNewEntry: $showingNewEntry)
                .tabItem { Label("總覽", systemImage: "rectangle.3.group.fill") }
            RecordsView(showingNewEntry: $showingNewEntry)
                .tabItem { Label("記錄", systemImage: "list.bullet.rectangle") }
            InsightsView()
                .tabItem { Label("統計", systemImage: "chart.xyaxis.line") }
            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
        }
        .tint(.indigo)
        .sheet(isPresented: $showingNewEntry) { EntryEditorView() }
    }
}

@available(iOS 26.0, *)
private struct NativeGlassCard: ViewModifier {
    let radius: CGFloat
    func body(content: Content) -> some View {
        content.glassEffect(.regular, in: .rect(cornerRadius: radius))
    }
}

struct GlassCard: ViewModifier {
    var radius: CGFloat = 24
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.modifier(NativeGlassCard(radius: radius))
        } else {
            content.background(.thinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }
}

extension View {
    func ledgerGlass(radius: CGFloat = 24) -> some View {
        modifier(GlassCard(radius: radius))
    }
}

