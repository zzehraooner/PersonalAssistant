//
//  HabitsModel.swift
//  PersonalAssistant
//
//  Created by Zehra on 29.11.2025.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct HabitModel: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var icon: String
    var userId: String
    var creationDate: Date
    var lastCompletionDate: Date? // Serinin kırılmaması için son tamamlanma tarihi
    var streak: Int
    
    // Alışkanlığın bugün tamamlanıp tamamlanmadığını kontrol eder (hesaplanan değer)
    var isCompletedToday: Bool {
        guard let lastCompletionDate = lastCompletionDate else { return false }
        return Calendar.current.isDateInToday(lastCompletionDate)
    }
    
    init(id: String? = nil, title: String, icon: String, userId: String, streak: Int = 0) {
        self.id = id
        self.title = title
        self.icon = icon
        self.userId = userId
        self.creationDate = Date()
        self.streak = streak
    }
}
