import SwiftUI

struct AIChatView: View {
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(content: "Merhaba! Ben kişisel asistanın. Sana nasıl yardımcı olabilirim?", isUser: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("AI Asistan")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundColor(AppTheme.fallbackSecondary)
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
            
            // Chat Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                        
                        if chatService.isTyping {
                            HStack {
                                TypingIndicator()
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Area
            HStack(spacing: 12) {
                Button(action: {
                    // Voice command placeholder
                }) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                
                TextField("Bir şeyler yaz...", text: $messageText)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(messageText.isEmpty ? .gray : AppTheme.fallbackPrimary)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color.white)
        }
        .background(AppTheme.fallbackBackground)
    }
    
    func sendMessage() {
        let userMsg = ChatMessage(content: messageText, isUser: true)
        messages.append(userMsg)
        let currentText = messageText
        messageText = ""
        
        Task {
            do {
                let response = try await chatService.sendMessage(currentText)
                let aiMsg = ChatMessage(content: response, isUser: false)
                withAnimation {
                    messages.append(aiMsg)
                }
            } catch {
                // Handle error
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.content)
                .padding(12)
                .background(message.isUser ? AppTheme.gradientMain : LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom))
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: message.isUser ? 0 : 1)
                )
            
            if !message.isUser { Spacer() }
        }
    }
}

struct TypingIndicator: View {
    @State private var numberOfDots = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .scaleEffect(numberOfDots == index ? 1.2 : 0.8)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever()) {
                numberOfDots = 2
            }
        }
    }
}
