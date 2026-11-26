import SwiftUI
import Combine

class TimerViewModel: ObservableObject {

    @Published var timeRemaining: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var isBreakMode: Bool = false
    @Published var sessionsCompleted: Int = 0

    let focusTime: Int = 25 * 60
    let breakTime: Int = 5 * 60

    private var timer: AnyCancellable?

    func toggleTimer() {
        if isRunning {
            timer?.cancel()
        } else {
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                    } else {
                        self.handleTimerCompletion()
                    }
                }
        }
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

    func formatTime() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
