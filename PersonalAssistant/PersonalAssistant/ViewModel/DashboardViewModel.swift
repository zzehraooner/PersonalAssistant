import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

// MARK: - Activity Model
// Dashboard'daki karışık listeyi (Görev + Finans) göstermek için model
struct ActivityItem: Identifiable, Equatable {
    let id: String
    let icon: String
    let title: String
    let time: Date
    let timeString: String
    let details: String
    let type: String
}

final class DashboardViewModel: ObservableObject {
    // Özet Kart Verileri
    @Published var taskCount: Int = 0        // Tüm Kalan Görevler (Tarih fark etmeksizin)
    @Published var totalBalance: Double = 0.0 // Güncel Bakiye
    @Published var streakDays: Int = 0       // En Yüksek Alışkanlık Serisi
    @Published var pendingReminders: Int = 0 // Sadece Bugünün Bekleyen Görevleri

    // Son Aktiviteler Listesi
    @Published var recentActivities: [ActivityItem] = []

    // Firestore
    private var db = Firestore.firestore()
    private var taskListener: ListenerRegistration?
    private var financeListener: ListenerRegistration?
    private var habitListener: ListenerRegistration? // ✅ Seri takibi için eklendi
    
    // Geçici veri dizileri (Hesaplamalar için)
    private var currentTasks: [TaskModel] = []
    private var currentTransactions: [TransactionModel] = []

    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    init() {
        // Kullanıcı oturum durumunu dinle
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            // Eski dinleyicileri temizle
            self?.taskListener?.remove()
            self?.financeListener?.remove()
            self?.habitListener?.remove()
            
            if let uid = user?.uid {
                self?.fetchDashboardData(for: uid)
            } else {
                self?.resetData()
            }
        }
    }
    
    deinit {
        taskListener?.remove()
        financeListener?.remove()
        habitListener?.remove()
    }
    
    private func resetData() {
        self.taskCount = 0
        self.totalBalance = 0.0
        self.streakDays = 0
        self.pendingReminders = 0
        self.recentActivities = []
    }

    // MARK: - Veri Çekme Fonksiyonları
    
    func fetchDashboardData(for uid: String) {
        guard !uid.isEmpty else { return }
        
        // 1. GÖREVLERİ DİNLE
        taskListener = db.collection("users").document(uid).collection("tasks")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let documents = snapshot?.documents else { return }

                self.currentTasks = documents.compactMap { try? $0.data(as: TaskModel.self) }
                
                // A) Kalan Görevler: Tarih fark etmeksizin TÜM bitmemiş görevler
                let totalUnfinished = self.currentTasks.filter { !$0.isCompleted }.count
                
                // B) Bekleyen (Bugün): Sadece BUGÜNE ait ve bitmemiş görevler
                let todayPending = self.currentTasks.filter { task in
                    !task.isCompleted && Calendar.current.isDateInToday(task.date)
                }.count
                
                DispatchQueue.main.async {
                    self.taskCount = totalUnfinished
                    self.pendingReminders = todayPending
                }
                
                self.updateRecentActivities()
            }
        
        // 2. FİNANS İŞLEMLERİNİ DİNLE
        financeListener = db.collection("users").document(uid).collection("transactions")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let documents = snapshot?.documents else { return }

                self.currentTransactions = documents.compactMap { try? $0.data(as: TransactionModel.self) }

                // Bakiye Hesaplama: Gelirler (+) Giderler (-)
                let balance = self.currentTransactions.reduce(0.0) { result, transaction in
                    transaction.isIncome ? result + transaction.amount : result - transaction.amount
                }
                
                DispatchQueue.main.async {
                    self.totalBalance = balance
                }
                
                self.updateRecentActivities()
            }
            
        // 3. ALIŞKANLIKLARI (SERİ) DİNLE ✅
        // Alışkanlıklar koleksiyonunu dinleyip en yüksek seriyi buluyoruz
        habitListener = db.collection("users").document(uid).collection("habits")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                var maxStreak = 0
                
                for doc in documents {
                    let data = doc.data()
                    // Firestore'daki 'streak' alanını okuyoruz
                    if let streak = data["streak"] as? Int {
                        if streak > maxStreak {
                            maxStreak = streak
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.streakDays = maxStreak // En yüksek seriyi Dashboard'a yansıt
                }
            }
    }
    
    // MARK: - Aktiviteleri Birleştirme ve Sıralama
    private func updateRecentActivities() {
        var combined: [ActivityItem] = []
        
        // İlk 5 Görevi Ekle
        for task in currentTasks.prefix(5) {
            let icon = task.isCompleted ? "checkmark.circle.fill" : "calendar"
            let details = task.isCompleted ? "Tamamlandı" : "Planlandı"
            
            let formattedTime = task.date.formatted(date: .omitted, time: .shortened)
            
            combined.append(ActivityItem(
                id: task.id ?? UUID().uuidString,
                icon: icon,
                title: task.title,
                time: task.date,
                timeString: formattedTime,
                details: details,
                type: "task"
            ))
        }
        
        // İlk 5 Finans İşlemini Ekle
        for trans in currentTransactions.prefix(5) {
            let icon = trans.isIncome ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill"
            let details = "\(trans.isIncome ? "+" : "-")₺\(String(format: "%.0f", trans.amount))"
            let formattedTime = trans.date.formatted(date: .omitted, time: .shortened)
            
            combined.append(ActivityItem(
                id: trans.id ?? UUID().uuidString,
                icon: icon,
                title: trans.title,
                time: trans.date,
                timeString: formattedTime,
                details: details,
                type: trans.isIncome ? "income" : "expense"
            ))
        }
        
        // Tarihe göre yeniden sırala (En yeni en üstte)
        combined.sort { $0.time > $1.time }
        
        // Ekrana sadece en son 5 karışık aktiviteyi ver
        DispatchQueue.main.async {
            self.recentActivities = Array(combined.prefix(5))
        }
    }
}
