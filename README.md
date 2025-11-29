📱 Personal Assistant (Kişisel Asistan)

Personal Assistant, günlük yaşamınızı organize etmenize yardımcı olan, görev yönetimi, finans takibi ve alışkanlık kazanımı özelliklerini tek bir çatı altında toplayan modern bir iOS uygulamasıdır.

Bu proje, SwiftUI arayüz çatısı ve Firebase backend servisleri kullanılarak, temiz ve ölçeklenebilir MVVM (Model-View-ViewModel) mimarisi ile geliştirilmiştir.

✨ Özellikler

1. 📊 Dashboard (Ana Ekran)

Dinamik Özet: Kalan görevler, güncel bakiye, alışkanlık serileri ve bekleyen işler için anlık özet kartları.

Aktivite Akışı: Görev tamamlama ve finansal harcamaların bir arada bulunduğu, zamana göre sıralı "Son Aktiviteler" listesi.

Profil Yönetimi: Kullanıcı adı güncelleme ve çıkış yapma özellikleri.

2. 🗓️ Planlayıcı (Planner)

Haftalık Takvim: Seçilen güne ait görevleri filtreleyen yatay takvim şeridi.

Görev Yönetimi: Başlık, detay, tarih ve öncelik seviyesi ile görev ekleme.

Anlık Senkronizasyon: Görevleri tamamlama veya silme işlemlerinin anında veritabanına yansıması.

3. 💰 Cüzdan (Finance)

Gelir/Gider Takibi: Harcamalarınızı ve gelirlerinizi kategorize ederek kaydedin.

Bakiye Hesabı: Tüm işlemlerden otomatik hesaplanan toplam bakiye.

Görsel Ayrım: Gelirler (Yeşil) ve Giderler (Kırmızı) için özel renklendirme.

4. 🔥 Alışkanlıklar (Habits)

Seri Takibi (Streak): Alışkanlıklarınızı kaç gün üst üste yaptığınızı takip edin.

Motivasyon: Günlük hedefleri tamamlayarak zinciri kırmayın.

5. 🔐 Güvenlik

Firebase Auth: E-posta ve şifre ile güvenli giriş/kayıt sistemi.

Veri Gizliliği: Her kullanıcının verisi Firestore'da ayrıştırılmış (Sandboxed) şekilde tutulur.

🛠️ Teknoloji Yığını

Dil: Swift 5

Framework: SwiftUI

Mimari: MVVM (Model-View-ViewModel)

Backend: Firebase (Authentication, Firestore Database)

Bağımlılık Yönetimi: CocoaPods / Swift Package Manager

Veri Modelleri: Codable, Identifiable, FirebaseFirestoreSwift

📂 Proje Yapısı

Proje, sorumlulukların ayrılması (Separation of Concerns) ilkesine uygun olarak klasörlenmiştir:

```text
PersonalAssistant/
├── App/
│   ├── PersonalAssistantApp.swift  (Giriş Noktası & Firebase Config)
│   └── ContentView.swift           (Root View & Tab Bar)
├── Model/
│   ├── TaskModel.swift
│   ├── TransactionModel.swift
│   └── HabitModel.swift
├── View/
│   ├── Auth/                       (Login & Register)
│   ├── Dashboard/
│   ├── Planner/
│   ├── Finance/
│   └── Habits/
├── ViewModel/
│   ├── DashboardViewModel.swift
│   ├── PlannerViewModel.swift
│   ├── FinanceViewModel.swift
│   └── HabitsViewModel.swift
└── Service/
    └── AuthService.swift           (Singleton Auth Yöneticisi)
```



⚙️ Kurulum ve Çalıştırma

Bu projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin:

Projeyi Klonlayın:

git clone [https://github.com/kullaniciadi/PersonalAssistant.git](https://github.com/kullaniciadi/PersonalAssistant.git)
cd PersonalAssistant


Bağımlılıkları Yükleyin (CocoaPods kullanıyorsanız):

pod install
open PersonalAssistant.xcworkspace


Firebase Kurulumu (Çok Önemli!):

Firebase Console adresine gidin ve yeni bir proje oluşturun.

Bir iOS uygulaması ekleyin ve Bundle ID'nizi girin.

İndirdiğiniz GoogleService-Info.plist dosyasını Xcode projesinin ana dizinine sürükleyip bırakın.

Konsolda Authentication'ı (Email/Password) aktif edin.

Firestore Database oluşturun ve aşağıdaki güvenlik kurallarını ekleyin:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;

      match /tasks/{taskId} { allow read, write: if request.auth.uid == uid; }
      match /transactions/{transId} { allow read, write: if request.auth.uid == uid; }
      match /habits/{habitId} { allow read, write: if request.auth.uid == uid; }
    }
  }
}


Çalıştırın:
Xcode üzerinden Cmd + R yaparak simülatörde başlatın.

🤝 İletişim

Geliştirici: Zehra ÖNER GitHub: https://github.com/zzehraooner
