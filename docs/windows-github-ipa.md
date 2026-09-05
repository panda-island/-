# Windows + GitHub 產生 IPA

你不需要 Mac；GitHub Actions 會在雲端 macOS 主機上編譯。你仍需要有效的 Apple Developer Program 會員資格，因為只有 Apple 能為 iPhone App 簽章。

## 1. 建立 App ID 與測試裝置

1. 到 [Apple Developer Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) 建立一個 App ID。
2. Identifier 必須和 `project.yml` 的 `PRODUCT_BUNDLE_IDENTIFIER` 一字不差，例如 `com.yourname.ledgerglass`。
3. 在 Devices 加入要測試的 iPhone UDID。

## 2. 在 Windows 建立憑證

安裝 Git for Windows 後，開啟 **Git Bash**，在不會上傳 GitHub 的資料夾中執行。請把姓名與 email 改成自己的資料，並妥善保存 `.key` 檔；遺失它就不能再建立同一張 `.p12`。

```bash
openssl req -new -newkey rsa:2048 -nodes \
  -keyout ios-signing.key -out ios-signing.csr \
  -subj "/emailAddress=你的AppleID信箱/CN=你的姓名/C=TW"
```

將 `ios-signing.csr` 上傳到 Apple Developer 的 Certificates 頁面，建立 **Apple Development** certificate，下載得到的 `.cer` 檔後回到 Git Bash：

```bash
openssl x509 -inform DER -in development.cer -out development.pem
openssl pkcs12 -export -out ios-development.p12 \
  -inkey ios-signing.key -in development.pem
```

最後一行會要求你設定 `.p12` 密碼。請記下它，但不要把憑證、私鑰或密碼提交到 GitHub。

## 3. 建立 provisioning profile

在 Apple Developer 的 Profiles 頁面建立 **iOS App Development** profile，選擇剛才的 App ID、Apple Development certificate 與測試 iPhone，下載 `.mobileprovision`。

## 4. 設定 GitHub Secrets

在 PowerShell、且檔案位於目前資料夾時執行以下指令；每次會把一段 Base64 文字放到剪貼簿：

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("ios-development.p12")) | Set-Clipboard
```

貼到 repository 的 **Settings → Secrets and variables → Actions**，名稱為 `IOS_CERTIFICATE_BASE64`。對 profile 再做一次：

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("YourProfile.mobileprovision")) | Set-Clipboard
```

貼到 `IOS_PROVISION_PROFILE_BASE64`，然後再建立：

- `IOS_CERTIFICATE_PASSWORD`：建立 `.p12` 時設定的密碼
- `KEYCHAIN_PASSWORD`：任意新密碼，僅供 GitHub 的暫用 keychain 使用
- `APPLE_TEAM_ID`：Apple Developer 網頁上顯示的十碼 Team ID

## 5. 執行

推送專案後，到 GitHub 的 **Actions → Build IPA → Run workflow**，勾選 `signed_ipa`。完成後從 workflow 的 Artifacts 下載 `LedgerGlass-IPA`。

這是 development IPA，只能安裝到 provisioning profile 內列出的 iPhone。若要發佈給未登錄的使用者，需改用 App Store Connect/TestFlight 或 Ad Hoc distribution profile。
