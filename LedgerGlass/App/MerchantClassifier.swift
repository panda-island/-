import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

enum MerchantClassifier {
    /// Fast, offline rules cover the merchants most likely to be entered from a shortcut.
    /// Apple Intelligence is used only after the deterministic rules cannot decide.
    static func suggest(for merchant: String, allowedCategories: [String]) async -> String {
        let normalized = merchant.uppercased().replacingOccurrences(of: " ", with: "")
        let rules: [(String, String)] = [
            ("7-ELEVEN", "飲食"), ("7ELEVEN", "飲食"), ("統一超商", "飲食"),
            ("全家", "飲食"), ("FAMILYMART", "飲食"), ("萊爾富", "飲食"), ("OK超商", "飲食"),
            ("STARBUCKS", "飲料"), ("星巴克", "飲料"), ("五十嵐", "飲料"), ("清心", "飲料"),
            ("COCO", "飲料"), ("可不可", "飲料"), ("麻古", "飲料"),
            ("UBEREATS", "飲食"), ("FOODPANDA", "飲食"), ("麥當勞", "飲食"),
            ("肯德基", "飲食"), ("餐廳", "飲食"), ("便當", "飲食"), ("小吃", "飲食")
        ]
        if let match = rules.first(where: { normalized.contains($0.0) }), allowedCategories.contains(match.1) {
            return match.1
        }

        if #available(iOS 26.0, *), let result = await AppleIntelligenceCategorySuggestion.suggest(merchant: merchant, allowedCategories: allowedCategories) {
            return result
        }
        return allowedCategories.contains("雜項") ? "雜項" : (allowedCategories.first ?? "雜項")
    }
}

@available(iOS 26.0, *)
private enum AppleIntelligenceCategorySuggestion {
    static func suggest(merchant: String, allowedCategories: [String]) async -> String? {
        #if canImport(FoundationModels)
        let choices = allowedCategories.joined(separator: "、")
        let prompt = "商家名稱是「\(merchant)」。只從這些記帳類別選擇最可能的一項：\(choices)。只回答類別名稱，不要說明。若無法判斷，回答雜項。"
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            let answer = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return allowedCategories.first { answer.localizedCaseInsensitiveContains($0) }
        } catch {
            return nil
        }
        #else
        return nil
        #endif
    }
}
