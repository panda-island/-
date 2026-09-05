import Foundation
import SwiftUI

/// A local-first ledger stored in Keychain so it survives an App reinstall.
@MainActor
final class LedgerStore: ObservableObject {
    static let shared = LedgerStore()

    @Published private(set) var entries: [LedgerEntry]
    @Published private(set) var categories: [LedgerCategory]
    @Published var persistenceMessage: String?

    private let encoder: JSONEncoder
    private let decoder = JSONDecoder()

    private init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        let snapshot = Self.loadSnapshot() ?? LedgerSnapshot()
        entries = snapshot.entries.sorted { $0.date > $1.date }
        categories = snapshot.categories.isEmpty ? LedgerCategory.defaults : snapshot.categories
    }

    var balance: Decimal {
        entries.reduce(0) { partial, entry in
            partial + (entry.kind == .income ? entry.amount : -entry.amount)
        }
    }

    var monthlyExpenses: Decimal {
        let calendar = Calendar.current
        return entries.filter { $0.kind == .expense && calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    func addEntry(kind: TransactionKind, amount: Decimal, merchant: String, category: String, date: Date, note: String = "") {
        guard amount > 0 else {
            persistenceMessage = "金額必須大於 0"
            return
        }
        let cleanedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        if !categories.contains(where: { $0.name.caseInsensitiveCompare(cleanedCategory) == .orderedSame }) {
            addCategory(name: cleanedCategory.isEmpty ? "雜項" : cleanedCategory)
        }
        entries.insert(LedgerEntry(kind: kind, amount: amount, merchant: merchant.trimmingCharacters(in: .whitespacesAndNewlines), category: cleanedCategory.isEmpty ? "雜項" : cleanedCategory, date: date, note: note), at: 0)
        persist()
    }

    func addExpenseFromShortcut(amount: Double, merchant: String, category: String?, date: Date?) async throws -> String {
        guard amount > 0 else { throw LedgerIntentError.invalidAmount }
        let supplied = category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let resolvedCategory: String
        if supplied.isEmpty {
            resolvedCategory = await MerchantClassifier.suggest(for: merchant, allowedCategories: categories.map(\.name))
        } else {
            resolvedCategory = supplied
        }
        addEntry(kind: .expense, amount: Decimal(amount), merchant: merchant, category: resolvedCategory, date: date ?? .now)
        return resolvedCategory
    }

    func delete(_ entry: LedgerEntry) {
        entries.removeAll { $0.id == entry.id }
        persist()
    }

    func addCategory(name: String, symbol: String = "tag.fill", tintName: String = "indigo") {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !categories.contains(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) else { return }
        categories.append(LedgerCategory(name: name, symbol: symbol, tintName: tintName))
        persist()
    }

    func deleteCategory(_ category: LedgerCategory) {
        guard !category.isBuiltIn else { return }
        categories.removeAll { $0.id == category.id }
        entries = entries.map { entry in
            var entry = entry
            if entry.category == category.name { entry.category = "雜項" }
            return entry
        }
        persist()
    }

    func category(named name: String) -> LedgerCategory? {
        categories.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }

    func persist() {
        let snapshot = LedgerSnapshot(entries: entries, categories: categories, updatedAt: .now)
        guard let data = try? encoder.encode(snapshot) else {
            persistenceMessage = "資料編碼失敗"
            return
        }
        do {
            try KeychainLedgerVault.save(data)
        } catch {
            persistenceMessage = "本機 Keychain 儲存失敗：\(error.localizedDescription)"
        }
    }

    private static func loadSnapshot() -> LedgerSnapshot? {
        guard let data = KeychainLedgerVault.load() else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(LedgerSnapshot.self, from: data)
    }
}

enum LedgerIntentError: LocalizedError {
    case invalidAmount

    var errorDescription: String? { "金額必須大於 0" }
}
