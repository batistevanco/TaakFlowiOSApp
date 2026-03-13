// OnboardingView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userName") private var userName = ""
    @AppStorage("checkinTime") private var checkinTimeStr = "08:00"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    @State private var currentPage = 0
    @State private var localName = ""

    private let checkinTimes = ["07:30", "08:00", "08:30", "09:00"]

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: onboardingBackgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    page1.tag(0)
                    page2.tag(1)
                    page3.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Dots + buttons
                VStack(spacing: TFSpacing.xl) {
                    // Page dots
                    HStack(spacing: TFSpacing.sm) {
                        ForEach(0..<3, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? Color.tfAccent : Color.tfBorderMedium)
                                .frame(width: i == currentPage ? 24 : 8, height: 4)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                        }
                    }

                    if currentPage < 2 {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                currentPage += 1
                            }
                        }) {
                            Text("Volgende")
                                .font(.tfHeadline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(TFSpacing.lg)
                                .background(LinearGradient.tfButton)
                                .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                                .buttonGlowShadow(color: .tfAccent)
                        }
                        .buttonStyle(SpringButtonStyle())
                        .padding(.horizontal, TFSpacing.xl)
                    } else {
                        Button(action: complete) {
                            Text("Begin →")
                                .font(.tfHeadline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(TFSpacing.lg)
                                .background(LinearGradient.tfButton)
                                .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                                .buttonGlowShadow(color: .tfAccent)
                        }
                        .buttonStyle(SpringButtonStyle())
                        .padding(.horizontal, TFSpacing.xl)
                    }
                }
                .padding(.bottom, TFSpacing.xxxl + TFSpacing.lg)
            }
        }
        .dismissKeyboardOnInteraction()
    }

    // MARK: - Pages

    private var page1: some View {
        VStack(spacing: TFSpacing.xxl) {
            Spacer()

            // App icon placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient.tfHero)
                    .frame(width: 120, height: 120)
                    .heroGlowShadow()
                Image(systemName: "checkmark.square.fill")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: TFSpacing.md) {
                Text("Welkom bij TaakFlow")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
                    .multilineTextAlignment(.center)

                Text("Jouw taken. Jouw flow.")
                    .font(.tfTitle2())
                    .foregroundColor(.tfTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, TFSpacing.xl)

            Spacer()
        }
    }

    private var page2: some View {
        VStack(spacing: TFSpacing.xl) {
            Spacer()

            Text("Alles wat je nodig hebt")
                .font(.tfTitle2())
                .foregroundColor(.tfTextPrimary)
                .tracking(-0.5)
                .padding(.horizontal, TFSpacing.xl)

            VStack(spacing: TFSpacing.md) {
                featureRow(icon: "☀️", title: "Ochtend Check-in", subtitle: "Plan je dag elke ochtend in 2 minuten")
                featureRow(icon: "🎯", title: "Focus Mode", subtitle: "Werk geconcentreerd met een Pomodoro timer")
                featureRow(icon: "📊", title: "Inzichten", subtitle: "Zie je productiviteit groeien week na week")
            }
            .padding(.horizontal, TFSpacing.xl)

            Spacer()
        }
    }

    private var page3: some View {
        VStack(spacing: TFSpacing.xl) {
            Spacer()

            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text("Snel instellen")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
                Text("Je kunt dit later altijd wijzigen")
                    .font(.tfSubheadline())
                    .foregroundColor(.tfTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, TFSpacing.xl)

            VStack(spacing: TFSpacing.md) {
                // Name
                VStack(alignment: .leading, spacing: TFSpacing.sm) {
                    Text("HOE MOGEN WE JE NOEMEN?")
                        .font(.tfCaption())
                        .tracking(0.8)
                        .foregroundColor(.tfTextSecondary)
                    TextField("Je naam", text: $localName)
                        .font(.tfSubheadline())
                        .foregroundColor(.tfTextPrimary)
                        .padding(TFSpacing.md)
                        .background(Color.tfBgCard)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                        .overlay(inputBorder)
                        .cardShadow()
                }

                // Check-in time
                VStack(alignment: .leading, spacing: TFSpacing.sm) {
                    Text("HOE LAAT WIL JE JE CHECK-IN?")
                        .font(.tfCaption())
                        .tracking(0.8)
                        .foregroundColor(.tfTextSecondary)
                    HStack(spacing: TFSpacing.sm) {
                        ForEach(checkinTimes, id: \.self) { time in
                            Button(action: { checkinTimeStr = time }) {
                                Text(time)
                                    .font(.tfCaption())
                                    .foregroundColor(checkinTimeStr == time ? .white : .tfTextPrimary)
                                    .padding(.horizontal, TFSpacing.md)
                                    .padding(.vertical, TFSpacing.sm)
                                    .background(checkinTimeStr == time ? Color.tfAccent : Color.tfBgCard)
                                    .clipShape(Capsule())
                                    .overlay {
                                        if checkinTimeStr != time {
                                            Capsule()
                                                .strokeBorder(Color.tfBorderLight, lineWidth: 1)
                                        }
                                    }
                                    .shadow(color: checkinTimeStr == time ? Color.tfAccent.opacity(0.3) : .black.opacity(0.04),
                                            radius: 6)
                            }
                            .buttonStyle(SpringButtonStyle())
                        }
                    }
                }

                // Notifications
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Meldingen inschakelen?")
                            .font(.tfSubheadline())
                            .foregroundColor(.tfTextPrimary)
                        Text("Reminders voor taken & check-in")
                            .font(.tfCaption2())
                            .foregroundColor(.tfTextSecondary)
                    }
                    Spacer()
                    CustomToggle(isOn: $notificationsEnabled)
                }
                .padding(TFSpacing.md)
                .background(Color.tfBgCard)
                .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                .overlay(inputBorder)
                .cardShadow()
            }
            .padding(.horizontal, TFSpacing.xl)

            Spacer()
        }
    }

    // MARK: - Feature Row

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: TFSpacing.lg) {
            Text(icon)
                .font(.system(size: 28))
                .frame(width: 52, height: 52)
                .background(Color.tfAccent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text(title)
                    .font(.tfHeadline())
                    .foregroundColor(.tfTextPrimary)
                Text(subtitle)
                    .font(.tfBody())
                    .foregroundColor(.tfTextSecondary)
            }
            Spacer()
        }
        .padding(TFSpacing.md)
        .background(Color.tfBgCard)
        .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: TFRadius.card)
                .strokeBorder(Color.tfBorderLight, lineWidth: 1)
        )
        .cardShadow()
    }

    private var onboardingBackgroundColors: [Color] {
        if colorScheme == .dark {
            return [Color(hex: "#0F172A"), Color(hex: "#141B34"), Color(hex: "#111827")]
        }
        return [Color(hex: "#EEF0FF"), Color(hex: "#F5F0FF"), Color(hex: "#EEF5FF")]
    }

    private var inputBorder: some View {
        RoundedRectangle(cornerRadius: TFRadius.input)
            .strokeBorder(Color.tfBorderLight, lineWidth: 1)
    }

    // MARK: - Complete

    private func complete() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if !localName.isEmpty { userName = localName }
        if notificationsEnabled {
            Task { await NotificationService.shared.requestPermission() }
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
}
