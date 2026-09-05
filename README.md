# Ledger Glass

一個可只用 Windows + GitHub 維護的 iOS 26 記帳 App。支出可由「捷徑」在背景或鎖定畫面新增，也可在 App 中手動管理收入、支出、類別、統計、趨勢及搜尋。

## 重要特性

- **捷徑直接新增支出**：輸入金額、商家、類別與日期時間；日期可省略而使用目前時間。
- **自動分類**：先以常見商家規則辨識；未辨識時，在支援 Apple Intelligence 的裝置上會請系統模型只從你的類別中建議一項。7-ELEVEN、全家等便利商店預設歸為「飲食」。
- **鎖定畫面可用**：捷徑 Intent 不開啟 App，資料檔採「第一次解鎖後可存取」保護等級，因此當天首次解鎖後可於背景執行。
- **本機優先、可復原**：記帳資料存在 iPhone Keychain，不需要 iCloud capability；以相同 bundle identifier 重新安裝時可繼續讀取，也會納入加密備份。
- **Liquid Glass**：以 iOS 26 的 `glassEffect` 呈現半透明、層次化介面；系統不支援時自然退回標準材質。

## 開始使用

這個專案使用 [XcodeGen](https://github.com/yonaskolb/XcodeGen) 產生 Xcode 專案，避免把大量 Xcode 使用者設定提交到 Git。

1. 將此資料夾建立為 GitHub repository 並推送。
2. 將 `project.yml` 的 `com.example.ledgerglass` 改為自己的 bundle identifier（例如 `com.你的英文名稱.ledger`）。
3. 用 GitHub Actions 產生 IPA，再用自己的 sideload 工具安裝到 iPhone；首次開啟後，在「捷徑」搜尋「新增支出」即可加入捷徑。

### GitHub 產生 sideload IPA

工作流程位於 `.github/workflows/build-ipa.yml`，不需要 Apple Developer 會員、簽章憑證、provisioning profile 或 GitHub Secrets。

1. 將專案推送到 GitHub。
2. 開啟 **Actions → Build Sideload IPA → Run workflow**。
3. 完成後在 Artifacts 下載 `LedgerGlass-sideload-IPA`。
4. 將下載的 `LedgerGlass-sideload.ipa` 交給自己的 sideload 工具重新簽名並安裝。

> 這是未簽名的 device IPA，不能直接點開安裝；sideload 工具會使用你的 Apple ID 在安裝時簽名。這正是此流程設計的用途。

## 捷徑輸入對應

| 捷徑欄位 | 行為 |
| --- | --- |
| 金額 | 必填、必須大於 0 |
| 商家 | 必填，例如 `全家便利商店` |
| 類別 | 可留白；留白時自動判斷 |
| 日期時間 | 可留白；留白時使用現在 |

## 專案結構

- `LedgerGlass/App`：App 入口、資料模型與本機 Keychain 儲存
- `LedgerGlass/Intents`：Siri / Shortcuts 的背景新增支出 Intent
- `LedgerGlass/Features`：儀表板、記錄、統計、設定與手動輸入畫面
- `project.yml`：XcodeGen 設定
