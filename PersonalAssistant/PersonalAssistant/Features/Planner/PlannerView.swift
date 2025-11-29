import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift

struct PlannerView: View {
    
    @StateObject var viewModel = PlannerViewModel() // ViewModel'i bağladık
    
    @State private var selectedDate = Date()
    @State private var showAddTask = false
    
    // Seçili güne ait görevleri filtrele
    var filteredTasks: [TaskModel] {
        viewModel.tasks.filter { task in
            Calendar.current.isDate(task.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        ZStack { // ZStack kullanarak butonu en üste koyacağız
            VStack(spacing: 0) {
                // Header (Tarih Başlığı)
                HStack {
                    VStack(alignment: .leading) {
                        Text(selectedDate.formatted(.dateTime.month().year()))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Text("Planlayıcı")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.fallbackPrimary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white)
                
                // Takvim Şeridi (Calendar Strip)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(0..<14) { day in
                            DateCard(dayOffset: day, selectedDate: $selectedDate)
                        }
                    }
                    .padding()
                }
                .background(Color.white)
                
                // Görev Listesi
                ScrollView {
                    if filteredTasks.isEmpty {
                        VStack(spacing: 15) {
                            Spacer().frame(height: 50)
                            Image(systemName: "clipboard")
                                .font(.system(size: 70))
                                .foregroundColor(.gray.opacity(0.3))
                            Text("Bu gün için plan yok.")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50)
                    } else {
                        VStack(spacing: 15) {
                            ForEach(filteredTasks) { task in
                                TaskRow(task: task, viewModel: viewModel)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.deleteTask(task: task)
                                        } label: {
                                            Label("Sil", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                        .padding(.bottom, 80) // Listenin en altı butonun altında kalmasın
                    }
                }
            }
            
            // 🔥 YÜZEN EKLE BUTONU (FLOATING ACTION BUTTON)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAddTask = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(AppTheme.fallbackPrimary)
                            .clipShape(Circle())
                            .shadow(color: AppTheme.fallbackPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100) // TabBar'ın üzerinde durması için boşluk
                }
            }
        }
        .background(AppTheme.fallbackBackground)
        .sheet(isPresented: $showAddTask) {
            // AddTaskView'a seçili tarihi ve ViewModel'i gönderiyoruz
            AddTaskView(defaultDate: selectedDate, viewModel: viewModel)
        }
    }
}

// MARK: - Helper Views

struct DateCard: View {
    let dayOffset: Int
    @Binding var selectedDate: Date
    
    var date: Date {
        Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
    }
    
    var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    var body: some View {
        Button(action: { withAnimation { selectedDate = date } }) {
            VStack {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .gray)
                Text(date.formatted(.dateTime.day()))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .black)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? AppTheme.fallbackPrimary : Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct TaskRow: View {
    let task: TaskModel
    @ObservedObject var viewModel: PlannerViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    viewModel.toggleTask(task: task)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .black)
                
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(task.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                }
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Öncelik Rozeti
            if task.priority == 2 {
                Text("Yüksek")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
