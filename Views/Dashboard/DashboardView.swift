// DashboardView.swift
// Vista principal que contiene las pestañas de navegación

import SwiftUI

struct DashboardView: View {
    // Asegúrate de usar la definición correcta de CoachingService
    @StateObject var coachingService = CoachingService()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(coachingService: coachingService)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
                .tag(0)
            
            // Reemplazamos ActivitiesView por ProcessView
            ProcessView(coachingService: coachingService)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Proceso")
                }
                .tag(1)
            
            // Mantén aquí las otras pestañas que ya tengas en tu app
            // Por ejemplo, si tienes una vista de nutrición:
            // NutritionView(coachingService: coachingService)
            //    .tabItem {
            //        Image(systemName: "fork.knife")
            //        Text("Nutrición")
            //    }
            //    .tag(2)
            
            // Corregido: Cambiamos el nombre del parámetro a profileData
            ProfileView(profileData: coachingService)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
                .tag(2) // Ajusta el número de tag según las pestañas que tengas
        }
        .accentColor(.blue)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
