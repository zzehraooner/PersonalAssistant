import SwiftUI
import FirebaseAuth

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PlannerViewModel // ViewModel'i dışarıdan alıyoruz
    
    var defaultDate: Date
    
    // MARK: - State Değişkenleri (Form Alanları)
    @State private var title = ""
    @State private var details = ""
    @State private var date: Date
    @State private var priority = 1 // 0: Düşük, 1: Orta, 2: Yüksek
    
    // Init: Seçilen tarihi varsayılan olarak ayarlamak için
    init(defaultDate: Date, viewModel: PlannerViewModel) {
        self.defaultDate = defaultDate
        self.viewModel = viewModel
        // State değişkenini init içinde başlatmak için alt çizgi (_) kullanılır
        self._date = State(initialValue: defaultDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 1. Bölüm: Metin Girişleri
                Section(header: Text("Görev Bilgileri")) {
                    TextField("Başlık (Örn: Toplantı)", text: $title)
                    
                    // Not/Detay alanı
                    TextField("Not (İsteğe bağlı)", text: $details)
                }
                
                // 2. Bölüm: Tarih ve Öncelik Seçimi
                Section(header: Text("Zamanlama")) {
                    DatePicker("Tarih", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Öncelik", selection: $priority) {
                        Text("Düşük").tag(0)
                        Text("Orta").tag(1)
                        Text("Yüksek").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Yeni Görev")
            .toolbar {
                // İptal Butonu (Sol)
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                
                // Ekle Butonu (Sağ)
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        saveTask()
                    }
                    .disabled(title.isEmpty) // Başlık boşsa buton pasif olur
                }
            }
        }
    }
    
    // Görevi Kaydetme Fonksiyonu
    private func saveTask() {
        // Kullanıcı giriş yapmış mı kontrol et
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Yeni TaskModel oluştur
        let newTask = TaskModel(
            title: title,
            details: details,
            date: date,
            isCompleted: false,
            priority: priority,
            userId: uid
        )
        
        // ViewModel üzerinden Firestore'a kaydet
        viewModel.addTask(task: newTask)
        
        // Sayfayı kapat
        dismiss()
    }
}
