// FocusModeView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct FocusModeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var task: TFTask

    @AppStorage("shortBreakMinutes")  private var shortBreakMinutes  = 5
    @AppStorage("longBreakMinutes")   private var longBreakMinutes   = 15

    @State private var timer: PomodoroTimer
    @State private var showDoneMessage = false
    @State private var pulseRing = false

    init(task: TFTask) {
        self.task = task
        let shortBreak = UserDefaults.standard.integer(forKey: "shortBreakMinutes")
        let longBreak = UserDefaults.standard.integer(forKey: "longBreakMinutes")
        let workMinutes = task.estimatedMinutes ?? 25
        _timer = State(initialValue: PomodoroTimer(
            workMinutes: workMinutes > 0 ? workMinutes : 25,
            shortBreakMinutes: shortBreak > 0 ? shortBreak : 5,
            longBreakMinutes: longBreak > 0 ? longBreak : 15
        ))
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: TFSpacing.xl) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        timer.stop()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, TFSpacing.xl)
                .padding(.top, TFSpacing.lg)

                Spacer()

                // Focus chip
                Text("\(timer.phase.emoji) \(timer.phase.label.uppercased())")
                    .font(.tfCaption())
                    .tracking(1.0)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, TFSpacing.md)
                    .padding(.vertical, TFSpacing.xs)
                    .background(Color.white.opacity(0.10))
                    .clipShape(Capsule())

                // Task title
                Text(task.title)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(-0.5)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TFSpacing.xxl)

                // Priority + time
                HStack(spacing: TFSpacing.md) {
                    if task.priority != .none {
                        HStack(spacing: TFSpacing.xs) {
                            Circle()
                                .fill(task.priority.color)
                                .frame(width: 6, height: 6)
                            Text(task.priority.label)
                                .font(.tfCaption2())
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    if let dueTime = task.dueTime {
                        Text("🕐 \(dueTime.timeString)")
                            .font(.tfCaption2())
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                // Timer display with pulsing ring
                ZStack {
                    // Pulse ring
                    Circle()
                        .stroke(Color.tfAccent.opacity(0.20), lineWidth: 2)
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseRing ? 1.08 : 1.0)
                        .animation(
                            timer.isRunning
                            ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
                            : .default,
                            value: pulseRing
                        )

                    // Progress arc
                    Circle()
                        .trim(from: 0, to: timer.progress)
                        .stroke(
                            LinearGradient.tfHero,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timer.progress)

                    // Time text
                    VStack(spacing: TFSpacing.xs) {
                        Text(timer.timeString)
                            .font(.system(size: 56, weight: .heavy, design: .monospaced))
                            .foregroundColor(.white)
                            .tracking(-2)

                        Text("Pomodoro Timer")
                            .font(.tfCaption2())
                            .tracking(1.0)
                            .foregroundColor(.white.opacity(0.4))
                            .textCase(.uppercase)
                    }
                }

                // Session dots
                HStack(spacing: TFSpacing.sm) {
                    ForEach(Array(timer.sessionDots.enumerated()), id: \.offset) { _, done in
                        Circle()
                            .fill(done ? Color.tfAccent : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: timer.completedSessions)

                // Controls
                HStack(spacing: TFSpacing.xl) {
                    Button(action: timerToggle) {
                        HStack(spacing: TFSpacing.sm) {
                            Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text(timer.isRunning ? "Pauze" : "Start")
                                .font(.tfHeadline())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, TFSpacing.xl)
                        .padding(.vertical, TFSpacing.md)
                        .background(LinearGradient.tfHero)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                        .heroGlowShadow()
                    }
                    .buttonStyle(SpringButtonStyle())

                    Button(action: { timer.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 48, height: 48)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Circle())
                    }
                    .buttonStyle(SpringButtonStyle())
                }

                Spacer()

                // Mark done button
                if showDoneMessage {
                    VStack(spacing: TFSpacing.sm) {
                        Text("Goed gedaan! 🎉")
                            .font(.tfTitle2())
                            .foregroundColor(.tfPriorityLow)
                        Text("Taak afgevinkt!")
                            .font(.tfBody())
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Button(action: markTaskDone) {
                        HStack(spacing: TFSpacing.sm) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                            Text("Taak afvinken")
                                .font(.tfHeadline())
                        }
                        .foregroundColor(.tfPriorityLow)
                        .frame(maxWidth: .infinity)
                        .padding(TFSpacing.lg)
                        .background(Color.tfPriorityLow.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                        .overlay(
                            RoundedRectangle(cornerRadius: TFRadius.card)
                                .strokeBorder(Color.tfPriorityLow.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(SpringButtonStyle())
                    .padding(.horizontal, TFSpacing.xl)
                    .padding(.bottom, TFSpacing.xxxl)
                    .disabled(task.isDone)
                    .opacity(task.isDone ? 0.4 : 1.0)
                }

                Spacer(minLength: TFSpacing.xxl)
            }
        }
        .onAppear {
            withAnimation { pulseRing = true }
        }
        .onDisappear {
            timer.stop()
        }
    }

    // MARK: - Actions

    private func timerToggle() {
        if timer.isRunning {
            timer.pause()
            withAnimation { pulseRing = false }
        } else {
            timer.start()
            withAnimation { pulseRing = true }
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func markTaskDone() {
        guard !task.isDone else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            task.isDone = true
            task.completedAt = Date()
            task.actualMinutes = timer.elapsedSeconds / 60
            showDoneMessage = true
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
