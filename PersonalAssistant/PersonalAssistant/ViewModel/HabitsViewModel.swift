//
//  HabitsViewModel.swift
//  PersonalAssistant
//
//  Created by Zehra on 29.11.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

class HabitsViewModel: ObservableObject {
    @Published var habits: [HabitModel] = []
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    init() {
        // Oturum durumunu dinle ve değişirse verileri temizle/çek
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.listenerRegistration?.remove()
            if let uid = user?.uid {
                self?.fetchHabits(for: uid)
            } else {
                self?.habits = []
            }
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    // MARK: - Firestore Listener
    func fetchHabits(for uid: String) {
        listenerRegistration = db.collection("users").document(uid).collection("habits")
            .order(by: "creationDate", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Firestore Alışkanlık Çekme Hatası: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.habits = documents.compactMap { doc -> HabitModel? in
                    try? doc.data(as: HabitModel.self)
                }
            }
    }
    
    // MARK: - CRUD & Seriler
    
    func addHabit(title: String, icon: String) {
        guard let uid = userId else { return }
        
        let newHabit = HabitModel(title: title, icon: icon, userId: uid)
        
        do {
            let _ = try db.collection("users").document(uid).collection("habits").addDocument(from: newHabit)
        } catch {
            print("Firestore Alışkanlık Ekleme Hatası: \(error.localizedDescription)")
        }
    }
    
    func deleteHabit(habit: HabitModel) {
        guard let uid = userId, let habitId = habit.id else { return }
        
        db.collection("users").document(uid).collection("habits").document(habitId).delete()
    }
    
    func toggleHabitCompletion(habit: HabitModel) {
        guard let uid = userId, let habitId = habit.id else { return }
        
        var newStreak = habit.streak
        var newLastCompletionDate: Date? = nil
        
        if habit.isCompletedToday {
            // Bugün tamamlanmışsa, iptal ediliyor.
            newStreak -= 1
            newLastCompletionDate = nil // İleride daha karmaşık hesaplama gerekebilir
            
            // Not: İptal edildiğinde serinin kırılma mantığı burada daha detaylı incelenmelidir.
        } else {
            // Bugün tamamlanmamışsa, tamamlanıyor.
            newStreak += 1
            newLastCompletionDate = Date()
        }
        
        db.collection("users").document(uid).collection("habits").document(habitId)
            .updateData([
                "streak": newStreak,
                "lastCompletionDate": newLastCompletionDate as Any
            ]) { error in
                if let error = error {
                    print("Firestore Alışkanlık Güncelleme Hatası: \(error.localizedDescription)")
                }
            }
    }
}
