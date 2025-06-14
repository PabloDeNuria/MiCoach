import SwiftUI

struct TaskDetailView: View {
    let task: DailyTaskItem
    let coachingService: CoachingService
    let isInProgress: Bool
    let onTaskStarted: (String) -> Void
    let onTaskCompleted: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var isCompleted = false
    
    init(task: DailyTaskItem, coachingService: CoachingService, isInProgress: Bool, onTaskStarted: @escaping (String) -> Void, onTaskCompleted: @escaping (String) -> Void) {
        self.task = task
        self.coachingService = coachingService
        self.isInProgress = isInProgress
        self.onTaskStarted = onTaskStarted
        self.onTaskCompleted = onTaskCompleted
        self._isCompleted = State(initialValue: coachingService.progress?.completedTasks.contains(task.id) ?? false)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Icono de la tarea
                Image(systemName: taskIcon)
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 16) {
                    Text(task.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(task.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(task.estimatedTime)
                            .foregroundColor(.secondary)
                    }
                }
                
                if isInProgress && !isCompleted {
                    Button(action: completeTask) {
                        Text("Finalizar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                } else if !isCompleted {
                    Button(action: startTask) {
                        Text("Empezar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarItems(trailing: Button("Cerrar") { dismiss() })
        }
    }
    
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
    
    private func startTask() {
        withAnimation {
            onTaskStarted(task.id)
        }
        dismiss()
    }
    
    private func completeTask() {
        Task {
            do {
                try await coachingService.completeTask(taskId: task.id)
                withAnimation {
                    isCompleted = true
                    onTaskCompleted(task.id)
                }
                // Esperar un momento antes de cerrar
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            } catch {
                print("Error completing task: \(error)")
            }
        }
    }
}
