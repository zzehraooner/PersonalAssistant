import Foundation
import SwiftUI
import Combine

class ChatService: ObservableObject {
    @Published var isTyping = false
    
    func sendMessage(_ text: String) async throws -> String {
        // UI güncellemelerini ana iş parçacığında yapıyoruz
        await MainActor.run { isTyping = true }
        
        // Ağ gecikmesi simülasyonu (1.5 saniye)
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run { isTyping = false }
        return generateResponse(for: text)
    }
    
    private func generateResponse(for text: String) -> String {
        let lowerText = text.lowercased()
        
        if lowerText.contains("merhaba") || lowerText.contains("selam") {
            return "Merhaba! Bugün sana nasıl yardımcı olabilirim?"
        } else if lowerText.contains("plan") || lowerText.contains("program") {
            return "Günlük planını gözden geçirmek ister misin? Takvimine yeni bir etkinlik ekleyebilirim."
        } else if lowerText.contains("nasılsın") {
            return "Ben bir yapay zekayım, ama harika hissediyorum! Senin günün nasıl geçiyor?"
        } else if lowerText.contains("hatırlat") {
            return "Tamam, neyi hatırlatmamı istersin? Lütfen detayları ver."
        } else {
            return "Bunu not aldım. Başka yapabileceğim bir şey var mı?"
        }
    }
}
