import SwiftUI
import Combine

struct TimerView: View {

    @StateObject private var vm = TimerViewModel()
    @State private var waveOffset: Double = 0.0

    var body: some View {
        VStack(spacing: 36) {

            VStack(spacing: 4) {
                Text("MindTimer")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.purple)
                Text(vm.isBreakMode ? "Tiempo de descanso" : "Tiempo de enfoque")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.15), lineWidth: 10)

                WaveShape(offset: waveOffset, percent: calculateProgress())
                    .fill(Color.purple.opacity(0.45))
                    .clipShape(Circle())

                VStack(spacing: 6) {
                    Text(vm.formatTime())
                        .font(.system(size: 68, weight: .bold, design: .rounded))
                        .foregroundStyle(.purple)

                    Text(vm.isRunning ? "En curso..." : "Listo")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 270, height: 270)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    waveOffset = .pi * 2
                }
            }

            HStack(spacing: 52) {
                Button(action: vm.resetTimer) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundStyle(.purple)
                }

                Button(action: vm.toggleTimer) {
                    Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
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

    private func calculateProgress() -> Double {
        let total = vm.isBreakMode ? Double(vm.breakTime) : Double(vm.focusTime)
        return 1.0 - (Double(vm.timeRemaining) / total)
    }
}

#Preview {
    TimerView()
}
