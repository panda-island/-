import AppIntents
import Foundation

struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "新增支出"
    static var description = IntentDescription("在背景新增一筆支出；類別留白時自動依商家判斷。")
    static var openAppWhenRun = false

    @Parameter(title: "金額")
    var amount: Double

    @Parameter(title: "商家")
    var merchant: String

    @Parameter(title: "類別")
    var category: String?

    @Parameter(title: "日期時間")
    var date: Date?

    static var parameterSummary: some ParameterSummary {
        Summary("在 \(.$merchant) 新增 \(.$amount) 元支出") {
            \.$category
            \.$date
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let category = try await LedgerStore.shared.addExpenseFromShortcut(
            amount: amount, merchant: merchant, category: category, date: date
        )
        return .result(dialog: "已新增 \(merchant) 的 \(amount.formatted()) 元支出（\(category)）。")
    }
}

struct LedgerAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "用 \(.applicationName) 新增支出",
                "在 \(.applicationName) 記一筆支出",
                "用 \(.applicationName) 記帳"
            ],
            shortTitle: "新增支出",
            systemImageName: "plus.circle.fill"
        )
    }
}
