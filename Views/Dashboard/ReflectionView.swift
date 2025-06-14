import SwiftUI

struct ReflectionView: View {
    @Binding var reflectionText: String
    @Environment(\.dismiss) private var dismiss
    @State private var tempText: String = ""
    
    init(reflectionText: Binding<String>) {
        self._reflectionText = reflectionText
        self._tempText = State(initialValue: reflectionText.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Reflexión diaria")
                    .font(.largeTitle.bold())
                
                Text("¿Cómo te fue hoy? ¿Qué aprendiste?")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $tempText)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .frame(minHeight: 200)
                
                Button(action: saveReflection) {
                    Text("Guardar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarItems(trailing: Button("Cerrar") { dismiss() })
        }
    }
    
    private func saveReflection() {
        reflectionText = tempText
        dismiss()
    }
}
