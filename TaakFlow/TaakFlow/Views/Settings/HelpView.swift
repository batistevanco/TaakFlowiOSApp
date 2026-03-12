// HelpView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TFSpacing.xl) {

                    // Header
                    VStack(spacing: TFSpacing.sm) {
                        Text("👋")
                            .font(.system(size: 48))
                        Text("Welkom bij TaakFlow")
                            .font(.tfLargeTitle())
                            .foregroundColor(.tfTextPrimary)
                            .tracking(-1.0)
                            .multilineTextAlignment(.center)
                        Text("Alles wat je moet weten om productief aan de slag te gaan.")
                            .font(.tfSubheadline())
                            .foregroundColor(.tfTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, TFSpacing.xl)
                    }
                    .padding(.top, TFSpacing.xl)
                    .padding(.horizontal, TFSpacing.lg)

                    // Sections
                    helpSection(
                        emoji: "☀️",
                        title: "Dagelijkse view",
                        items: [
                            ("sun.max.fill", "Het Vandaag-tabblad toont al je taken voor vandaag, verdeeld over tijdsblokken."),
                            ("chart.bar.fill", "De voortgangskaart bovenaan toont hoeveel taken je al hebt afgerond vandaag."),
                            ("flame.fill", "Je dag streak groeit elke dag dat je minstens één taak afvinkt."),
                        ]
                    )

                    helpSection(
                        emoji: "⏰",
                        title: "Tijdsblokken",
                        items: [
                            ("sunrise.fill",    "Ochtend: taken gepland tussen 06:00 en 12:00."),
                            ("sun.max.fill",    "Middag: taken gepland tussen 12:00 en 17:00."),
                            ("moon.stars.fill", "Avond: taken gepland tussen 17:00 en 23:59."),
                            ("tray.fill",       "Ongepland: taken zonder tijdstip, altijd zichtbaar."),
                        ]
                    )

                    helpSection(
                        emoji: "🔴",
                        title: "Prioriteiten",
                        items: [
                            ("circle.fill", "Hoog (rood): dringende taken die vandaag af moeten."),
                            ("circle.fill", "Middel (oranje): belangrijk maar niet dringend."),
                            ("circle.fill", "Laag (groen): nice-to-have, doe ze als je tijd hebt."),
                            ("circle",      "Geen: taken zonder prioriteit."),
                        ]
                    )

                    helpSection(
                        emoji: "📁",
                        title: "Projecten & Tags",
                        items: [
                            ("folder.fill",         "Groepeer gerelateerde taken in een project. Elk project heeft een emoji en kleur."),
                            ("tag.fill",            "Tags zijn labels die je aan meerdere taken kunt hangen, over projecten heen."),
                            ("chart.pie.fill",      "Op het projectdetail zie je de voortgang en alle gekoppelde taken."),
                        ]
                    )

                    helpSection(
                        emoji: "🎯",
                        title: "Focus modus",
                        items: [
                            ("timer",               "Veeg naar links op een taak en tik op het timer-icoon om de Focus modus te starten."),
                            ("clock.fill",          "De Pomodoro timer telt af — werk geconcentreerd, daarna automatisch pauze."),
                            ("checkmark.circle.fill","Klik 'Taak voltooid' om de taak direct af te vinken vanuit de Focus modus."),
                        ]
                    )

                    helpSection(
                        emoji: "🌅",
                        title: "Ochtend check-in",
                        items: [
                            ("sun.horizon.fill",    "Elke ochtend verschijnt er een kort check-in scherm op het geconfigureerde tijdstip."),
                            ("face.smiling",        "Je stelt je stemming in, formuleert je dagdoel en kiest welke taken prioriteit krijgen."),
                            ("gearshape.fill",      "Pas het tijdstip en de stappen aan via Instellingen → Ochtend Check-in."),
                        ]
                    )

                    helpSection(
                        emoji: "📊",
                        title: "Inzichten & Statistieken",
                        items: [
                            ("chart.bar.fill",      "Het weekgrafiek toont hoeveel taken je per dag hebt afgerond."),
                            ("calendar",            "De streak-kalender kleurt de dagen in waarop je taken afvinkte."),
                            ("lightbulb.fill",      "Inzichten worden automatisch gegenereerd op basis van jouw gewoontes."),
                        ]
                    )

                    // Footer
                    Text("Versie 1.0 · Vancoillie Studio")
                        .font(.tfCaption2())
                        .foregroundColor(.tfTextSecondary)
                        .padding(.bottom, TFSpacing.xl)
                }
            }
            .background(Color.tfBgPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Klaar") { dismiss() }
                        .font(.tfSubheadline())
                        .foregroundColor(.tfAccent)
                }
            }
        }
    }

    // MARK: - Section builder

    @ViewBuilder
    private func helpSection(
        emoji: String,
        title: String,
        items: [(String, String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            // Section header
            HStack(spacing: TFSpacing.sm) {
                Text(emoji)
                    .font(.system(size: 18))
                Text(title)
                    .font(.tfHeadline())
                    .foregroundColor(.tfTextPrimary)
            }
            .padding(.horizontal, TFSpacing.lg)

            // Items card
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: TFSpacing.md) {
                        Image(systemName: item.0)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.tfAccent)
                            .frame(width: 20)
                            .padding(.top, 2)

                        Text(item.1)
                            .font(.tfSubheadline())
                            .foregroundColor(.tfTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()
                    }
                    .padding(.horizontal, TFSpacing.lg)
                    .padding(.vertical, TFSpacing.md)

                    if index < items.count - 1 {
                        Divider().padding(.leading, TFSpacing.lg)
                    }
                }
            }
            .background(Color.tfBgCard)
            .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
            .cardShadow()
            .padding(.horizontal, TFSpacing.lg)
        }
    }
}

#Preview {
    HelpView()
}
