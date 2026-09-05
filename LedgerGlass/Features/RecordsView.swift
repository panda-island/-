import SwiftUI

struct RecordsView: View {
    @EnvironmentObject private var ledger: LedgerStore
    @Binding var showingNewEntry: Bool
    @State private var query = ""
    @State private var kindFilter: TransactionKind?

    private var filteredEntries: [LedgerEntry] {
        ledger.entries.filter { entry in
            let matchesKind = kindFilter == nil || entry.kind == kindFilter
            let haystack = "\(entry.merchant) \(entry.category) \(entry.note)"
            return matchesKind && (query.isEmpty || haystack.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("篩選", selection: $kindFilter) {
                        Text("全部").tag(TransactionKind?.none)
                        ForEach(TransactionKind.allCases) { Text($0.title).tag(Optional($0)) }
                    }
                    .pickerStyle(.segmented)
                }
                if filteredEntries.isEmpty {
                    ContentUnavailableView.search(text: query)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredEntries) { entry in
                        EntryRow(entry: entry)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) { ledger.delete(entry) } label: { Label("刪除", systemImage: "trash") }
                            }
                    }
                }
            }
            .navigationTitle("記錄")
            .searchable(text: $query, prompt: "搜尋商家、類別或備註")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showingNewEntry = true } label: { Image(systemName: "plus") } } }
        }
    }
}

