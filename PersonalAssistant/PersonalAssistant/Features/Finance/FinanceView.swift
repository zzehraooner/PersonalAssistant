import SwiftUI
import Charts

struct FinanceView: View {
    struct Transaction: Identifiable {
        let id = UUID()
        let title: String
        let amount: Double
        let date: Date
        let category: String
        let isIncome: Bool
    }
    
    @State private var transactions: [Transaction] = []
    @State private var showAddTransaction = false
    
    var totalBalance: Double {
        transactions.reduce(0) { $0 + ($1.isIncome ? $1.amount : -$1.amount) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Cüzdan")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { showAddTransaction = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.fallbackPrimary)
                }
            }
            .padding()
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Card
                    VStack(spacing: 10) {
                        Text("Toplam Bakiye")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("₺\(String(format: "%.2f", totalBalance))")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(30)
                    .background(AppTheme.gradientMain)
                    .cornerRadius(20)
                    .shadow(color: AppTheme.fallbackPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // Transactions
                    if transactions.isEmpty {
                        Text("Henüz işlem yok.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Son İşlemler")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(transactions) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                    }
                }
                .padding(.top)
            }
        }
        .background(AppTheme.fallbackBackground)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView(transactions: $transactions)
        }
    }
}

// MARK: - Helper Views

struct TransactionRow: View {
    let transaction: FinanceView.Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.isIncome ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                .font(.title2)
                .foregroundColor(transaction.isIncome ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(transaction.isIncome ? "+" : "-")₺\(String(format: "%.0f", transaction.amount))")
                .fontWeight(.bold)
                .foregroundColor(transaction.isIncome ? .green : .black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var transactions: [FinanceView.Transaction]
    
    @State private var title = ""
    @State private var amountString = ""
    @State private var category = "Genel"
    @State private var type = 0 // 0: Gider, 1: Gelir
    
    let categories = ["Genel", "Gıda", "Ulaşım", "Eğlence", "Fatura", "Maaş", "Ek Gelir"]
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Tür", selection: $type) {
                    Text("Gider").tag(0)
                    Text("Gelir").tag(1)
                }
                .pickerStyle(.segmented)
                
                Section(header: Text("Detaylar")) {
                    TextField("Açıklama", text: $title)
                    TextField("Tutar", text: $amountString)
                        .keyboardType(.decimalPad)
                    
                    Picker("Kategori", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("İşlem Ekle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        if let amount = Double(amountString), !title.isEmpty {
                            let newTransaction = FinanceView.Transaction(
                                title: title,
                                amount: amount,
                                date: Date(),
                                category: category,
                                isIncome: type == 1
                            )
                            transactions.insert(newTransaction, at: 0)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || amountString.isEmpty)
                }
            }
        }
    }
}
