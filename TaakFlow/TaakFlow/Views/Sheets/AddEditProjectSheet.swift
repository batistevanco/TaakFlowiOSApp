// AddEditProjectSheet.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct AddEditProjectSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var existingProject: TFProject?

    @State private var name: String = ""
    @State private var emoji: String = "📁"
    @State private var selectedColorHex: String = "#5B6EF5"
    @State private var notes: String = ""
    @State private var hasDeadline: Bool = false
    @State private var deadline: Date = Date()

    private var isEditing: Bool { existingProject != nil }
    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TFSpacing.xl) {
                    // Handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.tfBorderMedium)
                        .frame(width: 36, height: 4)
                        .frame(maxWidth: .infinity)
                        .padding(.top, TFSpacing.md)

                    // Title
                    Text(isEditing ? "Project bewerken" : "Nieuw Project")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.tfTextPrimary)
                        .padding(.horizontal, TFSpacing.lg)

                    // MARK: Preview card
                    HStack(spacing: TFSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: TFRadius.projectIcon)
                                .fill(Color(hex: selectedColorHex).opacity(0.15))
                                .frame(width: 56, height: 56)
                            Text(emoji)
                                .font(.system(size: 28))
                        }
                        VStack(alignment: .leading, spacing: TFSpacing.xs) {
                            Text(name.isEmpty ? "Projectnaam" : name)
                                .font(.tfHeadline())
                                .foregroundColor(name.isEmpty ? .tfTextSecondary : .tfTextPrimary)
                            Text("Nieuw project")
                                .font(.tfCaption2())
                                .foregroundColor(.tfTextSecondary)
                        }
                    }
                    .padding(TFSpacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.tfBgSubtle)
                    .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                    .padding(.horizontal, TFSpacing.lg)

                    // MARK: Name
                    sectionLabel("Naam")
                    TextField("Projectnaam", text: $name)
                        .font(.tfSubheadline())
                        .padding(TFSpacing.md)
                        .background(Color.tfBgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                        .padding(.horizontal, TFSpacing.lg)

                    // MARK: Emoji
                    sectionLabel("Emoji")
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: TFSpacing.sm) {
                        ForEach(kProjectEmojis, id: \.self) { e in
                            Button(action: { emoji = e }) {
                                Text(e)
                                    .font(.system(size: 22))
                                    .frame(width: 40, height: 40)
                                    .background(emoji == e ? Color.tfAccent.opacity(0.15) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(emoji == e ? Color.tfAccent : Color.clear, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(SpringButtonStyle())
                        }
                    }
                    .padding(.horizontal, TFSpacing.lg)

                    // MARK: Color
                    sectionLabel("Kleur")
                    HStack(spacing: TFSpacing.md) {
                        ForEach(Color.tfTagHexColors, id: \.self) { hex in
                            Button(action: { selectedColorHex = hex }) {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.white, lineWidth: 2)
                                            .opacity(selectedColorHex == hex ? 1 : 0)
                                    )
                                    .shadow(color: Color(hex: hex).opacity(0.4), radius: 4)
                                    .scaleEffect(selectedColorHex == hex ? 1.15 : 1.0)
                            }
                            .buttonStyle(SpringButtonStyle())
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedColorHex)
                        }
                    }
                    .padding(.horizontal, TFSpacing.lg)

                    // MARK: Deadline
                    sectionLabel("Deadline")
                    VStack(spacing: TFSpacing.sm) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.tfAccent)
                            Text(hasDeadline ? deadline.fullDateString : "Geen deadline")
                                .font(.tfSubheadline())
                                .foregroundColor(hasDeadline ? .tfTextPrimary : .tfTextSecondary)
                            Spacer()
                            CustomToggle(isOn: $hasDeadline)
                        }
                        .padding(TFSpacing.md)
                        .background(Color.tfBgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                        .padding(.horizontal, TFSpacing.lg)

                        if hasDeadline {
                            DatePicker("", selection: $deadline, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(.tfAccent)
                                .padding(.horizontal, TFSpacing.lg)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }

                    // MARK: Notes
                    sectionLabel("Notities")
                    TextField("Optionele notities...", text: $notes, axis: .vertical)
                        .font(.tfBody())
                        .lineLimit(3...6)
                        .padding(TFSpacing.md)
                        .background(Color.tfBgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                        .padding(.horizontal, TFSpacing.lg)

                    // MARK: Submit
                    Button(action: saveProject) {
                        Text(isEditing ? "Opslaan" : "Project aanmaken")
                            .font(.tfHeadline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(TFSpacing.lg)
                            .background(
                                isValid
                                ? AnyView(LinearGradient.tfButton)
                                : AnyView(Color.tfBorderMedium)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                            .opacity(isValid ? 1.0 : 0.5)
                    }
                    .buttonStyle(SpringButtonStyle())
                    .disabled(!isValid)
                    .padding(.horizontal, TFSpacing.lg)
                    .padding(.bottom, TFSpacing.xxxl)
                }
            }
            .background(Color.tfBgCard)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .dismissKeyboardOnInteraction()
        }
        .onAppear(perform: populateIfEditing)
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.tfCaption())
            .tracking(0.8)
            .foregroundColor(.tfTextSecondary)
            .padding(.horizontal, TFSpacing.lg)
    }

    private func populateIfEditing() {
        guard let project = existingProject else { return }
        name = project.name
        emoji = project.emoji
        selectedColorHex = project.colorHex
        notes = project.notes
        if let dl = project.deadline { hasDeadline = true; deadline = dl }
    }

    private func saveProject() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if let project = existingProject {
            project.name = name
            project.emoji = emoji
            project.colorHex = selectedColorHex
            project.notes = notes
            project.deadline = hasDeadline ? deadline : nil
        } else {
            let project = TFProject(
                name: name,
                emoji: emoji,
                colorHex: selectedColorHex,
                notes: notes,
                deadline: hasDeadline ? deadline : nil
            )
            context.insert(project)
        }
        dismiss()
    }
}
