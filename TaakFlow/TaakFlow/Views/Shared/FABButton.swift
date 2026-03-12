// FABButton.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct FABButton: View {
    let action: () -> Void
    @State private var isFloating = false

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(LinearGradient.tfHero)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .fabGlowShadow()
        }
        .buttonStyle(SpringButtonStyle())
        .offset(y: isFloating ? -3 : 0)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
            ) {
                isFloating = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.tfBgPrimary
        VStack {
            Spacer()
            HStack {
                Spacer()
                FABButton {}
                    .padding()
            }
        }
    }
}
