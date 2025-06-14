// ProcessView.swift
// Versión con botón para ver explicación del entrenamiento

import SwiftUI

struct ProcessView: View {
    @ObservedObject var coachingService: CoachingService
    
    // Estado para la selección de la parte del proceso
    @State private var selectedSection: ProcessSection = .overview
    // Estado para controlar la navegación a la vista de explicación
    @State private var showTrainingExplanation = false
    @State private var selectedTrainingType = "Fuerza" // Tipo de entrenamiento por defecto
    
    // Posibles secciones de la vista de proceso
    enum ProcessSection {
        case overview
        case milestones
        case dailyRoutine
        case fitnessRoutine
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Selector de sección
                    sectionSelector
                    
                    // Contenido según la sección seleccionada
                    switch selectedSection {
                    case .overview:
                        processOverviewSection
                    case .milestones:
                        milestonesSection
                    case .dailyRoutine:
                        dailyRoutineSection
                    case .fitnessRoutine:
                        fitnessRoutineSection
                    }
                }
                .padding()
                .sheet(isPresented: $showTrainingExplanation) {
                    NavigationView {
                        TrainingExplanationView(trainingType: selectedTrainingType)
                    }
                }
            }
            .navigationTitle("Tu Proceso")
        }
    }
    
    // MARK: - Selector de sección
    private var sectionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                sectionButton(title: "Resumen", icon: "chart.pie.fill", section: .overview)
                sectionButton(title: "Hitos", icon: "flag.fill", section: .milestones)
                sectionButton(title: "Rutina Diaria", icon: "calendar", section: .dailyRoutine)
                
                // Mostrar la opción de rutina fitness solo si el plan tiene rutinas
                if let plan = coachingService.currentPlan, plan.fitnessRoutines != nil {
                    sectionButton(title: "Fitness", icon: "figure.walk", section: .fitnessRoutine)
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func sectionButton(title: String, icon: String, section: ProcessSection) -> some View {
        Button(action: {
            withAnimation {
                selectedSection = section
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.caption)
            }
            .frame(width: 90, height: 70)
            .background(selectedSection == section ? Color.blue.opacity(0.15) : Color.secondary.opacity(0.1))
            .foregroundColor(selectedSection == section ? .blue : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedSection == section ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
    
    // MARK: - Sección de Resumen del Proceso
    private var processOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tarjeta del objetivo principal con botón para ver tipo de entrenamiento
            if let plan = coachingService.currentPlan {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tu Objetivo")
                        .font(.headline)
                    
                    HStack(alignment: .top, spacing: 15) {
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "target")
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.objective)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Plan personalizado de \(plan.timeframe)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // Botón para ver explicación del entrenamiento
                            Button(action: {
                                // Determinar tipo de entrenamiento basado en el objetivo
                                if let fitnessGoal = getTrainingType(from: plan) {
                                    selectedTrainingType = fitnessGoal
                                }
                                showTrainingExplanation = true
                            }) {
                                Text("Descubre por qué este entrenamiento es ideal para ti")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                            }
                            .padding(.top, 6)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Progreso general
            if let progressInfo = coachingService.getProgress() {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Progreso General")
                        .font(.headline)
                    
                    // Barra de progreso
                    ProgressView(value: progressInfo.completionPercentage, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.green))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    HStack {
                        Text("\(Int(progressInfo.completionPercentage))% completado")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Text("Día \(progressInfo.currentDay) de \(progressInfo.totalDays)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                    
                    // Próximo hito
                    if let nextMilestone = progressInfo.nextMilestone {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Próximo hito:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.orange)
                                
                                Text(nextMilestone.title)
                                    .font(.subheadline.bold())
                                
                                Spacer()
                                
                                // Formato de fecha
                                Text(formatDate(nextMilestone.targetDate))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(12)
            }
            
            // Información sobre la rutina actual
            VStack(alignment: .leading, spacing: 12) {
                Text("Tu Rutina Actual")
                    .font(.headline)
                
                if let dailyTask = coachingService.getDailyGuidance(), !dailyTask.tasks.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tienes \(dailyTask.tasks.count) actividades planificadas para hoy")
                                .font(.subheadline)
                            
                            if let progress = coachingService.progress {
                                let completedTasks = dailyTask.tasks.filter { progress.completedTasks.contains($0.id) }.count
                                Text("\(completedTasks) de \(dailyTask.tasks.count) completadas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Cambiar a la sección de rutina diaria
                            withAnimation {
                                selectedSection = .dailyRoutine
                            }
                        }) {
                            Text("Ver detalles")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(12)
                } else {
                    Text("No hay actividades planificadas para hoy")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(12)
                }
            }
            
            // Sección de consejos
            VStack(alignment: .leading, spacing: 12) {
                Text("Consejos para tu éxito")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    tipCard(
                        title: "Consistencia es clave",
                        description: "Mantén tu rutina diaria para ver mejores resultados a largo plazo",
                        icon: "calendar.badge.clock"
                    )
                    
                    tipCard(
                        title: "Celebra tus logros",
                        description: "Reconoce y celebra cada hito alcanzado en tu camino",
                        icon: "star.fill"
                    )
                    
                    tipCard(
                        title: "Ajusta según necesites",
                        description: "No dudes en adaptar tu plan si encuentras obstáculos",
                        icon: "slider.horizontal.3"
                    )
                }
            }
        }
    }
    
    private func tipCard(title: String, description: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Sección de Hitos
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tus Hitos")
                .font(.headline)
            
            if let plan = coachingService.currentPlan, let progressInfo = coachingService.getProgress() {
                let sortedMilestones = plan.milestones.sorted(by: { $0.order < $1.order })
                
                ForEach(sortedMilestones) { milestone in
                    let isPast = milestone.targetDate < Date()
                    let isCurrent = progressInfo.nextMilestone?.id == milestone.id
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(milestone.title)
                                .font(.title3.bold())
                                .foregroundColor(isPast ? .green : isCurrent ? .blue : .primary)
                            
                            Spacer()
                            
                            Text("Hito \(milestone.order)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(6)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Text(milestone.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            
                            Text(formatDate(milestone.targetDate))
                                .font(.subheadline)
                            
                            Spacer()
                            
                            // Indicador de estado
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(isPast ? Color.green : isCurrent ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                
                                Text(isPast ? "Completado" : isCurrent ? "Actual" : "Pendiente")
                                    .font(.caption)
                                    .foregroundColor(isPast ? .green : isCurrent ? .blue : .secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isPast ? Color.green.opacity(0.5) :
                                isCurrent ? Color.blue.opacity(0.5) :
                                Color.clear,
                                lineWidth: 1.5
                            )
                    )
                }
            } else {
                Text("No hay hitos disponibles")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Sección de Rutina Diaria
    private var dailyRoutineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tu Rutina Diaria")
                    .font(.headline)
                
                Spacer()
                
                if let progress = coachingService.progress {
                    Text("Día \(progress.currentDay)")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            if let dailyTask = coachingService.getDailyGuidance(), let progress = coachingService.progress {
                ForEach(dailyTask.tasks) { task in
                    let isCompleted = progress.completedTasks.contains(task.id)
                    
                    Button(action: {
                        // Marcar tarea como completada
                        Task {
                            do {
                                try await coachingService.completeTask(taskId: task.id)
                            } catch {
                                print("Error al completar tarea: \(error)")
                            }
                        }
                    }) {
                        HStack(alignment: .top, spacing: 15) {
                            // Indicador de estado
                            Circle()
                                .fill(isCompleted ? Color.green : Color.blue.opacity(0.2))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Group {
                                        if isCompleted {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.system(size: 12, weight: .bold))
                                        }
                                    }
                                )
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(task.title)
                                    .font(.headline)
                                    .foregroundColor(isCompleted ? .secondary : .primary)
                                    .strikethrough(isCompleted)
                                
                                Text(task.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Label(task.estimatedTime, systemImage: "clock")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    // Botón para explicación si la categoría es "Salud" o "Fitness"
                                    if task.category == "Salud" || task.category == "Fitness" {
                                        Button(action: {
                                            // Determinar tipo de entrenamiento basado en el título de la tarea
                                            selectedTrainingType = getTrainingTypeFromTask(task)
                                            showTrainingExplanation = true
                                        }) {
                                            Text(task.category)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Color.blue)
                                                .cornerRadius(8)
                                        }
                                    } else {
                                        Text(task.category)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.secondary.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isCompleted ? Color.green.opacity(0.05) : Color.white)
                                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                Text("No hay tareas disponibles para hoy")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Sección de Rutina Fitness
    private var fitnessRoutineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tu Rutina de Fitness")
                    .font(.headline)
                
                Spacer()
                
                // Botón para mostrar explicación del tipo de entrenamiento
                if let plan = coachingService.currentPlan, let routines = plan.fitnessRoutines, !routines.isEmpty {
                    Button(action: {
                        if let fitnessGoal = getTrainingType(from: plan) {
                            selectedTrainingType = fitnessGoal
                        }
                        showTrainingExplanation = true
                    }) {
                        Text("¿Por qué este entrenamiento?")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                }
            }
            
            if let plan = coachingService.currentPlan, let routines = plan.fitnessRoutines {
                // Selector de día
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(routines) { routine in
                            dayButton(day: routine.day, focus: routine.focus)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.bottom, 8)
                
                // Mostrar la rutina seleccionada (por defecto la primera)
                if let selectedRoutine = routines.first {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedRoutine.day)
                                    .font(.title3.bold())
                                
                                Text(selectedRoutine.focus)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(selectedRoutine.exercises.count) ejercicios")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.bottom, 8)
                        
                        // Lista de ejercicios
                        ForEach(selectedRoutine.exercises) { exercise in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(exercise.name)
                                    .font(.headline)
                                
                                HStack {
                                    exerciseDetailBadge(title: "\(exercise.sets) series", icon: "number")
                                    exerciseDetailBadge(title: exercise.reps, icon: "repeat")
                                    exerciseDetailBadge(title: exercise.weight, icon: "scalemass.fill")
                                    exerciseDetailBadge(title: exercise.rest, icon: "timer")
                                }
                                
                                if let notes = exercise.notes {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
            } else {
                Text("No hay rutinas fitness disponibles")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Componentes auxiliares
    private func dayButton(day: String, focus: String) -> some View {
        VStack(spacing: 6) {
            Text(day)
                .font(.headline)
            
            Text(focus)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 100, height: 60)
        .padding(.horizontal, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func exerciseDetailBadge(title: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            
            Text(title)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Métodos auxiliares
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Función para determinar el tipo de entrenamiento basado en el plan
    private func getTrainingType(from plan: PersonalizedPlan) -> String? {
        if let fitnessRoutines = plan.fitnessRoutines, !fitnessRoutines.isEmpty {
            // Intentar obtener información de metadata
            if plan.objective.contains("Salud") {
                if let fitnessGoal = plan.fitnessRoutines?.first?.focus {
                    // Si el focus de la rutina contiene información útil
                    if fitnessGoal.contains("Fuerza") || fitnessGoal.contains("Pecho") || fitnessGoal.contains("Espalda") {
                        return "Fuerza"
                    } else if fitnessGoal.contains("Cardio") || fitnessGoal.contains("HIIT") {
                        return "Cardio"
                    } else if fitnessGoal.contains("Resistencia") {
                        return "Resistencia"
                    } else if fitnessGoal.lowercased().contains("pérdida de peso") || fitnessGoal.contains("Quema") {
                        return "Pérdida de peso"
                    } else if fitnessGoal.contains("Hipertrofia") || fitnessGoal.contains("Músculo") {
                        return "Hipertrofia"
                    }
                }
            }
            
            // Análisis basado en el objetivo general
            if plan.objective.lowercased().contains("fuerza") {
                return "Fuerza"
            } else if plan.objective.lowercased().contains("cardio") || plan.objective.lowercased().contains("resistencia") {
                return "Cardio"
            } else if plan.objective.lowercased().contains("perder peso") || plan.objective.lowercased().contains("adelgazar") {
                return "Pérdida de peso"
            } else if plan.objective.lowercased().contains("músculo") || plan.objective.lowercased().contains("hipertrofia") {
                return "Hipertrofia"
            }
        }
        
        // Valor predeterminado
        return "Fuerza"
    }
    
    // Función para determinar el tipo de entrenamiento basado en una tarea diaria
    private func getTrainingTypeFromTask(_ task: DailyTaskItem) -> String {
        let title = task.title.lowercased()
        let description = task.description.lowercased()
        
        if title.contains("fuerza") || description.contains("fuerza") ||
           title.contains("pesas") || description.contains("pesas") ||
           title.contains("músculo") || description.contains("músculo") {
            return "Fuerza"
        } else if title.contains("cardio") || description.contains("cardio") ||
                  title.contains("correr") || description.contains("correr") ||
                  title.contains("caminar") || description.contains("caminar") {
            return "Cardio"
        } else if title.contains("resistencia") || description.contains("resistencia") {
            return "Resistencia"
        } else if title.contains("perder peso") || description.contains("perder peso") ||
                  title.contains("quemar") || description.contains("quemar") {
            return "Pérdida de peso"
        } else if title.contains("hipertrofia") || description.contains("hipertrofia") ||
                  title.contains("volumen") || description.contains("volumen muscular") {
            return "Hipertrofia"
        }
        
        // Si no se puede determinar, usar un valor predeterminado
        return "Fuerza"
    }
}

// MARK: - Vista previa para SwiftUI
struct ProcessView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessView(coachingService: CoachingService())
    }
}
