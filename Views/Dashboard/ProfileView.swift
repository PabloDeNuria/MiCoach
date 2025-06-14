// ProfileView.swift

import SwiftUI

struct ProfileView: View {
    @ObservedObject var profileData: CoachingService  // Cambiar ProfileData a CoachingService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con imagen de perfil
                VStack(spacing: 16) {
                    if let user = profileData.currentUser {
                        // Imagen de perfil
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(user.name.prefix(1).uppercased())
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.white)
                            )
                        
                        Text(user.name)
                            .font(.title2.bold())
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                
                // Lista de opciones
                ScrollView {
                    VStack(spacing: 12) {
                        // Sección de cuenta
                        SectionHeader(title: "Cuenta")
                        
                        SettingsRow(icon: "person.crop.circle", title: "Información personal", action: {})
                        SettingsRow(icon: "bell", title: "Notificaciones", action: {})
                        SettingsRow(icon: "moon", title: "Tema", action: {})
                        
                        // Sección de preferencias
                        SectionHeader(title: "Preferencias")
                        
                        SettingsRow(icon: "heart", title: "Objetivos", action: {})
                        SettingsRow(icon: "gearshape", title: "Configuración", action: {})
                        
                        // Sección de soporte
                        SectionHeader(title: "Soporte")
                        
                        SettingsRow(icon: "questionmark.circle", title: "Ayuda", action: {})
                        SettingsRow(icon: "envelope", title: "Contacto", action: {})
                        
                        // Cerrar sesión
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .foregroundColor(.red)
                                    .frame(width: 24)
                                Text("Cerrar sesión")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.top, 24)
                    }
                    .padding()
                }
            }
            .navigationTitle("Perfil")
            .navigationBarItems(trailing: Button("Cerrar") { dismiss() })
        }
    }
}

// Componentes auxiliares
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.bottom, 4)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(profileData: CoachingService())
    }
}
