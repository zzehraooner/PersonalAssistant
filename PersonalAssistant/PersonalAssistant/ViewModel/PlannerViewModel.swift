//
//  PlannerViewModel.swift
//  PersonalAssistant
//
//  Created by Zehra on 29.11.2025.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class PlannerViewModel: ObservableObject {
    
    @Published var tasks: [TaskModel] = []
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    init() {
        // Oturum açılıysa görevleri çekmeye başla
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.listenerRegistration?.remove() // Eski dinleyiciyi durdur
            if let uid = user?.uid {
                self?.fetchTasks(for: uid)
            } else {
                self?.tasks = [] // Kullanıcı çıkış yaparsa listeyi temizle
            }
        }
    }
    
    // Uygulama kapatıldığında dinleyiciyi durdurmak için
    deinit {
        listenerRegistration?.remove()
    }
    
    // MARK: - Firestore Veri Çekme (Real-Time Listener)
    func fetchTasks(for uid: String) {
        // Kullanıcının tüm görevlerini tarihe göre sıralayarak dinle
        listenerRegistration = db.collection("users").document(uid).collection("tasks")
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Firestore Görev Çekme Hatası: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // Firestore verisini TaskModel'e çevir
                self.tasks = documents.compactMap { doc -> TaskModel? in
                    try? doc.data(as: TaskModel.self)
                }
            }
    }
    
    // MARK: - CRUD İŞLEMLERİ
    
    func addTask(task: TaskModel) {
        guard let uid = userId else { return }
        
        do {
            // Firestore'a eklerken ID'yi otomatik atar
            let _ = try db.collection("users").document(uid).collection("tasks").addDocument(from: task)
        } catch {
            print("Firestore Görev Ekleme Hatası: \(error.localizedDescription)")
        }
    }
    
    func toggleTask(task: TaskModel) {
        guard let uid = userId, let taskId = task.id else { return }
        
        // Sadece isCompleted alanını güncelle
        db.collection("users").document(uid).collection("tasks").document(taskId)
            .updateData(["isCompleted": !task.isCompleted]) { error in
                if let error = error {
                    print("Firestore Güncelleme Hatası: \(error.localizedDescription)")
                }
            }
    }
    
    func deleteTask(task: TaskModel) {
        guard let uid = userId, let taskId = task.id else { return }
        
        db.collection("users").document(uid).collection("tasks").document(taskId).delete()
    }
}
