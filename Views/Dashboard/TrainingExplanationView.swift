
// TrainingExplanationView.swift
// Vista que explica el fundamento del entrenamiento que está siguiendo el usuario

import SwiftUI

struct TrainingExplanationView: View {
    let trainingType: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Cabecera
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entrenamiento de \(trainingType)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Descubre por qué este entrenamiento es ideal para ti")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                // Imagen ilustrativa
                imageForTrainingType(trainingType)
                    .padding(.bottom, 10)
                
                // Sección: ¿Por qué este entrenamiento?
                sectionTitle("¿Por qué entrenamiento de \(trainingType)?")
                
                Text(whyThisTraining(trainingType))
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Sección: Beneficios
                sectionTitle("Beneficios principales")
                
                ForEach(benefitsFor(trainingType), id: \.title) { benefit in
                    benefitRow(benefit.title, description: benefit.description, icon: benefit.icon)
                }
                
                // Sección: Funcionamiento
                sectionTitle("¿Cómo funciona?")
                
                Text(howItWorks(trainingType))
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Sección: Adaptación personal
                sectionTitle("Adaptado a tu persona")
                
                Text("Tu plan de entrenamiento ha sido personalizado teniendo en cuenta tu condición física actual, objetivos y preferencias. Nuestro sistema crea una progresión adaptada específicamente para ti, con cargas e intensidades que evolucionan a medida que mejoras.")
                    .font(.body)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 8) {
                    adaptationRow("Intensidad graduada según tu nivel")
                    adaptationRow("Progresión basada en tu rendimiento")
                    adaptationRow("Descansos optimizados para tu recuperación")
                    adaptationRow("Variedad de ejercicios adaptados a tus necesidades")
                }
                .padding(.bottom, 20)
                
                // Fuentes y respaldo científico
                sectionTitle("Respaldo científico")
                
                Text("Este enfoque de entrenamiento está basado en investigación científica reciente en el campo de la fisiología del ejercicio y la medicina deportiva. Los programas se actualizan regularmente para incorporar los últimos avances en ciencia deportiva.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Volver")
            }
        })
    }
    
    // MARK: - Componentes de UI
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.vertical, 8)
    }
    
    private func benefitRow(_ title: String, description: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func adaptationRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text(text)
                .font(.subheadline)
        }
    }
    
    private func imageForTrainingType(_ type: String) -> some View {
        let imageName: String
        
        switch type.lowercased() {
        case "fuerza":
            imageName = "figure.strengthtraining.traditional"
        case "hipertrofia":
            imageName = "figure.strengthtraining.functional"
        case "resistencia":
            imageName = "figure.run"
        case "cardio":
            imageName = "heart.circle"
        case "pérdida de peso":
            imageName = "figure.walk"
        default:
            imageName = "figure.mixed.cardio"
        }
        
        return Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(height: 150)
            .foregroundColor(.blue)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
    }
    
    // MARK: - Contenido específico por tipo de entrenamiento
    
    private func whyThisTraining(_ type: String) -> String {
        switch type.lowercased() {
        case "fuerza":
            return "El entrenamiento de fuerza es fundamental para mejorar tu rendimiento físico general. Estamos siguiendo este tipo de entrenamiento porque está científicamente demostrado que acelera el metabolismo, aumenta la densidad ósea y contribuye a un mejor equilibrio hormonal. Además, estimula la producción de endorfinas que mejoran tu estado de ánimo y reducen los niveles de estrés."
            
        case "hipertrofia":
            return "El entrenamiento de hipertrofia está diseñado para incrementar el tamaño muscular. Este tipo de entrenamiento no solo mejora tu aspecto físico, sino que también aumenta tu metabolismo basal, ya que un mayor volumen muscular requiere más energía incluso en reposo. Además, contribuye a un mejor equilibrio hormonal y a la producción de endorfinas que mejoran significativamente tu bienestar general."
            
        case "resistencia":
            return "El entrenamiento de resistencia mejora la capacidad de tu cuerpo para sostener esfuerzos durante períodos prolongados. Fortalece tu sistema cardiovascular, aumenta la capacidad pulmonar y mejora la eficiencia en el uso del oxígeno. Este tipo de entrenamiento es excelente para tu salud cardiaca a largo plazo y para incrementar tus niveles de energía diarios."
            
        case "cardio":
            return "El entrenamiento cardiovascular es esencial para la salud de tu corazón y sistema circulatorio. Mejora la capacidad de tu cuerpo para transportar y utilizar oxígeno, lo que se traduce en mayor energía diaria. El cardio regular reduce el riesgo de enfermedades crónicas y tiene profundos efectos positivos en tu estado de ánimo gracias a la liberación de endorfinas durante el ejercicio."
            
        case "pérdida de peso":
            return "Este entrenamiento está específicamente diseñado para maximizar el gasto calórico y optimizar la pérdida de grasa. Combina ejercicios de alta intensidad con intervalos estratégicos para crear un efecto de post-combustión (EPOC) que continúa quemando calorías incluso después de terminar el entrenamiento. Además, incluye ejercicios de resistencia para preservar y tonificar tu masa muscular."
            
        default:
            return "Este programa de entrenamiento personalizado ha sido diseñado específicamente para ayudarte a alcanzar tus objetivos de forma eficiente y segura. Combinamos diferentes tipos de ejercicios y metodologías basadas en la ciencia del deporte más reciente para ofrecerte resultados óptimos adaptados a tu condición física actual."
        }
    }
    
    private struct Benefit {
        let title: String
        let description: String
        let icon: String
    }
    
    private func benefitsFor(_ type: String) -> [Benefit] {
        switch type.lowercased() {
        case "fuerza":
            return [
                Benefit(
                    title: "Acelera tu metabolismo",
                    description: "El entrenamiento de fuerza aumenta significativamente tu tasa metabólica basal, ayudándote a quemar más calorías incluso en reposo.",
                    icon: "flame.fill"
                ),
                Benefit(
                    title: "Mejora tu estado de ánimo",
                    description: "Estimula la producción de endorfinas y otras hormonas que reducen el estrés y mejoran la sensación de bienestar general.",
                    icon: "brain.head.profile"
                ),
                Benefit(
                    title: "Aumenta tu densidad ósea",
                    description: "Fortalece tus huesos y reduce el riesgo de osteoporosis a largo plazo.",
                    icon: "figure.stand"
                ),
                Benefit(
                    title: "Mejora tu postura y equilibrio",
                    description: "Fortalece los músculos estabilizadores que contribuyen a una mejor postura y menor riesgo de lesiones.",
                    icon: "figure.walk.motion"
                )
            ]
            
        case "hipertrofia":
            return [
                Benefit(
                    title: "Incremento de masa muscular",
                    description: "Estimula el crecimiento de las fibras musculares a través de la hipertrofia, mejorando tu composición corporal.",
                    icon: "figure.strengthtraining.traditional"
                ),
                Benefit(
                    title: "Mayor metabolismo basal",
                    description: "El aumento de masa muscular eleva tu gasto calórico en reposo, facilitando el mantenimiento de un peso saludable.",
                    icon: "flame.fill"
                ),
                Benefit(
                    title: "Mejora hormonal",
                    description: "Optimiza los niveles de testosterona, hormona de crecimiento e insulina, creando un ambiente anabólico favorable.",
                    icon: "waveform.path.ecg"
                ),
                Benefit(
                    title: "Mayor fuerza funcional",
                    description: "No solo mejora tu aspecto físico, sino también tu capacidad para realizar actividades cotidianas.",
                    icon: "figure.mixed.cardio"
                )
            ]
            
        case "resistencia":
            return [
                Benefit(
                    title: "Eficiencia cardiovascular",
                    description: "Mejora la capacidad de tu corazón para bombear sangre y distribuir oxígeno por todo el cuerpo.",
                    icon: "heart.fill"
                ),
                Benefit(
                    title: "Mayor capacidad pulmonar",
                    description: "Optimiza la función respiratoria, permitiéndote utilizar el oxígeno de manera más eficiente.",
                    icon: "lungs.fill"
                ),
                Benefit(
                    title: "Resistencia a la fatiga",
                    description: "Aumenta tu capacidad para realizar actividades diarias sin cansarte rápidamente.",
                    icon: "battery.100.fill"
                ),
                Benefit(
                    title: "Mejor recuperación",
                    description: "Desarrolla la capacidad de tu cuerpo para recuperarse más rápidamente después del esfuerzo.",
                    icon: "arrow.clockwise"
                )
            ]
            
        case "cardio":
            return [
                Benefit(
                    title: "Salud cardiovascular",
                    description: "Reduce significativamente el riesgo de enfermedades cardíacas y mejora la salud general de tu sistema circulatorio.",
                    icon: "heart.fill"
                ),
                Benefit(
                    title: "Control de peso efectivo",
                    description: "Maximiza el gasto calórico durante el ejercicio, ayudándote a mantener un peso saludable.",
                    icon: "scalemass.fill"
                ),
                Benefit(
                    title: "Mejor estado de ánimo",
                    description: "Libera endorfinas que actúan como analgésicos naturales y mejoran la sensación de bienestar.",
                    icon: "face.smiling.fill"
                ),
                Benefit(
                    title: "Mayor energía diaria",
                    description: "Mejora la resistencia general, permitiéndote enfrentar tus actividades diarias con más vitalidad.",
                    icon: "bolt.fill"
                )
            ]
            
        case "pérdida de peso":
            return [
                Benefit(
                    title: "Máximo gasto calórico",
                    description: "Diseñado para optimizar la quema de calorías durante y después del entrenamiento.",
                    icon: "flame.fill"
                ),
                Benefit(
                    title: "Preservación muscular",
                    description: "Mantiene el tejido muscular mientras te enfocas en la pérdida de grasa, mejorando tu composición corporal.",
                    icon: "figure.arms.open"
                ),
                Benefit(
                    title: "Efecto metabólico duradero",
                    description: "Genera un efecto de post-combustión que continúa quemando calorías horas después de terminar el ejercicio.",
                    icon: "clock.arrow.circlepath"
                ),
                Benefit(
                    title: "Mejora hormonal",
                    description: "Optimiza las hormonas relacionadas con el metabolismo y la sensación de saciedad.",
                    icon: "waveform.path.ecg"
                )
            ]
            
        default:
            return [
                Benefit(
                    title: "Mejora integral",
                    description: "Optimiza todos los aspectos de tu condición física: fuerza, resistencia, flexibilidad y composición corporal.",
                    icon: "figure.mixed.cardio"
                ),
                Benefit(
                    title: "Salud a largo plazo",
                    description: "Reduce el riesgo de enfermedades crónicas y mejora tu calidad de vida general.",
                    icon: "heart.text.square.fill"
                ),
                Benefit(
                    title: "Bienestar mental",
                    description: "Potencia la liberación de hormonas y neurotransmisores que mejoran tu estado de ánimo y reducen el estrés.",
                    icon: "brain.head.profile"
                ),
                Benefit(
                    title: "Energía y vitalidad",
                    description: "Aumenta tus niveles de energía diarios y mejora tu capacidad para disfrutar de todas tus actividades.",
                    icon: "bolt.fill"
                )
            ]
        }
    }
    
    private func howItWorks(_ type: String) -> String {
        switch type.lowercased() {
        case "fuerza":
            return "Tu rutina de fuerza está diseñada siguiendo principios de sobrecarga progresiva. Comenzamos con cargas adaptadas a tu nivel actual y las incrementamos gradualmente a medida que tu cuerpo se adapta. Cada ejercicio ha sido seleccionado para trabajar grupos musculares específicos con patrones de movimiento funcionales.\n\nEl programa alterna días de entrenamiento y descanso estratégicamente para permitir una recuperación adecuada, ya que es durante este periodo cuando realmente ocurre el fortalecimiento muscular. La frecuencia, intensidad y volumen están cuidadosamente calculados para maximizar tus resultados sin sobrecargar tu sistema."
            
        case "hipertrofia":
            return "Tu rutina de hipertrofia se basa en el principio de daño muscular controlado y recuperación. Utilizamos volúmenes de entrenamiento moderados a altos, con rangos de repeticiones específicos (generalmente 8-12) que estimulan el crecimiento muscular de manera óptima.\n\nCada sesión está diseñada para generar microtraumas en las fibras musculares, que luego se reparan durante el descanso, resultando en músculos más grandes y fuertes. El programa incluye técnicas especializadas como series compuestas, drops sets y períodos de tensión prolongada para maximizar la estimulación muscular y la respuesta hipertrófica."
            
        case "resistencia":
            return "Tu entrenamiento de resistencia sigue un modelo de periodización que incrementa gradualmente la duración e intensidad de los ejercicios. Combinamos entrenamientos de resistencia continua con intervalos de alta intensidad para mejorar tanto tu resistencia aeróbica como anaeróbica.\n\nEl programa está diseñado para aumentar progresivamente tu capacidad cardiovascular, mejorar la eficiencia de tu sistema energético y optimizar tu capacidad para eliminar los productos de desecho metabólico. A medida que avanzas, tu cuerpo se adapta para utilizar el oxígeno de manera más eficiente y resistir la fatiga durante períodos más largos."
            
        case "cardio":
            return "Tu programa cardiovascular combina diferentes modalidades de ejercicio aeróbico para mejorar la salud y eficiencia de tu sistema cardiorrespiratorio. Incluimos tanto entrenamiento continuo de intensidad moderada como intervalos de alta intensidad para estimular diferentes adaptaciones fisiológicas.\n\nLa progresión está cuidadosamente planificada para aumentar gradualmente la carga cardiovascular, permitiendo que tu corazón, pulmones y sistema vascular se fortalezcan sin sobrecargarlos. A medida que avanzas, notarás mejoras en tu resistencia, recuperación y capacidad para mantener intensidades más altas durante períodos más largos."
            
        case "pérdida de peso":
            return "Tu programa de pérdida de peso utiliza un enfoque multimodal que combina entrenamientos de alta intensidad, entrenamiento por intervalos y ejercicios de resistencia. Esta combinación maximiza el gasto calórico durante el ejercicio y crea un efecto metabólico elevado post-entrenamiento.\n\nLa estructura de las sesiones está diseñada para mantener un déficit calórico efectivo mientras preservamos tu masa muscular. Alternamos días de mayor y menor intensidad para permitir una recuperación adecuada y evitar el sobreentrenamiento, lo que podría ser contraproducente para tus objetivos de pérdida de peso."
            
        default:
            return "Tu programa de entrenamiento personalizado utiliza principios científicos de periodización y sobrecarga progresiva para asegurar mejoras continuas. Combinamos diferentes tipos de estímulos físicos para crear adaptaciones óptimas en todos los sistemas de tu cuerpo.\n\nLa estructura del programa alterna ciclos de intensidad variable, permitiendo periodos estratégicos de recuperación para maximizar los resultados y minimizar el riesgo de lesiones o sobreentrenamiento. Cada fase del programa está cuidadosamente diseñada para construir sobre los logros de la fase anterior, asegurando una progresión constante hacia tus objetivos."
        }
    }
}

// MARK: - Previews
struct TrainingExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TrainingExplanationView(trainingType: "Fuerza")
        }
    }
} 
