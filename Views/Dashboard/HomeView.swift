// HomeView.swift

import SwiftUI

struct HomeView: View {
    @ObservedObject var coachingService: CoachingService
    @State private var showingProfile = false
    @State private var selectedTask: DailyTaskItem?
    @State private var selectedRoutine: FitnessRoutine?
    @State private var inProgressTasks: Set<String> = []
    @State private var showingReflection = false
    @State private var reflectionText = ""
    @State private var showCompletionMessage = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        // Fecha actual en grande
                        dateHeader
                        
                        // Sección de rutina de fitness (si aplica)
                        if let fitnessRoutines = coachingService.currentPlan?.fitnessRoutines, !fitnessRoutines.isEmpty {
                            fitnessRoutineSection(routines: fitnessRoutines)
                        }
                        
                        // Objetivos diarios
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Objetivos diarios:")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            // Task Cards (sin reflexión)
                            if let dailyTask = coachingService.getDailyGuidance() {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(dailyTask.tasks.filter { !$0.title.contains("Reflexión") }) { task in
                                        TaskCard(
                                            task: task,
                                            isCompleted: taskCompleted(task.id),
                                            isInProgress: inProgressTasks.contains(task.id),
                                            onCompleted: {
                                                showCompletionFeedback()
                                            }
                                        ) {
                                            selectedTask = task
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // Botones de desarrollo
                        VStack(spacing: 12) {
                            // Botón para resetear el día actual (para pruebas)
                            Button(action: resetCurrentDay) {
                                Text("Reiniciar tareas de hoy")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // Botón para reiniciar la app completamente
                            Button(action: resetApp) {
                                Text("Reiniciar App Completamente")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 32)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 32)
                }
                
                // Sección de reflexión en la parte inferior
                reflectionSection
            }
            .navigationTitle("")
            .navigationBarItems(trailing: profileButton)
            .sheet(isPresented: $showingProfile) {
                ProfileView(profileData: coachingService)
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(
                    task: task,
                    coachingService: coachingService,
                    isInProgress: inProgressTasks.contains(task.id),
                    onTaskStarted: { taskId in
                        inProgressTasks.insert(taskId)
                    },
                    onTaskCompleted: { taskId in
                        inProgressTasks.remove(taskId)
                        showCompletionFeedback()
                    }
                )
            }
            .sheet(item: $selectedRoutine) { routine in
                FitnessRoutineView(routine: routine)
            }
            .sheet(isPresented: $showingReflection) {
                ReflectionView(reflectionText: $reflectionText)
            }
            .overlay(
                CompletionFeedback(isShowing: $showCompletionMessage)
            )
        }
    }
    
    private func fitnessRoutineSection(routines: [FitnessRoutine]) -> some View {
        // Determinar qué rutina corresponde al día de hoy
        let todaysRoutine = getTodaysRoutine(from: routines)
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Rutina de entrenamiento para hoy:")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
            
            if let routine = todaysRoutine {
                // Mostrar solo la rutina de hoy
                WorkoutCard(routine: routine) {
                    selectedRoutine = routine
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            } else {
                // Si hoy no toca entrenamiento
                Text("Hoy es tu día de descanso 😊")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            }
        }
        .padding(.horizontal)
    }
    
    // Función para determinar la rutina de hoy
    private func getTodaysRoutine(from routines: [FitnessRoutine]) -> FitnessRoutine? {
        guard !routines.isEmpty else { return nil }
        
        // Determinar el día de la semana (1-7, donde 1 es domingo)
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        
        // Para rutinas de 3 días (Lun, Mié, Vie)
        if routines.count == 3 {
            switch today {
            case 2: // Lunes
                return routines[0]
            case 4: // Miércoles
                return routines[1]
            case 6: // Viernes
                return routines[2]
            default:
                return nil
            }
        }
        // Para rutinas de 4 días (Lun, Mar, Jue, Vie)
        else if routines.count == 4 {
            switch today {
            case 2: // Lunes
                return routines[0]
            case 3: // Martes
                return routines[1]
            case 5: // Jueves
                return routines[2]
            case 6: // Viernes
                return routines[3]
            default:
                return nil
            }
        }
        // Para rutinas de 5 días (Lun-Vie)
        else if routines.count == 5 {
            // De lunes a viernes
            if today >= 2 && today <= 6 {
                return routines[today - 2]
            } else {
                return nil
            }
        }
        
        // Si ninguno de los casos anteriores, devolver la primera rutina
        // (esto es solo una fallback)
        return routines.first
    }
    
    private func showCompletionFeedback() {
        withAnimation {
            showCompletionMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCompletionMessage = false
            }
        }
    }
    
    private var reflectionSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
            
            Button(action: { showingReflection = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                    
                    Text("Reflexión diaria")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
    
    private var dateHeader: some View {
        VStack(spacing: 4) {
            Text(dateFormatter.string(from: Date()))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(weekdayFormatter.string(from: Date()))
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private var profileButton: some View {
        Button(action: { showingProfile = true }) {
            Circle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                )
        }
    }
    
    private func taskCompleted(_ taskId: String) -> Bool {
        coachingService.progress?.completedTasks.contains(taskId) ?? false
    }
    
    // Función para resetear el día actual corregida
    private func resetCurrentDay() {
        coachingService.resetTodayTasks()
        inProgressTasks.removeAll()
    }
    
    // Función para reiniciar toda la app
    private func resetApp() {
        // Borrar todos los datos
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "currentPlan")
        UserDefaults.standard.removeObject(forKey: "currentProgress")
        UserDefaults.standard.removeObject(forKey: "currentAssessment")
        
        // Reiniciar el coaching service
        coachingService.currentUser = nil
        coachingService.currentPlan = nil
        coachingService.progress = nil
        
        // Limpiar tareas en progreso
        inProgressTasks.removeAll()
        
        // Esto forzará que la app vuelva a mostrar el onboarding
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Reiniciar la app navegando al root
            if let window = UIApplication.shared.windows.first {
                window.rootViewController?.dismiss(animated: false)
            }
        }
    }
    
    // Formatters
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d 'de' MMMM"
        return formatter
    }
    
    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE"
        return formatter
    }
}

struct CompletionFeedback: View {
    @Binding var isShowing: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if isShowing {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                
                Text("¡Bien hecho!")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(24)
            .background(
                (colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isShowing)
        }
    }
}

struct WorkoutCard: View {
    let routine: FitnessRoutine
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text(routine.day)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            Text(routine.focus)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(width: 160, height: 160)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
        .onTapGesture(perform: onTap)
    }
}

struct TaskCard: View {
    let task: DailyTaskItem
    let isCompleted: Bool
    let isInProgress: Bool
    let onCompleted: () -> Void
    let onTap: () -> Void
    @State private var showCheckmark = false
    
    private var taskIcon: String {
        if task.title.contains("Caminar") || task.title.contains("ejercicio") {
            return "figure.walk"
        } else if task.title.contains("Leer") || task.title.contains("lectura") {
            return "book.fill"
        } else if task.title.contains("Planifica") || task.title.contains("productividad") {
            return "brain.head.profile"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    private var cardColor: Color {
        if isCompleted {
            return .blue.opacity(0.5)
        } else if isInProgress {
            return .orange.opacity(0.2)
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    private var iconColor: Color {
        if isCompleted {
            return .blue
        } else if isInProgress {
            return .orange
        } else {
            return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Image(systemName: taskIcon)
                    .font(.system(size: 40))
                    .foregroundColor(iconColor)
                    .scaleEffect(isCompleted ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isCompleted)
                
                if showCheckmark {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                        .scaleEffect(showCheckmark ? 1.5 : 0.1)
                        .opacity(showCheckmark ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCheckmark)
                }
            }
            
            Text(task.title)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            Text(task.estimatedTime)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(width: 160, height: 160)
        .background(cardColor)
        .cornerRadius(16)
        .onTapGesture(perform: onTap)
        .onChange(of: isCompleted) { newValue in
            if newValue && !showCheckmark {
                withAnimation {
                    showCheckmark = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showCheckmark = false
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(coachingService: CoachingService())
    }
}
