import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var ledger: LedgerStore
    @State private var showingAddCategory = false
    @State private var newCategory = ""

    var body: some View {
        NavigationStack {
            List {
                Section("資料保護") {
                    Label("本機 Keychain 儲存", systemImage: "key.fill")
                    Text("資料保存在 iPhone Keychain。以相同 bundle identifier 重新安裝後仍能讀取；也可隨加密備份移轉至新手機。")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Section("支出類別") {
                    ForEach(ledger.categories) { category in
                        HStack {
                            Image(systemName: category.symbol).foregroundStyle(.indigo).frame(width: 25)
                            Text(category.name)
                            if category.isBuiltIn { Text("預設").font(.caption).foregroundStyle(.secondary) }
                        }
                    }
                    .onDelete { offsets in
                        offsets.map { ledger.categories[$0] }.forEach(ledger.deleteCategory)
                    }
                    Button { showingAddCategory = true } label: { Label("新增類別", systemImage: "plus.circle.fill") }
                }
                Section("捷徑") {
                    Label("新增支出", systemImage: "bolt.fill")
                    Text("在 Apple「捷徑」中搜尋「新增支出」，輸入金額、商家、類別與日期時間。類別留白時會自動判斷。")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("設定")
            .alert("新增類別", isPresented: $showingAddCategory) {
                TextField("例如：交通", text: $newCategory)
                Button("取消", role: .cancel) { newCategory = "" }
                Button("新增") { ledger.addCategory(name: newCategory); newCategory = "" }
            } message: { Text("新增後可在手動記帳與自動分類中使用。") }
            .alert("記帳", isPresented: Binding(get: { ledger.persistenceMessage != nil }, set: { if !$0 { ledger.persistenceMessage = nil } })) {
                Button("好", role: .cancel) { ledger.persistenceMessage = nil }
            } message: { Text(ledger.persistenceMessage ?? "") }
        }
    }
}
