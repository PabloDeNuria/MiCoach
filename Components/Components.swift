// Components.swift

import SwiftUI  // ASEGÚRATE que diga 'import' y no 'Imageimport'

// Ejemplo de estructura correcta de un componente
struct YourComponent: View {
    var body: some View {
        HStack {  // ASEGÚRATE que HStack esté correctamente construido
            // Contenido aquí
        }
    }
}

// Si estás usando HStack con parámetros, asegúrate que la sintaxis sea correcta:
struct AnotherComponent: View {
    var body: some View {
        HStack(spacing: 10) {  // Sintaxis correcta para HStack con parámetros
            // Contenido
        }
    }
}

// No hagas esto:
// HStack<>() - Esto está mal, no necesitas especificar el tipo genérico
// HStack<Content>() - Tampoco hagas esto

// Haz esto:
struct CorrectComponent: View {
    var body: some View {
        HStack {
            // Tu contenido
        }
    }
}

// Asegúrate de cerrar todas las llaves correctamente
struct ExampleComponent: View {
    var body: some View {
        VStack {
            Text("Ejemplo")
        }
    } // ← Asegúrate de tener esta llave de cierre
} // ← Y esta

// Preview
struct YourComponent_Previews: PreviewProvider {
    static var previews: some View {
        YourComponent()
    }
}
