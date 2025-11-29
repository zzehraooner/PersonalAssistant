import SwiftUI

struct ContentView: View {
    @ObservedObject var authService = AuthService.shared
    
    @State private var selectedTab: Tab = .dashboard
    
    enum Tab {
        case dashboard
        case planner
        case chat
        case finance
        case habits
    }
    
    var body: some View {
        Group {
            // KULLANICI KONTROLÜ
            if authService.user == nil {
                AuthView()
            } else {
                mainAppInterface
            }
        }
        .animation(.easeInOut, value: authService.user)
    }
    
    // Kod karmaşasını önlemek için tasarımınızı buraya ayırdım
    var mainAppInterface: some View {
        ZStack {
            AppTheme.fallbackBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Sayfalar
                TabView(selection: $selectedTab) {
                    DashboardView(selectedTab: $selectedTab).tag(Tab.dashboard)
                    PlannerView().tag(Tab.planner)
                    AIChatView().tag(Tab.chat)
                    FinanceView().tag(Tab.finance)
                    HabitsView().tag(Tab.habits)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Özel Tab Bar Tasarımınız
                HStack {
                    TabButton(icon: "square.grid.2x2.fill", title: "Home", tab: .dashboard, selectedTab: $selectedTab)
                    TabButton(icon: "calendar", title: "Plan", tab: .planner, selectedTab: $selectedTab)
                    
                    Spacer().frame(width: 60) // Orta buton boşluğu
                    
                    TabButton(icon: "creditcard.fill", title: "Finance", tab: .finance, selectedTab: $selectedTab)
                    TabButton(icon: "list.bullet.clipboard.fill", title: "Habits", tab: .habits, selectedTab: $selectedTab)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .padding(.top, 15)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: -5)
                .overlay(
                    // AI Butonu
                    Button(action: { selectedTab = .chat }) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.gradientMain)
                                .frame(width: 65, height: 65)
                                .shadow(color: AppTheme.fallbackPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -35),
                    alignment: .bottom
                )
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

// Yardımcı Tab Butonu (Aynen korundu)
struct TabButton: View {
    let icon: String
    let title: String
    let tab: ContentView.Tab
    @Binding var selectedTab: ContentView.Tab
    
    var body: some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(selectedTab == tab ? AppTheme.fallbackPrimary : Color.gray.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
