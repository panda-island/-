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
3. 在 Apple Developer 網站建立相同的 App ID 與 development provisioning profile。
4. 用 GitHub Actions 產生 IPA，安裝到 iPhone 後，在「捷徑」搜尋「新增支出」即可加入捷徑。

Windows 簽章檔的建立與 GitHub Secrets 的貼入方式，請看 [Windows 建置指南](docs/windows-github-ipa.md)。

### GitHub 產生可安裝 IPA

工作流程位於 `.github/workflows/build-ipa.yml`。在 GitHub repository 的 **Settings → Secrets and variables → Actions** 加入：

| Secret | 內容 |
| --- | --- |
| `IOS_CERTIFICATE_BASE64` | Apple Development 憑證 `.p12` 的 Base64 |
| `IOS_CERTIFICATE_PASSWORD` | `.p12` 密碼 |
| `IOS_PROVISION_PROFILE_BASE64` | 對應 provisioning profile 的 Base64 |
| `KEYCHAIN_PASSWORD` | CI 暫用 keychain 密碼 |
| `APPLE_TEAM_ID` | 十碼 Apple Team ID |

在 Actions 手動執行 **Build IPA** 並勾選 `signed_ipa`，即可下載 `LedgerGlass-IPA` artifact。Apple 的簽章是可安裝 IPA 的必要條件；未提供憑證時，流程仍會驗證 simulator build，但不會偽造一個不能安裝的 IPA。你不需要 Mac：可在 Windows 產生 CSR／`.p12`、在 Apple Developer 網站下載 provisioning profile，並把它們設為 GitHub Secrets。

> bundle identifier 與 provisioning profile 必須完全相同；否則 archive 會被 Apple 簽章拒絕。

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
