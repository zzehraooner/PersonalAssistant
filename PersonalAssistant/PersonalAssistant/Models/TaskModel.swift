//
//  TaskModel.swift
//  PersonalAssistant
//
//  Created by Zehra on 29.11.2025.
//

import Foundation
import FirebaseFirestoreSwift

struct TaskModel: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var details: String
    var date: Date
    var isCompleted: Bool
    var priority: Int
    var userId: String
    
    // Varsayılan init
    init(id: String? = nil, title: String, details: String = "", date: Date = Date(), isCompleted: Bool = false, priority: Int = 1, userId: String) {
        self.id = id
        self.title = title
        self.details = details
        self.date = date
        self.isCompleted = isCompleted
        self.priority = priority
        self.userId = userId
    }
}
