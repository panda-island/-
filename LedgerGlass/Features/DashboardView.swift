import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var ledger: LedgerStore
    @Binding var showingNewEntry: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    balanceCard
                    HStack(spacing: 12) {
                        metric(title: "本月支出", value: ledger.monthlyExpenses.currencyText, icon: "arrow.down.right", color: .orange)
                        metric(title: "本月筆數", value: "\(ledger.entries.filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) }.count)", icon: "list.number", color: .indigo)
                    }
                    recentSection
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("記帳")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNewEntry = true } label: {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                    }
                    .accessibilityLabel("新增記帳")
                }
            }
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("目前結餘", systemImage: "wallet.pass.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(ledger.balance.currencyText)
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
            Text("本機 Keychain 儲存 · 重裝可保留")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: [.indigo.opacity(0.9), .purple.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .foregroundStyle(.white)
        .shadow(color: .indigo.opacity(0.22), radius: 18, y: 10)
    }

    private func metric(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(color).font(.title3.weight(.semibold))
            Text(value).font(.headline.monospacedDigit())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .ledgerGlass(radius: 20)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("最近記錄").font(.title3.weight(.bold))
                Spacer()
                Text("\(ledger.entries.count) 筆").font(.caption).foregroundStyle(.secondary)
            }
            if ledger.entries.isEmpty {
                ContentUnavailableView("還沒有記錄", systemImage: "tray", description: Text("點右上角＋或用捷徑新增第一筆支出。"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .ledgerGlass(radius: 20)
            } else {
                ForEach(ledger.entries.prefix(5)) { entry in
                    EntryRow(entry: entry)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .ledgerGlass(radius: 18)
                }
            }
        }
    }
}
