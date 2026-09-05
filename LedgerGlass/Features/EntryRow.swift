import SwiftUI

struct EntryRow: View {
    @EnvironmentObject private var ledger: LedgerStore
    let entry: LedgerEntry

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: ledger.category(named: entry.category)?.symbol ?? "tag.fill")
                .font(.headline)
                .foregroundStyle(entry.kind == .expense ? .orange : .green)
                .frame(width: 34, height: 34)
                .background((entry.kind == .expense ? Color.orange : .green).opacity(0.13), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.merchant.isEmpty ? entry.category : entry.merchant).font(.body.weight(.medium))
                Text("\(entry.category) · \(entry.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Text("\(entry.kind == .expense ? "−" : "+")\(entry.amount.currencyText)")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(entry.kind == .expense ? .primary : .green)
        }
        .padding(.vertical, 4)
    }
}

