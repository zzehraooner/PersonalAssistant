import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift

struct HabitsView: View {
    
    @StateObject var viewModel = HabitsViewModel()
    @State private var showAddHabit = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Text("Alışkanlıklar")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddHabit = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.fallbackPrimary)
                            .padding(10) // Tıklama alanını genişletir
                            .contentShape(Rectangle())
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 3)
                
                // MARK: - List
                ScrollView {
                    if viewModel.habits.isEmpty {
                        VStack {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.bottom, 10)
                            Text("Henüz alışkanlık eklemedin.")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 100)
                    } else {
                        VStack(spacing: 15) {
                            ForEach(viewModel.habits) { habit in
                                HabitRow(habit: habit, viewModel: viewModel)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.deleteHabit(habit: habit)
                                        } label: {
                                            Label("Sil", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .background(AppTheme.fallbackBackground)
        .sheet(isPresented: $showAddHabit) {
            AddHabitView(viewModel: viewModel)
        }
    }
}

// MARK: - Helper Views (Eksik olan kısım burasıydı)

struct HabitRow: View {
    let habit: HabitModel
    @ObservedObject var viewModel: HabitsViewModel
    
    var body: some View {
        HStack {
            Image(systemName: habit.icon)
                .font(.title2)
                .foregroundColor(habit.isCompletedToday ? .white : AppTheme.fallbackPrimary)
                .frame(width: 50, height: 50)
                .background(habit.isCompletedToday ? AppTheme.fallbackPrimary : AppTheme.fallbackPrimary.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading) {
                Text(habit.title)
                    .font(.headline)
                    .strikethrough(habit.isCompletedToday)
                    .foregroundColor(habit.isCompletedToday ? .gray : .primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("\(habit.streak) gün seri")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    viewModel.toggleHabitCompletion(habit: habit)
                }
            }) {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 30))
                    .foregroundColor(habit.isCompletedToday ? .green : .gray.opacity(0.3))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        .opacity(habit.isCompletedToday ? 0.8 : 1.0)
    }
}

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitsViewModel
    
    @State private var title = ""
    @State private var selectedIcon = "star.fill"
    
    let icons = ["star.fill", "drop.fill", "book.fill", "figure.walk", "brain.head.profile", "bed.double.fill", "leaf.fill", "cart.fill", "dumbbell.fill"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Alışkanlık Detayları")) {
                    TextField("Başlık (Örn: Su iç)", text: $title)
                    
                    Picker("İkon", selection: $selectedIcon) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon).tag(icon)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
            }
            .navigationTitle("Yeni Alışkanlık")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        viewModel.addHabit(title: title, icon: selectedIcon)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
