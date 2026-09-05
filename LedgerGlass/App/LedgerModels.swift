import Foundation

enum TransactionKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case expense
    case income

    var id: String { rawValue }
    var title: String { self == .expense ? "支出" : "收入" }
    var symbol: String { self == .expense ? "arrow.down.circle.fill" : "arrow.up.circle.fill" }
}

struct LedgerCategory: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var name: String
    var symbol: String
    var tintName: String
    var isBuiltIn: Bool

    init(id: UUID = UUID(), name: String, symbol: String = "tag.fill", tintName: String = "indigo", isBuiltIn: Bool = false) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.tintName = tintName
        self.isBuiltIn = isBuiltIn
    }

    static let defaults = [
        LedgerCategory(name: "飲食", symbol: "fork.knife", tintName: "orange", isBuiltIn: true),
        LedgerCategory(name: "飲料", symbol: "cup.and.saucer.fill", tintName: "brown", isBuiltIn: true),
        LedgerCategory(name: "雜項", symbol: "square.grid.2x2.fill", tintName: "gray", isBuiltIn: true)
    ]
}

struct LedgerEntry: Identifiable, Codable, Hashable, Sendable {
    var id: UUID
    var kind: TransactionKind
    var amount: Decimal
    var merchant: String
    var category: String
    var date: Date
    var note: String
    var createdAt: Date

    init(
        id: UUID = UUID(), kind: TransactionKind, amount: Decimal, merchant: String,
        category: String, date: Date = .now, note: String = "", createdAt: Date = .now
    ) {
        self.id = id
        self.kind = kind
        self.amount = amount
        self.merchant = merchant
        self.category = category
        self.date = date
        self.note = note
        self.createdAt = createdAt
    }
}

struct LedgerSnapshot: Codable, Sendable {
    var schemaVersion: Int = 1
    var entries: [LedgerEntry] = []
    var categories: [LedgerCategory] = LedgerCategory.defaults
    var updatedAt: Date = .now
}

extension Decimal {
    var currencyText: String {
        formatted(.currency(code: Locale.current.currency?.identifier ?? "TWD").precision(.fractionLength(0...2)))
    }
}

