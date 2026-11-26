import SwiftUI

// ============================================================
// PASO 2: LA FORMA DE OLA PERSONALIZADA
// ============================================================
// Shape es un protocolo de SwiftUI para dibujar formas a mano.
// Cualquier struct que implemente Shape solo necesita un método:
//   func path(in rect: CGRect) -> Path
//
// CGRect es el rectángulo disponible para dibujar.
// Path es la "ruta" de líneas y curvas que forman la figura.
// ============================================================

struct WaveShape: Shape {

    var offset: Double   // Desplazamiento horizontal de la ola (para animarla)
    var percent: Double  // Nivel de llenado: 0.0 = vacío, 1.0 = lleno

    // TODO 4 ─────────────────────────────────────────────────
    // Implementa animatableData.
    //
    // ¿Por qué? SwiftUI necesita saber QUÉ valor interpolar
    // cuando anima entre dos estados del Shape.
    // animatableData es ese "puente" entre SwiftUI y tu struct.
    //
    //   var animatableData: Double {
    //       get { offset }
    //       set { offset = newValue }
    //   }
    // ─────────────────────────────────────────────────────────


    // path(in:) es donde dibujamos la ola punto por punto.
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // La altura base depende del porcentaje de llenado.
        // percent=0 → baseHeight=rect.height (fondo)
        // percent=1 → baseHeight=0 (arriba del todo)
        let baseHeight = (1.0 - percent) * rect.height

        // Empezamos desde el borde izquierdo
        path.move(to: CGPoint(x: 0, y: baseHeight))

        // Recorremos el ancho píxel a píxel
        for x in stride(from: 0.0, through: Double(rect.width), by: 1.0) {
            let relativeX = x / Double(rect.width)  // Normalizado: 0.0 → 1.0

            // TODO 5 ─────────────────────────────────────────
            // Calcula la coordenada Y usando la función seno.
            //
            // Fórmula completa:
            //   let seno = sin(relativeX * 2 * .pi + offset)
            //   let y = baseHeight + (seno * 12)
            //
            // ¿Por qué seno? Produce valores entre -1 y +1,
            // que al multiplicar por 12 da una cresta de ±12px.
            // El parámetro `offset` desplaza la ola hacia la
            // derecha → al animar offset de 0 a 2π la ola
            // "camina" en un loop perfecto.
            // ─────────────────────────────────────────────────
            let y = baseHeight   // ← Reemplaza esto con la fórmula

            path.addLine(to: CGPoint(x: x, y: y))
        }

        // Cerramos la forma hacia las esquinas inferiores
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}
