// MiCoachApp.swift
// Punto de entrada principal de la aplicación

import SwiftUI

@main
struct MiCoachApp: App {
    // Si usas una clase de aplicación para gestionar el estado global
    // @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            // Asegúrate de que DashboardView.swift esté en tu proyecto
            // y que esté accesible desde aquí
            DashboardView()
                // Puedes pasar appState u otras dependencias si las necesitas
                // .environmentObject(appState)
        }
    }
}
