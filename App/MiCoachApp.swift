// MiCoachApp.swift
// Punto de entrada principal de la aplicación

import SwiftUI

@main
struct MiCoachApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var coachingService = CoachingService()
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                // Pantalla de carga mientras verificamos si hay datos
                LoadingView()
            } else if coachingService.currentUser == nil {
                // Si no hay usuario, mostrar onboarding
                OnboardingView(coachingService: coachingService)
            } else {
                // Si hay usuario, mostrar dashboard
                DashboardView(coachingService: coachingService)
            }
        }
        .onAppear {
            loadInitialData()
        }
        .onChange(of: coachingService.currentUser) { user in
            // Cuando se cree un usuario (al terminar onboarding), recargar datos
            if user != nil && isLoading == false {
                Task {
                    await coachingService.loadData()
                }
            }
        }
    }
    
    private func loadInitialData() {
        Task {
            // Cargar datos del coaching service
            await coachingService.loadData()
            
            // Pequeña pausa para mostrar la pantalla de carga
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("MiCoach")
                    .font(.largeTitle.bold())
                
                ProgressView()
                    .scaleEffect(1.2)
                    .padding(.top, 20)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
