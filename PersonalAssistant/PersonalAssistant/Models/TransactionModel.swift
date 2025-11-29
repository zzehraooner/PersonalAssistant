//
//  TransactionModel.swift
//  PersonalAssistant
//
//  Created by Zehra on 29.11.2025.
//

import Foundation
import FirebaseFirestore // @DocumentID özelliği için gereklidir

struct TransactionModel: Identifiable, Codable {
    // @DocumentID, Firestore'daki belge kimliğini (document ID) otomatik olarak bu değişkene atar.
    // Veri yazarken bu alanı göndermene gerek yoktur, okurken otomatik dolar.
    @DocumentID var id: String?
    
    var title: String
    var amount: Double
    var isIncome: Bool // true ise Gelir, false ise Gider
    var date: Date
    
    // ViewModel'da açıkça kullanılmamış ama genelde işlem detaylarında kategori de olur.
    // İhtiyacına göre bu alanı ekleyip çıkarabilirsin:
    var category: String?
    
    // Varsayılan init (Test verileri oluşturmak istersen kolaylık sağlar)
    init(id: String? = nil, title: String, amount: Double, isIncome: Bool, date: Date, category: String? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.isIncome = isIncome
        self.date = date
        self.category = category
    }
}
