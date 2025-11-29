import SwiftUI

struct AuthView: View {
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            AppTheme.gradientMain
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo / Title
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    Text("Kişisel Asistan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 50)
                
                // Form Card
                VStack(spacing: 20) {
                    Text(isLoginMode ? "Giriş Yap" : "Hesap Oluştur")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    if !isLoginMode {
                        TextField("Ad Soyad", text: $name)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    TextField("E-posta", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    SecureField("Şifre", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        Button(action: handleAuth) {
                            Text(isLoginMode ? "Giriş Yap" : "Kayıt Ol")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.fallbackPrimary)
                                .cornerRadius(12)
                                .shadow(color: AppTheme.fallbackPrimary.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                }
                .padding(30)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                .padding(.horizontal)
                .alert(isPresented: $showError) {
                    Alert(title: Text("Hata"), message: Text(errorMessage), dismissButton: .default(Text("Tamam")))
                }
                
                // Toggle Mode
                Button(action: { withAnimation { isLoginMode.toggle() } }) {
                    Text(isLoginMode ? "Hesabın yok mu? Kayıt Ol" : "Zaten hesabın var mı? Giriş Yap")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
        }
    }
    
    private func handleAuth() {
        isLoading = true
        if isLoginMode {
            AuthService.shared.login(email: email, password: password) { success in
                isLoading = false
                if success {
                    withAnimation {
                    }
                } else {
                    errorMessage = AuthService.shared.errorMessage
                    showError = true
                }
            }
        } else {
            AuthService.shared.register(email: email, password: password, name: name) { success in
                isLoading = false
                if success {
                    withAnimation {
                    }
                } else {
                    errorMessage = AuthService.shared.errorMessage
                    showError = true
                }
            }
        }
    }
}
