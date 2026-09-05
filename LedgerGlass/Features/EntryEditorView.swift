import SwiftUI

struct EntryEditorView: View {
    @EnvironmentObject private var ledger: LedgerStore
    @Environment(\.dismiss) private var dismiss
    @State private var kind: TransactionKind = .expense
    @State private var amountText = ""
    @State private var merchant = ""
    @State private var category = "飲食"
    @State private var date = Date.now
    @State private var note = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("類型", selection: $kind) {
                        ForEach(TransactionKind.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("內容") {
                    TextField("金額", text: $amountText)
                        .keyboardType(.decimalPad)
                    TextField(kind == .expense ? "商家" : "收入來源", text: $merchant)
                    Picker("類別", selection: $category) {
                        ForEach(ledger.categories) { category in
                            Label(category.name, systemImage: category.symbol).tag(category.name)
                        }
                    }
                    DatePicker("日期時間", selection: $date)
                }
                Section("備註") { TextField("選填", text: $note, axis: .vertical) }
                if let validationMessage {
                    Section { Label(validationMessage, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.red) }
                }
            }
            .navigationTitle("新增記帳")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("儲存", action: save).fontWeight(.semibold) }
            }
        }
    }

    private func save() {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        let normalized = amountText.replacingOccurrences(of: ",", with: "")
        guard let value = formatter.number(from: normalized)?.decimalValue ?? Decimal(string: normalized), value > 0 else {
            validationMessage = "請輸入大於 0 的金額"
            return
        }
        ledger.addEntry(kind: kind, amount: value, merchant: merchant, category: category, date: date, note: note)
        dismiss()
    }
}

