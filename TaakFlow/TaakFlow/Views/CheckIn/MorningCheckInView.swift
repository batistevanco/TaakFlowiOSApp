// MorningCheckInView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct MorningCheckInView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("longestStreak") private var longestStreak = 0
    @AppStorage("lastStreakDate") private var lastStreakDate = ""

    @State private var viewModel = CheckInViewModel()
    @State private var showConfetti = false

    private var totalSteps: Int { viewModel.totalSteps }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#EEF0FF"), Color(hex: "#F5F0FF")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: TFSpacing.xl) {
                // Header
                HStack {
                    CheckInStepIndicator(
                        currentStep: viewModel.currentStep,
                        totalSteps: totalSteps
                    )
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("Overslaan")
                            .font(.tfCaption())
                            .foregroundColor(.tfTextSecondary)
                    }
                }
                .padding(.horizontal, TFSpacing.xl)
                .padding(.top, TFSpacing.xl)

                // Step content
                Group {
                    switch viewModel.currentStep {
                    case 0:
                        CheckInMoodStep(viewModel: viewModel)
                            .transition(.springSlideFromRight)
                    case 1:
                        CheckInGoalStep(viewModel: viewModel)
                            .transition(.springSlideFromRight)
                    default:
                        CheckInTasksStep(viewModel: viewModel)
                            .transition(.springSlideFromRight)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.currentStep)

                Spacer()

                // Next button
                let isLastStep = viewModel.currentStep == totalSteps - 1
                Button(action: {
                    if isLastStep {
                        completeCheckIn()
                    } else {
                        viewModel.goNext()
                    }
                }) {
                    HStack(spacing: TFSpacing.sm) {
                        Text(isLastStep ? "Start mijn dag 🚀" : "Volgende")
                            .font(.tfHeadline())
                        if !isLastStep {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(TFSpacing.lg)
                    .background(
                        viewModel.canGoNext
                        ? AnyView(LinearGradient.tfButton)
                        : AnyView(Color.tfBorderMedium)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                    .buttonGlowShadow(color: .tfAccent)
                    .opacity(viewModel.canGoNext ? 1.0 : 0.4)
                }
                .buttonStyle(SpringButtonStyle())
                .disabled(!viewModel.canGoNext)
                .padding(.horizontal, TFSpacing.xl)
                .padding(.bottom, TFSpacing.xxxl)
            }

            // Confetti
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .interactiveDismissDisabled()
        .dismissKeyboardOnInteraction()
    }

    // MARK: - Complete

    private func completeCheckIn() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        viewModel.saveCheckIn(context: context)

        // Update streak
        let today = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            return f.string(from: Date())
        }()
        if lastStreakDate != today {
            let yesterday = {
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                let d = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                return f.string(from: d)
            }()
            if lastStreakDate == yesterday {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            if currentStreak > longestStreak { longestStreak = currentStreak }
            lastStreakDate = today
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showConfetti = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            dismiss()
        }
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        Canvas { context, size in
            for p in particles {
                let rect = CGRect(x: p.x - 5, y: p.y - 5, width: 10, height: 10)
                context.fill(Circle().path(in: rect), with: .color(p.color.opacity(p.opacity)))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            particles = (0..<15).map { _ in
                ConfettiParticle(
                    x: UIScreen.main.bounds.width / 2,
                    y: UIScreen.main.bounds.height / 2,
                    color: [Color.tfAccent, .tfAccent2, .tfPriorityLow, .tfPriorityMed, .tagPink, .tagYellow].randomElement()!
                )
            }
            withAnimation(.easeOut(duration: 1.5)) {
                for i in particles.indices {
                    particles[i].x += CGFloat.random(in: -180...180)
                    particles[i].y += CGFloat.random(in: -250...50)
                    particles[i].opacity = 0
                }
            }
        }
    }
}

struct ConfettiParticle {
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var opacity: Double = 1.0
}
