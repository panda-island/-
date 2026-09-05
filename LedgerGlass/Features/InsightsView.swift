import Charts
import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var ledger: LedgerStore

    private var categoryTotals: [(name: String, amount: Double)] {
        Dictionary(grouping: ledger.entries.filter { $0.kind == .expense }, by: \.category)
            .map { ($0.key, NSDecimalNumber(decimal: $0.value.reduce(0) { $0 + $1.amount }).doubleValue) }
            .sorted { $0.amount > $1.amount }
    }

    private var dailyTotals: [(day: Date, amount: Double)] {
        let calendar = Calendar.current
        return Dictionary(grouping: ledger.entries.filter { $0.kind == .expense }, by: { calendar.startOfDay(for: $0.date) })
            .map { ($0.key, NSDecimalNumber(decimal: $0.value.reduce(0) { $0 + $1.amount }).doubleValue) }
            .sorted { $0.day < $1.day }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if categoryTotals.isEmpty {
                    ContentUnavailableView("尚無統計資料", systemImage: "chart.pie", description: Text("新增支出後，這裡會顯示分類占比與趨勢。"))
                        .padding(.top, 120)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("支出分類").font(.title3.weight(.bold))
                        Chart(categoryTotals, id: \.name) { item in
                            SectorMark(angle: .value("金額", item.amount), innerRadius: .ratio(0.62), angularInset: 2)
                                .foregroundStyle(by: .value("類別", item.name))
                        }
                        .frame(height: 230)
                        .chartLegend(position: .bottom, alignment: .leading)
                        .padding()
                        .ledgerGlass()

                        Text("每日趨勢").font(.title3.weight(.bold))
                        Chart(dailyTotals, id: \.day) { item in
                            AreaMark(x: .value("日期", item.day), y: .value("支出", item.amount))
                                .foregroundStyle(.indigo.opacity(0.18))
                            LineMark(x: .value("日期", item.day), y: .value("支出", item.amount))
                                .foregroundStyle(.indigo).interpolationMethod(.catmullRom)
                        }
                        .frame(height: 210)
                        .chartYAxis { AxisMarks(position: .leading) }
                        .padding()
                        .ledgerGlass()
                    }
                    .padding()
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("統計")
        }
    }
}

