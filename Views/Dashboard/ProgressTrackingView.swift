// ProgressTrackingView.swift

import SwiftUI
import Charts

struct ProgressTrackingView: View {
    @ObservedObject var profileData: CoachingService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Progreso general
                    if let progress = profileData.getProgress() {
                        progressOverviewCard(progress: progress)
                    }
                    
                    // Hitos
                    milestonesSection
                    
                    // Gráfico de progreso
                    progressChart
                    
                    // Estadísticas
                    statsSection
                }
                .padding()
            }
            .navigationTitle("Progreso")
        }
    }
    
    private func progressOverviewCard(progress: (currentDay: Int, totalDays: Int, streak: Int, completionPercentage: Double, nextMilestone: Milestone?)) -> some View {
        VStack(spacing: 12) {
            Text("Tu Progreso")
                .font(.headline)
            
            // Barra de progreso
            ProgressView(value: progress.completionPercentage, total: 100)
                .tint(Color.blue)
                .scaleEffect(x: 1, y: 2)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Día \(progress.currentDay) de \(progress.totalDays)")
                        .font(.subheadline)
                    Text("\(Int(progress.completionPercentage))% Completado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Racha: \(progress.streak) días")
                        .font(.subheadline)
                    Label("En racha", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hitos")
                .font(.headline)
            
            if let plan = profileData.currentPlan,
               let progress = profileData.progress {
                ForEach(plan.milestones.prefix(4)) { milestone in
                    milestoneCard(milestone: milestone, currentDay: progress.currentDay)
                }
            } else {
                Text("No hay hitos disponibles")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func milestoneCard(milestone: Milestone, currentDay: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(milestoneCompleted(milestone: milestone, currentDay: currentDay) ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: milestoneCompleted(milestone: milestone, currentDay: currentDay) ? "checkmark" : "circle")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                )
            
            VStack(alignment: .leading) {
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(milestone.targetDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func milestoneCompleted(milestone: Milestone, currentDay: Int) -> Bool {
        // Obtener la fecha actual
        let today = Date()
        
        // Comparar si el objetivo del hito es o era antes de hoy
        let targetDate = milestone.targetDate
        return targetDate <= today
    }
    
    private var progressChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progreso Semanal")
                .font(.headline)
            
            Chart {
                ForEach(weeklyData, id: \.day) { data in
                    BarMark(
                        x: .value("Día", data.day),
                        y: .value("Completado", data.completed)
                    )
                    .foregroundStyle(data.completed > 0 ? Color.green : Color.gray.opacity(0.3))
                }
            }
            .frame(height: 150)
            .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var weeklyData: [(day: String, completed: Int)] {
        let weekDays = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
        return weekDays.map { day in
            (day: day, completed: Int.random(in: 0...5))
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 16) {
            statCard(title: "Tareas Completadas", value: "\(profileData.progress?.completedTasks.count ?? 0)", icon: "checkmark.circle.fill", color: .green)
            statCard(title: "Tiempo Total", value: "42h 30m", icon: "clock.fill", color: .blue)
            statCard(title: "Mejor Racha", value: "\(profileData.progress?.streak ?? 0) días", icon: "flame.fill", color: .orange)
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ProgressTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressTrackingView(profileData: CoachingService())
    }
}
