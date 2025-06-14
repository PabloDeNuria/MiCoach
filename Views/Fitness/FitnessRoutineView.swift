// FitnessRoutineView.swift

import SwiftUI

struct FitnessRoutineView: View {
    let routine: FitnessRoutine
    @State private var completedExercises: Set<String> = []
    @State private var expandedExercise: String? = nil
    @State private var showingExerciseDetail = false
    @State private var selectedExercise: Exercise? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Encabezado
                    headerSection
                    
                    // Lista de ejercicios
                    exercisesList
                    
                    // Botón de completar rutina
                    completeButton
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarItems(trailing: Button("Cerrar") { dismiss() })
            .sheet(item: $selectedExercise) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(routine.day)
                .font(.title.bold())
            
            Text(routine.focus)
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("\(routine.exercises.count) ejercicios • \(estimateTime) min")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            
            progressBar
        }
    }
    
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(completedExercises.count)/\(routine.exercises.count) completados")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(completionPercentage))%")
                    .font(.caption.bold())
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: completionPercentage, total: 100)
                .tint(.blue)
                .scaleEffect(x: 1, y: 1.5)
        }
        .padding(.top, 8)
    }
    
    private var exercisesList: some View {
        VStack(spacing: 16) {
            ForEach(routine.exercises) { exercise in
                ExerciseRow(
                    exercise: exercise,
                    isCompleted: completedExercises.contains(exercise.name),
                    isExpanded: expandedExercise == exercise.name,
                    onComplete: {
                        toggleComplete(exercise: exercise)
                    },
                    onTap: {
                        withAnimation {
                            if expandedExercise == exercise.name {
                                expandedExercise = nil
                            } else {
                                expandedExercise = exercise.name
                            }
                        }
                    },
                    onInfo: {
                        selectedExercise = exercise
                    }
                )
            }
        }
    }
    
    private var completeButton: some View {
        Button(action: {
            // Marcar toda la rutina como completada
            for exercise in routine.exercises {
                completedExercises.insert(exercise.name)
            }
            
            // Dar feedback y cerrar después de un momento
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }) {
            HStack {
                Spacer()
                
                if completedExercises.count == routine.exercises.count {
                    Text("¡Rutina completada!")
                        .fontWeight(.semibold)
                } else {
                    Text("Completar rutina")
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            .padding()
            .background(completedExercises.count == routine.exercises.count ? Color.green : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(completedExercises.isEmpty)
        .padding(.top, 16)
    }
    
    private var completionPercentage: Double {
        return Double(completedExercises.count) / Double(routine.exercises.count) * 100.0
    }
    
    private var estimateTime: Int {
        // Estimación aproximada basada en número de ejercicios, series y descanso
        var totalMinutes = 0
        
        for exercise in routine.exercises {
            let restTimePerSet = extractRestTime(exercise.rest)
            let timePerExercise = exercise.sets * restTimePerSet + 2 // Añadir 2 minutos para la ejecución
            totalMinutes += timePerExercise
        }
        
        return totalMinutes
    }
    
    private func extractRestTime(_ restString: String) -> Int {
        // Extrae tiempo de descanso en minutos de strings como "60 seg", "2 min", etc.
        if restString.contains("seg") {
            if let seconds = Int(restString.components(separatedBy: " ").first ?? "60") {
                return max(1, seconds / 60) // Mínimo 1 minuto
            }
        } else if restString.contains("min") {
            if let minutes = Int(restString.components(separatedBy: " ").first ?? "1") {
                return minutes
            }
        }
        return 1 // Valor por defecto
    }
    
    private func toggleComplete(exercise: Exercise) {
        withAnimation {
            if completedExercises.contains(exercise.name) {
                completedExercises.remove(exercise.name)
            } else {
                completedExercises.insert(exercise.name)
            }
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    let isCompleted: Bool
    let isExpanded: Bool
    let onComplete: () -> Void
    let onTap: () -> Void
    let onInfo: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Fila principal (siempre visible)
            HStack(spacing: 12) {
                // Checkbox
                Button(action: onComplete) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isCompleted ? .green : .gray)
                }
                
                // Nombre del ejercicio
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                
                Spacer()
                
                // Sets y reps
                Text("\(exercise.sets) × \(exercise.reps)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Botón de información
                Button(action: onInfo) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                
                // Botón para expandir/colapsar
                Button(action: onTap) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(isExpanded ? 12 : 12)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            
            // Detalles adicionales (visibles solo al expandir)
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    HStack {
                        detailItem(
                            title: "Series",
                            value: "\(exercise.sets)",
                            icon: "number.circle.fill"
                        )
                        
                        detailItem(
                            title: "Reps",
                            value: exercise.reps,
                            icon: "repeat.circle.fill"
                        )
                        
                        detailItem(
                            title: "Peso",
                            value: exercise.weight,
                            icon: "scalemass.fill"
                        )
                        
                        detailItem(
                            title: "Descanso",
                            value: exercise.rest,
                            icon: "clock.fill"
                        )
                    }
                    
                    if let notes = exercise.notes, !notes.isEmpty {
                        Text("Notas: \(notes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private func detailItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Encabezado
                    Text(exercise.name)
                        .font(.largeTitle.bold())
                    
                    // Detalles del ejercicio
                    exerciseDetails
                    
                    // Descripción e instrucciones
                    exerciseInstructions
                    
                    // Imagen o ilustración (placeholder)
                    exerciseImage
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarItems(trailing: Button("Cerrar") { dismiss() })
        }
    }
    
    private var exerciseDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detalles")
                .font(.headline)
            
            HStack(spacing: 16) {
                detailCard(title: "Series", value: "\(exercise.sets)", icon: "number.circle.fill")
                detailCard(title: "Repeticiones", value: exercise.reps, icon: "repeat.circle.fill")
            }
            
            HStack(spacing: 16) {
                detailCard(title: "Peso", value: exercise.weight, icon: "scalemass.fill")
                detailCard(title: "Descanso", value: exercise.rest, icon: "clock.fill")
            }
        }
    }
    
    private var exerciseInstructions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Instrucciones")
                .font(.headline)
            
            Text(getInstructions(for: exercise.name))
                .font(.body)
                .lineSpacing(6)
            
            if let notes = exercise.notes, !notes.isEmpty {
                Text("Notas adicionales")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text(notes)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var exerciseImage: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ejecución")
                .font(.headline)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(1.5, contentMode: .fit)
                .overlay(
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                )
                .cornerRadius(12)
        }
    }
    
    private func detailCard(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // Instrucciones simplificadas para algunos ejercicios comunes
    private func getInstructions(for exercise: String) -> String {
        switch exercise.lowercased() {
        case let name where name.contains("sentadilla"):
            return "1. Ponte de pie con los pies separados al ancho de los hombros.\n2. Mantén la espalda recta y el pecho elevado.\n3. Baja las caderas como si fueras a sentarte en una silla.\n4. Detente cuando tus muslos estén paralelos al suelo.\n5. Regresa a la posición inicial empujando a través de los talones."
        case let name where name.contains("peso muerto"):
            return "1. Párate con los pies separados al ancho de las caderas.\n2. Flexiona las rodillas y las caderas para agarrar la barra.\n3. Mantén la espalda recta y el pecho elevado.\n4. Levanta la barra manteniendo cerca del cuerpo.\n5. Extiende completamente las caderas y las rodillas en la parte superior.\n6. Baja la barra controladamente."
        case let name where name.contains("press"):
            return "1. Siéntate en un banco con respaldo.\n2. Agarra la barra o mancuernas con las palmas hacia adelante.\n3. Levanta el peso a la altura de los hombros.\n4. Empuja hacia arriba extendiendo completamente los brazos.\n5. Baja el peso controladamente hasta la posición inicial."
        default:
            return "Realiza el ejercicio con buena técnica, manteniendo una postura adecuada en todo momento. Concéntrate en sentir el músculo trabajando y controla el movimiento tanto en la fase concéntrica como excéntrica."
        }
    }
}

struct FitnessRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessRoutineView(routine:
            FitnessRoutine(
                id: "1",
                day: "Día 1",
                focus: "Piernas y Core",
                exercises: [
                    Exercise(name: "Sentadillas", sets: 3, reps: "8-10", weight: "Moderado", rest: "2 min"),
                    Exercise(name: "Peso muerto", sets: 3, reps: "8", weight: "Moderado", rest: "2 min")
                ]
            )
        )
    }
}
