// OnboardingView.swift

import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var selectedObjectives: Set<String> = []
    @State private var userName = ""
    @State private var userEmail = ""
    @State private var fitnessGoal = "Fuerza"
    @State private var fitnessLevel = "Principiante"
    @State private var isCreatingPlan = false
    @ObservedObject var coachingService: CoachingService
    
    let objectives = [
        ("Salud", "figure.run", "Mejorar tu bienestar"),
        ("Productividad", "brain", "Ser más eficiente"),
        ("Aprendizaje", "book", "Aprender algo nuevo"),
        ("Otro", "circle.grid.3x3", "Objetivos personales")
    ]
    
    let fitnessGoals = ["Fuerza", "Hipertrofia", "Pérdida de peso", "Resistencia", "Tonificación"]
    let fitnessLevels = ["Principiante", "Intermedio", "Avanzado"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()
                
                if isCreatingPlan {
                    // Pantalla de carga mientras se crea el plan
                    creatingPlanView
                } else {
                    VStack(spacing: 0) {
                        // Progress bar
                        ProgressView(value: Double(currentStep + 1), total: showFitnessQuestions ? 4 : 3)
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding()
                        
                        // Content
                        TabView(selection: $currentStep) {
                            // Step 0: Welcome
                            welcomeStep
                                .tag(0)
                            
                            // Step 1: Basic info
                            basicInfoStep
                                .tag(1)
                            
                            // Step 2: Objective selection
                            objectiveSelectionStep
                                .tag(2)
                            
                            // Step 3: Fitness details (Condicional)
                            if showFitnessQuestions {
                                fitnessQuestionsStep
                                    .tag(3)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
            }
        }
    }
    
    private var showFitnessQuestions: Bool {
        selectedObjectives.contains("Salud")
    }
    
    private var creatingPlanView: some View {
        VStack(spacing: 32) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Creando tu plan personalizado")
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            Text("Estamos generando un plan único basado en tus objetivos y preferencias")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ProgressView()
                .scaleEffect(1.5)
                .padding(.top, 20)
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Bienvenido a MiCoach")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text("Tu asistente personal para alcanzar tus objetivos")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button("Comenzar") {
                withAnimation {
                    currentStep = 1
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
    
    private var basicInfoStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "Cuéntanos sobre ti",
                      subtitle: "Solo necesitamos algunos datos básicos")
            
            VStack(spacing: 16) {
                TextField("Tu nombre", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Tu email", text: $userEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal)
            }
            
            Spacer()
            navigationButtons
        }
        .padding()
    }
    
    private var objectiveSelectionStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "¿Qué quieres mejorar?",
                      subtitle: "Puedes elegir múltiples áreas")
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(objectives, id: \.0) { objective in
                        ObjectiveCard(
                            title: objective.0,
                            icon: objective.1,
                            description: objective.2,
                            isSelected: selectedObjectives.contains(objective.0)
                        )
                        .onTapGesture {
                            toggleObjective(objective.0)
                        }
                    }
                }
            }
            
            navigationButtons
        }
        .padding()
    }
    
    private var fitnessQuestionsStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(title: "Sobre tu entrenamiento",
                      subtitle: "Personaliza tu plan de fitness")
            
            VStack(alignment: .leading, spacing: 24) {
                Text("¿Cuál es tu objetivo principal?")
                    .font(.headline)
                
                Picker("Objetivo de fitness", selection: $fitnessGoal) {
                    ForEach(fitnessGoals, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom)
                
                Text("¿Cuál es tu nivel de experiencia?")
                    .font(.headline)
                
                Picker("Nivel de fitness", selection: $fitnessLevel) {
                    ForEach(fitnessLevels, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal)
            
            Spacer()
            navigationButtons
        }
        .padding()
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Atrás") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .padding()
                .disabled(isCreatingPlan)
            }
            
            Spacer()
            
            if (currentStep < 2) || (currentStep == 2) || (currentStep == 3) {
                Button(currentStep == (showFitnessQuestions ? 3 : 2) ? "Empezar" : "Siguiente") {
                    if currentStep == (showFitnessQuestions ? 3 : 2) {
                        createPlan()
                    } else {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
                .padding()
                .disabled(!canProceed || isCreatingPlan)
                .opacity(canProceed && !isCreatingPlan ? 1.0 : 0.6)
            }
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return !userName.isEmpty && !userEmail.isEmpty
        case 2: return !selectedObjectives.isEmpty
        case 3: return true
        default: return false
        }
    }
    
    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.largeTitle.bold())
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private func toggleObjective(_ objective: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedObjectives.contains(objective) {
                selectedObjectives.remove(objective)
            } else {
                selectedObjectives.insert(objective)
            }
        }
    }
    
    private func createPlan() {
        isCreatingPlan = true
        
        Task {
            do {
                // Crear usuario
                let user = User(
                    id: UUID().uuidString,
                    email: userEmail,
                    name: userName,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                // Crear evaluación simplificada con todos los objetivos seleccionados
                let preferences = AssessmentPreferences(
                    pace: "moderado",
                    learningStyle: "visual",
                    timeOfDay: "mañana"
                )
                
                // Construir metadata con información adicional si se seleccionó Salud
                var metadata: [String: String] = [:]
                if selectedObjectives.contains("Salud") {
                    metadata["fitnessGoal"] = fitnessGoal
                    metadata["fitnessLevel"] = fitnessLevel
                }
                
                let assessment = InitialAssessment(
                    id: UUID().uuidString,
                    userId: user.id,
                    mainObjective: selectedObjectives.joined(separator: ","),
                    currentSituation: "",
                    timeCommitment: "30 minutos",
                    resources: [],
                    preferences: preferences,
                    metadata: metadata,
                    createdAt: Date()
                )
                
                // Guardar usuario y crear plan
                try await coachingService.saveUser(user)
                _ = try await coachingService.createAssessment(assessmentData: assessment)
                
                print("✅ Plan creado exitosamente")
                
                // El ContentView detectará automáticamente que ahora hay un usuario
                // y cambiará a mostrar el DashboardView
                
            } catch {
                print("❌ Error creating plan: \(error)")
                await MainActor.run {
                    isCreatingPlan = false
                }
            }
        }
    }
}

struct ObjectiveCard: View {
    let title: String
    let icon: String
    let description: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .blue : .gray)
            Text(title)
                .font(.subheadline.bold())
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

extension Color {
    static let background = Color(.systemBackground)
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(coachingService: CoachingService())
    }
}
