// Models/Models.swift
import SwiftUI
import Foundation

// MARK: - User Model
struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let name: String
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Assessment Models
struct InitialAssessment: Codable, Identifiable {
    let id: String
    let userId: String
    let mainObjective: String
    let currentSituation: String
    let timeCommitment: String
    let resources: [String]
    let preferences: AssessmentPreferences
    let metadata: [String: String]  // Nuevo campo para datos adicionales específicos de cada objetivo
    let createdAt: Date
}

struct AssessmentPreferences: Codable {
    let pace: String // "lento", "moderado", "intensivo"
    let learningStyle: String // "visual", "auditivo", "práctico"
    let timeOfDay: String // "mañana", "tarde", "noche"
}

// MARK: - Plan Models
struct PersonalizedPlan: Codable, Identifiable {
    let id: String
    let userId: String
    let assessmentId: String
    let objective: String
    let timeframe: String
    let milestones: [Milestone]
    let dailyGuidance: [DailyTask]
    let fitnessRoutines: [FitnessRoutine]?  // Nueva propiedad opcional
    let createdAt: Date
}

struct Milestone: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let targetDate: Date
    let order: Int
}

struct DailyTask: Codable, Identifiable {
    let id: String
    let day: Int
    let tasks: [DailyTaskItem]
}

struct DailyTaskItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let importance: String
    let category: String
    let estimatedTime: String
}

// MARK: - Fitness Models
struct FitnessRoutine: Codable, Identifiable {
    let id: String
    let day: String  // Ej: "Día 1", "Lunes", etc.
    let focus: String  // Ej: "Pecho y Tríceps", "Piernas", etc.
    let exercises: [Exercise]
}

struct Exercise: Codable, Identifiable {
    var id: String { name }  // Usamos el nombre como ID para simplificar
    let name: String
    let sets: Int
    let reps: String  // Ej: "8-10", "12", "Hasta fallo"
    let weight: String  // Ej: "Ligero", "Moderado", "Pesado", "70% 1RM"
    let rest: String  // Ej: "60 seg", "2 min"
    var notes: String?
}

// MARK: - Progress Model
struct Progress: Codable, Identifiable {
    let id: String
    let userId: String
    let planId: String
    var currentDay: Int
    var completedTasks: [String]
    var streak: Int
    var lastActivity: Date
    let createdAt: Date
    var updatedAt: Date
}

// MARK: - Data Service
@MainActor
class DataService: ObservableObject {
    @Published var currentUser: User?
    @Published var currentPlan: PersonalizedPlan?
    @Published var progress: Progress?
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadStoredData()
    }
    
    // MARK: - Storage Management
    func loadStoredData() {
        // Load User
        if let userData = userDefaults.data(forKey: "currentUser") {
            currentUser = try? JSONDecoder().decode(User.self, from: userData)
        }
        
        // Load Plan
        if let planData = userDefaults.data(forKey: "currentPlan") {
            currentPlan = try? JSONDecoder().decode(PersonalizedPlan.self, from: planData)
        }
        
        // Load Progress
        if let progressData = userDefaults.data(forKey: "currentProgress") {
            progress = try? JSONDecoder().decode(Progress.self, from: progressData)
        }
    }
    
    func saveUser(_ user: User) throws {
        let data = try JSONEncoder().encode(user)
        userDefaults.set(data, forKey: "currentUser")
        self.currentUser = user
    }
    
    func saveAssessment(_ assessment: InitialAssessment) throws {
        let data = try JSONEncoder().encode(assessment)
        userDefaults.set(data, forKey: "currentAssessment")
    }
    
    func savePlan(_ plan: PersonalizedPlan) throws {
        let data = try JSONEncoder().encode(plan)
        userDefaults.set(data, forKey: "currentPlan")
        self.currentPlan = plan
    }
    
    func saveProgress(_ progress: Progress) throws {
        let data = try JSONEncoder().encode(progress)
        userDefaults.set(data, forKey: "currentProgress")
        self.progress = progress
    }
}

// MARK: - AI Service
class AIService {
    static func generatePlan(for assessment: InitialAssessment) async -> PersonalizedPlan {
        let timeframe = determineTimeframe(assessment: assessment)
        let milestones = generateMilestones(assessment: assessment, timeframe: timeframe)
        let dailyGuidance = generateDailyTasks(assessment: assessment, timeframe: timeframe)
        
        // Verificar si se solicita rutina de fitness
        var fitnessRoutines: [FitnessRoutine]? = nil
        if assessment.mainObjective.contains("Salud"),
           let fitnessGoal = assessment.metadata["fitnessGoal"],
           let fitnessLevel = assessment.metadata["fitnessLevel"] {
            fitnessRoutines = generateFitnessRoutine(goal: fitnessGoal, level: fitnessLevel)
        }
        
        return PersonalizedPlan(
            id: UUID().uuidString,
            userId: assessment.userId,
            assessmentId: assessment.id,
            objective: assessment.mainObjective,
            timeframe: timeframe,
            milestones: milestones,
            dailyGuidance: dailyGuidance,
            fitnessRoutines: fitnessRoutines,
            createdAt: Date()
        )
    }
    
    private static func determineTimeframe(assessment: InitialAssessment) -> String {
        let pace = assessment.preferences.pace
        let objectives = assessment.mainObjective.components(separatedBy: ",")
        
        // Usar el timeline más largo si hay múltiples objetivos
        var maxDays = 30
        
        objectives.forEach { objective in
            let trimmedObjective = objective.trimmingCharacters(in: .whitespaces)
            let daysForObjective: Int
            
            switch trimmedObjective {
            case "Salud":
                daysForObjective = pace == "intensivo" ? 30 : pace == "moderado" ? 60 : 90
            case "Productividad":
                daysForObjective = pace == "intensivo" ? 21 : pace == "moderado" ? 30 : 45
            case "Aprendizaje":
                daysForObjective = pace == "intensivo" ? 30 : pace == "moderado" ? 60 : 90
            default:
                daysForObjective = 30
            }
            
            maxDays = max(maxDays, daysForObjective)
        }
        
        return "\(maxDays) dias"
    }
    
    private static func generateMilestones(assessment: InitialAssessment, timeframe: String) -> [Milestone] {
        let days = Int(timeframe.components(separatedBy: " ")[0]) ?? 30
        var milestones: [Milestone] = []
        
        let milestonePoints = calculateMilestonePoints(days: days)
        
        for (index, day) in milestonePoints.enumerated() {
            milestones.append(Milestone(
                id: UUID().uuidString,
                title: generateMilestoneTitle(for: assessment.mainObjective, index: index),
                description: generateMilestoneDescription(assessment: assessment, index: index),
                targetDate: calculateTargetDate(day: day),
                order: index + 1
            ))
        }
        
        return milestones
    }
    
    private static func generateDailyTasks(assessment: InitialAssessment, timeframe: String) -> [DailyTask] {
        let days = Int(timeframe.components(separatedBy: " ")[0]) ?? 30
        var dailyTasks: [DailyTask] = []
        
        for day in 1...days {
            let tasks = generateTasksForDay(assessment: assessment, day: day, totalDays: days)
            dailyTasks.append(DailyTask(
                id: UUID().uuidString,
                day: day,
                tasks: tasks
            ))
        }
        
        return dailyTasks
    }
    
    private static func generateTasksForDay(assessment: InitialAssessment, day: Int, totalDays: Int) -> [DailyTaskItem] {
        var tasks: [DailyTaskItem] = []
        let progressPercentage = Double(day) / Double(totalDays)
        
        // Dividir los objetivos (pueden ser múltiples separados por coma)
        let objectives = assessment.mainObjective.components(separatedBy: ",")
        
        for objective in objectives {
            let trimmedObjective = objective.trimmingCharacters(in: .whitespaces)
            
            // Salud
            if trimmedObjective.contains("Salud") {
                if let fitnessGoal = assessment.metadata["fitnessGoal"],
                   let fitnessLevel = assessment.metadata["fitnessLevel"] {
                    // Si es día de entrenamiento (simple alternancia por ahora)
                    let isTrainingDay = (day % 2 == 1)
                    
                    if isTrainingDay {
                        tasks.append(DailyTaskItem(
                            id: UUID().uuidString,
                            title: "Entrenamiento de \(fitnessGoal)",
                            description: "Sigue tu rutina de \(fitnessGoal) para hoy",
                            importance: "Fundamental para tu progreso físico",
                            category: "Fitness",
                            estimatedTime: "45-60 minutos"
                        ))
                    } else {
                        let duration = day <= 7 ? 30 : day <= totalDays / 2 ? Int(progressPercentage * 60) : 60
                        tasks.append(DailyTaskItem(
                            id: UUID().uuidString,
                            title: "Caminar \(duration) minutos",
                            description: "Actividad cardiovascular en día de descanso",
                            importance: "Mantener un estilo de vida activo",
                            category: "Salud",
                            estimatedTime: "\(duration) minutos"
                        ))
                    }
                } else {
                    // Fallback original
                    let duration = day <= 7 ? 30 : day <= totalDays / 2 ? Int(progressPercentage * 60) : 60
                    tasks.append(DailyTaskItem(
                        id: UUID().uuidString,
                        title: "Caminar \(duration) minutos",
                        description: "Actividad física para mejorar tu salud",
                        importance: "Mantener un estilo de vida activo",
                        category: "Salud",
                        estimatedTime: "\(duration) minutos"
                    ))
                }
            }
            
            // Aprendizaje
            if trimmedObjective.contains("Aprendizaje") {
                let pages = day <= 7 ? 20 : day <= totalDays / 2 ? Int(progressPercentage * 50) : 50
                tasks.append(DailyTaskItem(
                    id: UUID().uuidString,
                    title: "Leer \(pages) páginas",
                    description: "Lectura diaria para expandir tus conocimientos",
                    importance: "El aprendizaje constante es clave",
                    category: "Aprendizaje",
                    estimatedTime: day <= 7 ? "30-40 minutos" : "1 hora"
                ))
            }
            
            // Productividad
            if trimmedObjective.contains("Productividad") {
                let taskTitle = day <= 7 ? "Planifica tus 3 tareas principales" : day <= totalDays / 2 ? "Optimiza tu flujo de trabajo" : "Revisa y ajusta tu sistema"
                tasks.append(DailyTaskItem(
                    id: UUID().uuidString,
                    title: taskTitle,
                    description: "Estructura tu día para máxima eficiencia",
                    importance: "La organización es fundamental",
                    category: "Productividad",
                    estimatedTime: "20 minutos"
                ))
            }
            
            // Otro/Personalizado
            if trimmedObjective.contains("Otro") {
                let duration = day <= 7 ? 30 : Int(progressPercentage * 60)
                tasks.append(DailyTaskItem(
                    id: UUID().uuidString,
                    title: "Dedica \(duration) minutos a tu objetivo personal",
                    description: "Avanza hacia tus metas personales",
                    importance: "Cada día cuenta",
                    category: "Otro",
                    estimatedTime: "\(duration) minutos"
                ))
            }
        }
        
        // Solo agregar reflexión si hay tareas
        if !tasks.isEmpty {
            tasks.append(DailyTaskItem(
                id: UUID().uuidString,
                title: "Reflexión diaria",
                description: "Registra tu progreso de hoy",
                importance: "La autoevaluación te ayuda a mejorar",
                category: "General",
                estimatedTime: "5 minutos"
            ))
        }
        
        return tasks
    }
    
    // MARK: - Fitness Routine Generation
    static func generateFitnessRoutine(goal: String, level: String) -> [FitnessRoutine] {
        var routines: [FitnessRoutine] = []
        
        // Número de días según nivel
        let daysPerWeek: Int
        switch level {
        case "Principiante":
            daysPerWeek = 3
        case "Intermedio":
            daysPerWeek = 4
        case "Avanzado":
            daysPerWeek = 5
        default:
            daysPerWeek = 3
        }
        
        // Generar rutina según objetivo
        switch goal {
        case "Fuerza":
            routines = generateStrengthRoutine(daysPerWeek: daysPerWeek, level: level)
        case "Hipertrofia":
            routines = generateHypertrophyRoutine(daysPerWeek: daysPerWeek, level: level)
        case "Pérdida de peso":
            routines = generateWeightLossRoutine(daysPerWeek: daysPerWeek, level: level)
        case "Resistencia":
            routines = generateEnduranceRoutine(daysPerWeek: daysPerWeek, level: level)
        case "Tonificación":
            routines = generateToneRoutine(daysPerWeek: daysPerWeek, level: level)
        default:
            routines = generateGeneralRoutine(daysPerWeek: daysPerWeek, level: level)
        }
        
        return routines
    }

    private static func generateStrengthRoutine(daysPerWeek: Int, level: String) -> [FitnessRoutine] {
        var routines: [FitnessRoutine] = []
        
        if daysPerWeek == 3 {
            // Rutina de fuerza 3 días (principiante)
            routines = [
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 1",
                    focus: "Piernas y Core",
                    exercises: [
                        Exercise(name: "Sentadillas", sets: 3, reps: "8-10", weight: "Moderado", rest: "2 min"),
                        Exercise(name: "Peso muerto", sets: 3, reps: "8", weight: "Moderado", rest: "2 min"),
                        Exercise(name: "Prensa de piernas", sets: 3, reps: "10", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Plancha", sets: 3, reps: "30 seg", weight: "Peso corporal", rest: "60 seg")
                    ]
                ),
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 2",
                    focus: "Pecho y Espalda",
                    exercises: [
                        Exercise(name: "Press de banca", sets: 3, reps: "8", weight: "Moderado", rest: "2 min"),
                        Exercise(name: "Remo con barra", sets: 3, reps: "8-10", weight: "Moderado", rest: "2 min"),
                        Exercise(name: "Dominadas asistidas", sets: 3, reps: "6-8", weight: "Peso corporal", rest: "90 seg"),
                        Exercise(name: "Fondos en banco", sets: 3, reps: "10", weight: "Peso corporal", rest: "90 seg")
                    ]
                ),
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 3",
                    focus: "Hombros y Brazos",
                    exercises: [
                        Exercise(name: "Press militar", sets: 3, reps: "8-10", weight: "Moderado", rest: "2 min"),
                        Exercise(name: "Curl de bíceps", sets: 3, reps: "10", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Extensión de tríceps", sets: 3, reps: "10", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Elevaciones laterales", sets: 3, reps: "12", weight: "Ligero", rest: "60 seg")
                    ]
                )
            ]
        } else if daysPerWeek == 4 {
            // Rutina de fuerza 4 días (intermedio)
            routines = [
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 1",
                    focus: "Piernas",
                    exercises: [
                        Exercise(name: "Sentadillas", sets: 4, reps: "6-8", weight: "Pesado", rest: "2-3 min"),
                        Exercise(name: "Peso muerto", sets: 4, reps: "6", weight: "Pesado", rest: "3 min"),
                        Exercise(name: "Prensa de piernas", sets: 3, reps: "8-10", weight: "Moderado-Pesado", rest: "2 min"),
                        Exercise(name: "Extensiones de cuádriceps", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Curl de isquiotibiales", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg")
                    ]
                ),
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 2",
                    focus: "Pecho y Tríceps",
                    exercises: [
                        Exercise(name: "Press de banca", sets: 4, reps: "6-8", weight: "Pesado", rest: "2-3 min"),
                        Exercise(name: "Press inclinado con mancuernas", sets: 3, reps: "8-10", weight: "Moderado-Pesado", rest: "2 min"),
                        Exercise(name: "Fondos", sets: 3, reps: "8-10", weight: "Peso corporal", rest: "2 min"),
                        Exercise(name: "Extensiones de tríceps con polea", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg")
                    ]
                ),
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 3",
                    focus: "Espalda y Bíceps",
                    exercises: [
                        Exercise(name: "Dominadas", sets: 4, reps: "6-8", weight: "Peso corporal", rest: "2-3 min"),
                        Exercise(name: "Remo con barra", sets: 4, reps: "6-8", weight: "Pesado", rest: "2-3 min"),
                        Exercise(name: "Remo con mancuerna", sets: 3, reps: "10", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Curl de bíceps con barra", sets: 3, reps: "8-10", weight: "Moderado-Pesado", rest: "2 min"),
                        Exercise(name: "Curl martillo", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg")
                    ]
                ),
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 4",
                    focus: "Hombros y Core",
                    exercises: [
                        Exercise(name: "Press militar", sets: 4, reps: "6-8", weight: "Pesado", rest: "2-3 min"),
                        Exercise(name: "Elevaciones laterales", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Remo al mentón", sets: 3, reps: "8-10", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Plancha", sets: 3, reps: "45-60 seg", weight: "Peso corporal", rest: "60 seg"),
                        Exercise(name: "Crunch abdominal", sets: 3, reps: "15-20", weight: "Peso corporal", rest: "60 seg")
                    ]
                )
            ]
        } else {
            // Rutina de fuerza 5 días (avanzado)
            routines = [
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 1",
                    focus: "Piernas",
                    exercises: [
                        Exercise(name: "Sentadillas", sets: 5, reps: "5", weight: "Pesado", rest: "3 min"),
                        Exercise(name: "Peso muerto", sets: 5, reps: "5", weight: "Pesado", rest: "3 min"),
                        Exercise(name: "Prensa de piernas", sets: 4, reps: "8", weight: "Pesado", rest: "2 min"),
                        Exercise(name: "Extensiones de cuádriceps", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Curl de isquiotibiales", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Elevaciones de pantorrilla", sets: 4, reps: "15-20", weight: "Moderado", rest: "60 seg")
                    ]
                ),
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 2",
                    focus: "Pecho",
                    exercises: [
                        Exercise(name: "Press de banca", sets: 5, reps: "5", weight: "Pesado", rest: "3 min"),
                        Exercise(name: "Press inclinado con barra", sets: 4, reps: "6-8", weight: "Pesado", rest: "2-3 min"),
                        Exercise(name: "Aperturas con mancuernas", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Fondos", sets: 4, reps: "8-10", weight: "Peso corporal+carga", rest: "2 min"),
                        Exercise(name: "Press declinado con mancuernas", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg")
                    ]
                ),
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 3",
                    focus: "Espalda",
                    exercises: [
                        Exercise(name: "Dominadas", sets: 5, reps: "5-8", weight: "Peso corporal+carga", rest: "2-3 min"),
                        Exercise(name: "Remo con barra", sets: 5, reps: "5", weight: "Pesado", rest: "3 min"),
                        Exercise(name: "Remo con mancuerna", sets: 3, reps: "8-10", weight: "Pesado", rest: "2 min"),
                        Exercise(name: "Jalón al pecho", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Peso muerto rumano", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg")
                    ]
                ),
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 4",
                    focus: "Hombros",
                    exercises: [
                        Exercise(name: "Press militar", sets: 5, reps: "5", weight: "Pesado", rest: "3 min"),
                        Exercise(name: "Press Arnold", sets: 4, reps: "8-10", weight: "Moderado-Pesado", rest: "2 min"),
                        Exercise(name: "Elevaciones laterales", sets: 4, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Elevaciones frontales", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Remo al mentón", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Encogimientos de hombros", sets: 4, reps: "12-15", weight: "Pesado", rest: "90 seg")
                    ]
                ),
                FitnessRoutine(
                    id: UUID().uuidString,
                    day: "Día 5",
                    focus: "Brazos y Core",
                    exercises: [
                        Exercise(name: "Curl de bíceps con barra", sets: 4, reps: "8-10", weight: "Pesado", rest: "2 min"),
                        Exercise(name: "Curl concentrado", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Extensión de tríceps con polea", sets: 4, reps: "8-10", weight: "Pesado", rest: "2 min"),
                        Exercise(name: "Press francés", sets: 3, reps: "10-12", weight: "Moderado", rest: "90 seg"),
                        Exercise(name: "Plancha", sets: 4, reps: "60 seg", weight: "Peso corporal", rest: "60 seg"),
                        Exercise(name: "Rueda abdominal", sets: 3, reps: "10-15", weight: "Peso corporal", rest: "90 seg")
                    ]
                )
            ]
        }
        
        return routines
    }

    private static func generateHypertrophyRoutine(daysPerWeek: Int, level: String) -> [FitnessRoutine] {
        // Usar la rutina de fuerza como base por ahora
        return generateStrengthRoutine(daysPerWeek: daysPerWeek, level: level)
    }

    private static func generateWeightLossRoutine(daysPerWeek: Int, level: String) -> [FitnessRoutine] {
        // Usar la rutina de fuerza como base por ahora
        return generateStrengthRoutine(daysPerWeek: daysPerWeek, level: level)
    }

    private static func generateEnduranceRoutine(daysPerWeek: Int, level: String) -> [FitnessRoutine] {
        // Usar la rutina de fuerza como base por ahora
        return generateStrengthRoutine(daysPerWeek: daysPerWeek, level: level)
    }

    private static func generateToneRoutine(daysPerWeek: Int, level: String) -> [FitnessRoutine] {
        // Usar la rutina de fuerza como base por ahora
        return generateStrengthRoutine(daysPerWeek: daysPerWeek, level: level)
    }

    private static func generateGeneralRoutine(daysPerWeek: Int, level: String) -> [FitnessRoutine] {
        // Usar la rutina de fuerza como base por ahora
        return generateStrengthRoutine(daysPerWeek: daysPerWeek, level: level)
    }
    
    // MARK: - Helper Methods
    private static func calculateMilestonePoints(days: Int) -> [Int] {
        if days <= 30 {
            return [5, 10, 20, 30]
        } else if days <= 60 {
            return [7, 15, 30, 45, 60]
        } else {
            return [10, 30, 60, 90]
        }
    }
    
    private static func generateMilestoneTitle(for objectives: String, index: Int) -> String {
        let objectivesList = objectives.components(separatedBy: ",")
        
        // Si hay múltiples objetivos, usar títulos generales
        if objectivesList.count > 1 {
            return ["Construir Bases", "Crear Rutinas", "Consolidar Hábitos", "Dominar el Sistema"][index % 4]
        }
        
        // Si hay un solo objetivo, usar títulos específicos
        let mainObjective = objectivesList.first?.trimmingCharacters(in: .whitespaces) ?? ""
        
        switch mainObjective {
        case "Salud":
            return ["Establecer Bases", "Primera Rutina", "Consistencia Diaria", "Hábito Consolidado"][index % 4]
        case "Productividad":
                   return ["Sistema Básico", "Automatización", "Optimización", "Maestría"][index % 4]
               case "Aprendizaje":
                   return ["Fundamentos", "Aplicación", "Profundización", "Dominio"][index % 4]
               default:
                   return "Hito #\(index + 1)"
               }
           }
           
           private static func generateMilestoneDescription(assessment: InitialAssessment, index: Int) -> String {
               let objective = assessment.mainObjective
               return "Descripción del hito \(index + 1) para \(objective)"
           }
           
           private static func calculateTargetDate(day: Int) -> Date {
               return Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
           }
           
           private static func getInitialHabitTask(category: String) -> String {
               switch category.lowercased() {
               case "salud":
                   return "Caminar 30 minutos"
               case "productividad":
                   return "Planifica tus 3 tareas principales del día"
               case "aprendizaje":
               return "Leer 20 páginas"
                   case "otro":
                       return "Dedica 30 minutos a tu objetivo"
                   default:
                       return "Comienza con 30 minutos de actividad"
                   }
               }
               
               private static func getBuildingTask(category: String, progress: Double) -> String {
                   let timeInterval = Int(progress * 60) // De 0 a 60 minutos
                   let readingPages = Int(progress * 50) // De 0 a 50 páginas
                   
                   switch category.lowercased() {
                   case "salud":
                       return "Caminar \(timeInterval) minutos"
                   case "productividad":
                       return "Enfócate en tu tarea prioritaria por \(timeInterval) minutos"
                   case "aprendizaje":
                       return "Leer \(readingPages) páginas"
                   case "otro":
                       return "Avanza en tu objetivo \(timeInterval) minutos"
                   default:
                       return "Dedica \(timeInterval) minutos a tu actividad"
                   }
               }
               
               private static func getConsolidationTask(category: String, progress: Double) -> String {
                   switch category.lowercased() {
                   case "salud":
                       return "Caminar 60 minutos"
                   case "productividad":
                       return "Revisa tu productividad y ajusta tu sistema"
                   case "aprendizaje":
                       return "Leer 50 páginas"
                   case "otro":
                       return "Consolida tu hábito con una sesión de 60 minutos"
                   default:
                       return "Mantén tu rutina completa"
                   }
               }
           }

           // MARK: - Coaching Service
           @MainActor
           class CoachingService: ObservableObject {
               @Published var currentUser: User?
               @Published var currentPlan: PersonalizedPlan?
               @Published var progress: Progress?
               
               private let dataService = DataService()
               
               init() {
                   Task {
                       await loadData()
                   }
               }
               
               func loadData() async {
                   self.currentUser = dataService.currentUser
                   self.currentPlan = dataService.currentPlan
                   self.progress = dataService.progress
               }
               
               // MARK: - User Methods
               func saveUser(_ user: User) async throws {
                   try dataService.saveUser(user)
                   self.currentUser = user
               }
               
               // MARK: - Assessment Methods
               func createAssessment(assessmentData: InitialAssessment) async throws -> PersonalizedPlan {
                   let assessment = assessmentData
                   
                   // Guardar evaluación
                   try dataService.saveAssessment(assessment)
                   
                   // Generar plan personalizado
                   let plan = await AIService.generatePlan(for: assessment)
                   
                   // Guardar plan
                   try dataService.savePlan(plan)
                   
                   // Inicializar progreso
                   let initialProgress = Progress(
                       id: UUID().uuidString,
                       userId: assessment.userId,
                       planId: plan.id,
                       currentDay: 1,
                       completedTasks: [],
                       streak: 0,
                       lastActivity: Date(),
                       createdAt: Date(),
                       updatedAt: Date()
                   )
                   try dataService.saveProgress(initialProgress)
                   
                   self.currentPlan = plan
                   self.progress = initialProgress
                   return plan
               }
               
               // MARK: - Plan Methods
               func getDailyGuidance(for day: Int? = nil) -> DailyTask? {
                   guard let plan = currentPlan,
                         let progress = progress else { return nil }
                   
                   let currentDay = day ?? progress.currentDay
                   return plan.dailyGuidance.first { $0.day == currentDay }
               }
               
               // MARK: - Progress Methods
               func completeTask(taskId: String) async throws {
                   guard var progress = progress else { return }
                   
                   // Actualizar progreso
                   var updatedProgress = progress
                   updatedProgress.completedTasks.append(taskId)
                   updatedProgress.lastActivity = Date()
                   updatedProgress.updatedAt = Date()
                   
                   // Verificar si completó todas las tareas del día
                   if await hasCompletedDayTasks(day: progress.currentDay) {
                       updatedProgress.currentDay += 1
                       updatedProgress.streak = calculateStreak(progress: progress)
                   }
                   
                   try dataService.saveProgress(updatedProgress)
                   self.progress = updatedProgress
               }
               
               func getProgress() -> (currentDay: Int, totalDays: Int, streak: Int, completionPercentage: Double, nextMilestone: Milestone?)? {
                   guard let progress = progress,
                         let plan = currentPlan else { return nil }
                   
                   let totalDays = Int(plan.timeframe.components(separatedBy: " ")[0]) ?? 30
                   let completionPercentage = Double(progress.currentDay) / Double(totalDays) * 100
                   let nextMilestone = getNextMilestone(milestones: plan.milestones, currentDay: progress.currentDay)
                   
                   return (
                       currentDay: progress.currentDay,
                       totalDays: totalDays,
                       streak: progress.streak,
                       completionPercentage: completionPercentage,
                       nextMilestone: nextMilestone
                   )
               }
               
               // Método para resetear las tareas de hoy
               func resetTodayTasks() {
                   guard var progress = progress else { return }
                   
                   // Remover las tareas del día actual de completadas
                   if let dailyTask = getDailyGuidance() {
                       let taskIds = dailyTask.tasks.map { $0.id }
                       progress.completedTasks = progress.completedTasks.filter { !taskIds.contains($0) }
                       
                       do {
                           try dataService.saveProgress(progress)
                           self.progress = progress
                       } catch {
                           print("Error resetting day: \(error)")
                       }
                   }
               }
               
               // MARK: - Helper Methods
               private func hasCompletedDayTasks(day: Int) async -> Bool {
                   guard let plan = currentPlan,
                         let progress = progress else { return false }
                   
                   if let dailyTask = plan.dailyGuidance.first(where: { $0.day == day }) {
                       let taskIds = dailyTask.tasks.map { $0.id }
                       return taskIds.allSatisfy { progress.completedTasks.contains($0) }
                   }
                   return false
               }
               
               private func calculateStreak(progress: Progress) -> Int {
                   let calendar = Calendar.current
                   let today = Date()
                   
                   if let lastActivity = calendar.dateInterval(of: .day, for: progress.lastActivity),
                      let currentDay = calendar.dateInterval(of: .day, for: today),
                      lastActivity.contains(currentDay.start) {
                       return progress.streak + 1
                   } else {
                       return 1
                   }
               }
               
               private func getNextMilestone(milestones: [Milestone], currentDay: Int) -> Milestone? {
                   let calendar = Calendar.current
                   return milestones
                       .sorted { $0.order < $1.order }
                       .first { calendar.compare($0.targetDate, to: Date(), toGranularity: .day) != .orderedAscending }
               }
           }

           // MARK: - Profile Model
           struct ProfileData: Codable, Identifiable {
               let id: String
               let name: String
               let email: String
               let profileImage: String?
               let joinDate: Date
               let totalActivities: Int
               let totalAchievements: Int
               let currentStreak: Int
           }

           // MARK: - Activity Model
           struct Activity: Codable, Identifiable {
               let id: String
               let title: String
               let description: String
               let date: Date
               let image: String?
               let type: String // "exercise", "meditation", "reading", etc.
               let duration: String
               let category: String
               let completed: Bool
               let energy: Int // 1-3 scale
               let mood: String? // optional mood after activity
           }

           // MARK: - Achievement Model
           struct Achievement: Codable, Identifiable {
               let id: String
               let title: String
               let description: String
               let icon: String
               let dateEarned: Date
               let category: String
               let level: Int // 1-5 achievement level
               let points: Int // points earned for this achievement
               
               enum AchievementType: String, Codable {
                   case streak = "streak"
                   case milestone = "milestone"
                   case special = "special"
                   case daily = "daily"
                   case weekly = "weekly"
               }
               
               let type: AchievementType
           }
