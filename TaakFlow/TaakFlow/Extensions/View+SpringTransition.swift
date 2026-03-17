// View+SpringTransition.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import UIKit

// MARK: - Custom Transitions

extension AnyTransition {
    static var springSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.97)),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }

    static var springFade: AnyTransition {
        .opacity.animation(.spring(response: 0.3, dampingFraction: 0.8))
    }

    static var springSlideFromRight: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

// MARK: - View Modifiers

extension View {
    func cardEntrance(delay: Double = 0) -> some View {
        self
            .transition(
                .asymmetric(
                    insertion: .move(edge: .bottom)
                        .combined(with: .opacity)
                        .combined(with: .scale(scale: 0.97)),
                    removal: .move(edge: .leading).combined(with: .opacity)
                )
            )
            .animation(
                .spring(response: 0.4, dampingFraction: 0.7).delay(delay),
                value: UUID()
            )
    }

    func springButton(isPressed: Bool) -> some View {
        self.scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }

    func hapticOnTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                UIImpactFeedbackGenerator(style: style).impactOccurred()
            }
        )
    }

    func dismissKeyboardOnInteraction() -> some View {
        self
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.hideKeyboard()
                }
            )
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
