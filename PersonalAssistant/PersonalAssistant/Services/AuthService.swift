import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var userName: String = ""
    @Published var errorMessage = ""
    
    static let shared = AuthService()
    private var db = Firestore.firestore()
    
    init() {
        // Oturum durumunu sürekli dinle (Listener)
        // Bu sayede kullanıcı çıkış yaparsa veya oturum açarsa otomatik tetiklenir.
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            
            if let user = user {
                // Kullanıcı giriş yaptıysa ismini çek
                self?.fetchUserData(uid: user.uid)
            } else {
                // Çıkış yaptıysa verileri temizle
                self?.userName = ""
                self?.errorMessage = ""
            }
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Giriş Hatası: \(error.localizedDescription)"
                    completion(false)
                }
                return
            }
            // Başarılı giriş (init içindeki listener otomatik olarak veriyi çekecek)
            completion(true)
        }
    }
    
    // MARK: - Register
    func register(email: String, password: String, name: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Kayıt Hatası: \(error.localizedDescription)"
                    completion(false)
                }
                return
            }
            
            guard let user = result?.user else { return }
            
            // 1. Firebase Auth Profilinde İsmi Güncelle
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Profil güncelleme hatası: \(error.localizedDescription)")
                }
                
                // 2. Firestore'a Kaydet
                self.saveUserToFirestore(user: user, name: name) { success in
                    if success {
                        DispatchQueue.main.async {
                            self.userName = name // UI'ı anında güncelle
                            completion(true)
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            // Listener otomatik olarak user'ı nil yapacak, ekstra koda gerek yok
        } catch {
            self.errorMessage = "Çıkış Hatası: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Data Operations
    
    func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Veri çekme hatası: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data(), let name = data["name"] as? String {
                DispatchQueue.main.async {
                    self.userName = name
                }
            } else {
                // Firestore'da yoksa Auth profilinden almayı dene (Yedek Plan)
                if let displayName = Auth.auth().currentUser?.displayName {
                    DispatchQueue.main.async {
                        self.userName = displayName
                    }
                }
            }
        }
    }
    
    private func saveUserToFirestore(user: FirebaseAuth.User, name: String, completion: @escaping (Bool) -> Void) {
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "name": name,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Veritabanı hatası: \(error.localizedDescription)"
                    completion(false)
                }
            } else {
                completion(true)
            }
        }
    }
    
    // MARK: - YENİ: Profil Güncelleme Fonksiyonu
    // Ayarlar sayfasında isim değiştirmek isterseniz bunu kullanacaksınız.
    func updateProfileName(newName: String, completion: @escaping (Bool) -> Void) {
        guard let user = self.user else { return }
        
        // 1. Auth Profilini Güncelle
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        changeRequest.commitChanges { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            // 2. Firestore'u Güncelle
            self.db.collection("users").document(user.uid).updateData(["name": newName]) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    DispatchQueue.main.async {
                        self.userName = newName // UI anında güncellenir
                        completion(true)
                    }
                }
            }
        }
    }
}
