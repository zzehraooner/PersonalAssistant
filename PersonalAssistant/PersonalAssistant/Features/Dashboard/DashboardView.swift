import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct DashboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedTab: ContentView.Tab
    @ObservedObject var authService = AuthService.shared
    
    // ✅ DYNAMIC DATA: ViewModel'i başlatıyoruz
    @StateObject var viewModel = DashboardViewModel()
    
    @State private var showEditProfile = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Header / Greeting
                HStack {
                    VStack(alignment: .leading) {
                        Text("Merhaba,")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // İsim Gösterimi
                        Text(!authService.userName.isEmpty ? authService.userName : (authService.user?.displayName ?? "Kullanıcı"))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.fallbackPrimary)
                    }
                    
                    Spacer()
                    
                    // MARK: - Ayarlar Menüsü
                    Menu {
                        Button(action: { showEditProfile = true }) {
                            Label("Profili Düzenle", systemImage: "person.crop.circle")
                        }
                        Divider()
                        Button(role: .destructive, action: { authService.signOut() }) {
                            Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(AppTheme.fallbackSecondary)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // MARK: - AI Assistant Card
                Button(action: { selectedTab = .chat }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI Asistanın Hazır").font(.headline).foregroundColor(.white)
                            Text("Günün planını yapmamı ister misin?").font(.caption).foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                        Image(systemName: "sparkles").font(.system(size: 40)).foregroundColor(.white)
                    }
                    .padding(20)
                    .background(AppTheme.gradientMain)
                    .cornerRadius(20)
                    .shadow(color: AppTheme.fallbackPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                
                // MARK: - Summary Cards Grid (DİNAMİK VERİ)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    
                    // 1. Görevler Kartı
                    SummaryCard(
                        icon: "calendar",
                        title: "Kalan Görevler",
                        value: "\(viewModel.taskCount) Görev",
                        color: Color.blue
                    ) { selectedTab = .planner }
                    
                    // 2. Bakiye Kartı
                    SummaryCard(
                        icon: "creditcard.fill",
                        title: "Bakiye",
                        value: String(format: "₺%.2f", viewModel.totalBalance),
                        color: viewModel.totalBalance >= 0 ? Color.green : Color.red
                    ) { selectedTab = .finance }
                    
                    // 3. Seri Kartı
                    SummaryCard(
                        icon: "flame.fill",
                        title: "Seri",
                        value: "\(viewModel.streakDays) Gün",
                        color: Color.orange
                    ) { selectedTab = .habits }
                    
                    // 4. Hatırlatma Kartı
                    SummaryCard(
                        icon: "clock.fill",
                        title: "Bekleyen",
                        value: "\(viewModel.pendingReminders) Hatırlatma",
                        color: Color.purple
                    ) { selectedTab = .planner }
                }
                .padding(.horizontal)
                
                // MARK: - Recent Activity (DİNAMİK LİSTE)
                VStack(alignment: .leading) {
                    Text("Son Aktiviteler")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.recentActivities.isEmpty {
                        Text("Henüz bir aktivite yok.")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(viewModel.recentActivities) { activity in
                                ActivityRow(activity: activity)
                                // Son öğeden sonra Divider koyma
                                if activity.id != viewModel.recentActivities.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .background(AppTheme.fallbackBackground)
        // MARK: - Sheet (Pop-up Ekranı)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        // ✅ ONAPPEAR DÜZELTİLDİ: Kullanıcı ID'si parametre olarak gönderiliyor
        .onAppear {
            if let uid = Auth.auth().currentUser?.uid {
                viewModel.fetchDashboardData(for: uid)
            }
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var authService = AuthService.shared
    @State private var newName: String = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kullanıcı Bilgileri")) {
                    TextField("Adınız Soyadınız", text: $newName)
                        .textContentType(.name)
                }
                
                Section {
                    Button(action: saveProfile) {
                        HStack {
                            Text("Değişiklikleri Kaydet")
                            if isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(newName.isEmpty || isLoading)
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarItems(trailing: Button("Kapat") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                newName = authService.userName
            }
        }
    }
    
    func saveProfile() {
        isLoading = true
        authService.updateProfileName(newName: newName) { success in
            isLoading = false
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Helper Views
struct SummaryCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .padding(10)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(value)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Activity Row (DÜZELTİLDİ)
struct ActivityRow: View {
    // ❌ ESKİ FAZLALIKLAR SİLİNDİ: icon, title, time, amount
    
    // ✅ Sadece activity nesnesi yeterli
    let activity: ActivityItem
    
    var body: some View {
        HStack(spacing: 15) {
            // İKON KISMI
            Image(systemName: activity.icon)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                // RENKLENDİRME
                .foregroundColor(
                    activity.type == "income" ? .green :
                    activity.type == "expense" ? .red :
                    activity.type == "habit" ? .orange :
                    activity.type == "task" ? .blue : .gray
                )
            
            // DETAYLAR KISMI
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(activity.details)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // SAAT KISMI
            Text(activity.timeString)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding() // İç boşluk eklendi, daha iyi görünüm için
    }
}
