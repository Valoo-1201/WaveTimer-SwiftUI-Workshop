import SwiftUI
import Combine

// ============================================================
// PASO 3: LA VISTA PRINCIPAL
// ============================================================
// La Vista SOLO muestra datos y envía acciones al ViewModel.
// Nunca calcula lógica de negocio por sí misma.
// ============================================================

struct TimerView: View {

    // @StateObject: SwiftUI crea y mantiene esta instancia.
    // Si usáramos @ObservedObject, se recrearía en cada redibujado.
    @StateObject private var vm = TimerViewModel()

    // @State es para estado LOCAL de la vista (solo la animación)
    @State private var waveOffset: Double = 0.0

    var body: some View {
        VStack(spacing: 36) {

            // ── ENCABEZADO ──────────────────────────────────
            VStack(spacing: 4) {
                Text("MindTimer")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.purple)
                Text(vm.isBreakMode ? "Tiempo de descanso" : "Tiempo de enfoque")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // ── CÍRCULO PRINCIPAL ────────────────────────────
            ZStack {
                // Borde decorativo
                Circle()
                    .stroke(Color.purple.opacity(0.15), lineWidth: 10)

                // TODO 6 ──────────────────────────────────────
                // Agrega el WaveShape dentro de este ZStack.
                //
                // WaveShape(offset: waveOffset, percent: calculateProgress())
                //     .fill(Color.purple.opacity(0.45))
                //     .clipShape(Circle())
                //
                // ¿Por qué clipShape(Circle())? Recorta la ola
                // para que no salga del círculo.
                // ─────────────────────────────────────────────

                // Texto del tiempo encima de la ola
                VStack(spacing: 6) {
                    // TODO 7 ──────────────────────────────────
                    // Muestra el tiempo con vm.formatTime()
                    // Reemplaza el "00:00" hardcodeado:
                    Text("00:00")
                        .font(.system(size: 68, weight: .bold, design: .rounded))
                        .foregroundStyle(.purple)

                    Text(vm.isRunning ? "En curso..." : "Listo")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 270, height: 270)
            .onAppear {
                // Animamos offset de 0 → 2π en loop sin rebote.
                // Esto mueve la ola horizontalmente sin parar.
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    waveOffset = .pi * 2
                }
            }

            // ── BOTONES DE CONTROL ───────────────────────────
            HStack(spacing: 52) {

                // Botón reset (ya está conectado)
                Button(action: vm.resetTimer) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundStyle(.purple)
                }

                // TODO 8 ──────────────────────────────────────
                // Conecta el botón de play/pause:
                //   • action: vm.toggleTimer
                //   • ícono: vm.isRunning ? "pause.fill" : "play.fill"
                // ─────────────────────────────────────────────
                Button(action: { }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 30))
                        .padding(24)
                        .background(vm.isBreakMode ? Color.green : Color.purple)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                        .shadow(
                            color: (vm.isBreakMode ? Color.green : Color.purple).opacity(0.35),
                            radius: 10, x: 0, y: 5
                        )
                }
            }

            // ── SESIONES COMPLETADAS ─────────────────────────
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Sesiones completadas: \(vm.sessionsCompleted)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
    }

    // Convierte timeRemaining a un valor de 0.0 a 1.0 para la ola
    private func calculateProgress() -> Double {
        let total = vm.isBreakMode ? Double(vm.breakTime) : Double(vm.focusTime)
        return 1.0 - (Double(vm.timeRemaining) / total)
    }
}

#Preview {
    TimerView()
}
