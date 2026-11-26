import SwiftUI
import Combine

// ============================================================
// PASO 1: EL VIEW MODEL
// ============================================================
// MVVM = Model - View - ViewModel
// El ViewModel es responsable de TODA la lógica del timer.
// La Vista solo muestra lo que el ViewModel le dice.
//
// ObservableObject: protocolo que permite que SwiftUI
// "escuche" los cambios de esta clase.
// ============================================================

class TimerViewModel: ObservableObject {

    // TODO 1 ─────────────────────────────────────────────────
    // Agrega @Published antes de cada propiedad.
    //
    // ¿Por qué? @Published notifica a SwiftUI cuando el valor
    // cambia, lo que hace que la vista se redibuje
    // automáticamente. Sin él, los cambios son invisibles.
    // ─────────────────────────────────────────────────────────
    var timeRemaining: Int = 25 * 60   // 1500 segundos = 25 min
    var isRunning: Bool = false
    var isBreakMode: Bool = false
    var sessionsCompleted: Int = 0

    // Constantes de tiempo (estas ya están listas)
    let focusTime: Int = 25 * 60
    let breakTime: Int = 5 * 60

    // AnyCancellable guarda la referencia al timer activo.
    // Cuando se destruye, el timer se cancela automáticamente.
    private var timer: AnyCancellable?

    // TODO 2 ─────────────────────────────────────────────────
    // Completa el método toggleTimer().
    //
    // Lógica:
    //   • Si isRunning == true → cancela el timer con timer?.cancel()
    //   • Si isRunning == false → crea un nuevo timer así:
    //
    //       timer = Timer.publish(every: 1, on: .main, in: .common)
    //           .autoconnect()
    //           .sink { [weak self] _ in
    //               guard let self = self else { return }
    //               if self.timeRemaining > 0 {
    //                   self.timeRemaining -= 1
    //               } else {
    //                   self.handleTimerCompletion()
    //               }
    //           }
    //
    //   • Al final, cambia isRunning con: isRunning.toggle()
    // ─────────────────────────────────────────────────────────
    func toggleTimer() {
        // Tu código aquí ↓


        isRunning.toggle()
    }

    func resetTimer() {
        timer?.cancel()
        isRunning = false
        timeRemaining = isBreakMode ? breakTime : focusTime
    }

    private func handleTimerCompletion() {
        timer?.cancel()
        isRunning = false

        if !isBreakMode {
            sessionsCompleted += 1
            isBreakMode = true
            timeRemaining = breakTime
        } else {
            isBreakMode = false
            timeRemaining = focusTime
        }
    }

    // TODO 3 ─────────────────────────────────────────────────
    // Implementa formatTime() para mostrar "MM:SS".
    //
    // Pistas:
    //   • minutos = timeRemaining / 60
    //   • segundos = timeRemaining % 60
    //   • Usa String(format: "%02d:%02d", minutos, segundos)
    //     El %02d asegura que siempre hay 2 dígitos (ej: "05:03")
    // ─────────────────────────────────────────────────────────
    func formatTime() -> String {
        return "00:00"   // ← Reemplaza esto
    }
}
