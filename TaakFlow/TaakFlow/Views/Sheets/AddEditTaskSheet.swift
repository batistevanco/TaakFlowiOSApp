// AddEditTaskSheet.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct AddEditTaskSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<TFProject> { !$0.isArchived }) private var projects: [TFProject]
    @Query private var allTags: [TFTag]

    var existingTask: TFTask?
    var defaultProject: TFProject? = nil

    // MARK: - State
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var showNotes: Bool = false
    @State private var priority: TFPriority = .none
    @State private var timeBlock: TFTimeBlock = .unscheduled
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var hasDueTime: Bool = false
    @State private var dueTime: Date = Date.today(hour: 9)
    @State private var hasReminder: Bool = false
    @State private var selectedProject: TFProject? = nil
    @State private var selectedTags: [TFTag] = []
    @State private var subtasks: [TFSubtask] = []
    @State private var estimatedMinutes: Int? = nil
    @State private var showDatePicker: Bool = false
    @State private var newTagName: String = ""
    @State private var showNewTagInput: Bool = false
    @State private var newSubtaskTitle: String = ""
    @State private var showMoreOptions: Bool = false

    private var isEditing: Bool { existingTask != nil }
    private var isValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    // MARK: - Init
    init(existingTask: TFTask?, defaultProject: TFProject? = nil) {
        self.existingTask = existingTask
        self.defaultProject = defaultProject
        _hasDueDate = State(initialValue: existingTask?.dueDate != nil || existingTask == nil)
        _dueDate = State(initialValue: existingTask?.dueDate ?? Calendar.current.startOfDay(for: Date()))
    }

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
                    Text(isEditing ? "Taak bewerken ✏️" : "Nieuwe Taak ✏️")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.tfTextPrimary)
                        .padding(.horizontal, TFSpacing.lg)

                    // MARK: Title input
                    TextField("Wat moet er gedaan worden?", text: $title, axis: .vertical)
                        .font(.tfSubheadline())
                        .foregroundColor(.tfTextPrimary)
                        .padding(TFSpacing.md)
                        .background(Color.tfBgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                        .overlay(
                            RoundedRectangle(cornerRadius: TFRadius.input)
                                .strokeBorder(title.isEmpty ? Color.clear : Color.tfAccent.opacity(0.5), lineWidth: 1.5)
                        )
                        .padding(.horizontal, TFSpacing.lg)

                    // MARK: Priority
                    formSection(title: "Prioriteit") {
                        HStack(spacing: TFSpacing.sm) {
                            ForEach(TFPriority.allCases) { p in
                                Button(action: { priority = p }) {
                                    VStack(spacing: TFSpacing.xs) {
                                        Circle()
                                            .fill(p.color)
                                            .frame(width: 10, height: 10)
                                        Text(p.label)
                                            .font(.tfCaption())
                                            .foregroundColor(priority == p ? .white : .tfTextSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, TFSpacing.sm)
                                    .background(
                                        priority == p ? p.color : Color.tfBgSubtle
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                                    .shadow(color: priority == p ? p.color.opacity(0.3) : .clear,
                                            radius: 6, x: 0, y: 2)
                                    .offset(y: priority == p ? -2 : 0)
                                }
                                .buttonStyle(SpringButtonStyle())
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: priority)
                            }
                        }
                    }

                    // MARK: Due date
                    formSection(title: "Datum") {
                        VStack(spacing: TFSpacing.sm) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.tfAccent)
                                    .font(.system(size: 16))
                                Text(hasDueDate ? dueDate.fullDateString : "Geen vervaldatum")
                                    .font(.tfSubheadline())
                                    .foregroundColor(hasDueDate ? .tfTextPrimary : .tfTextSecondary)
                                Spacer()
                                CustomToggle(isOn: $hasDueDate)
                            }
                            .padding(TFSpacing.md)
                            .background(Color.tfBgSubtle)
                            .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                            .onTapGesture {
                                if hasDueDate {
                                    withAnimation { showDatePicker.toggle() }
                                }
                            }

                            if hasDueDate && showDatePicker {
                                DatePicker("", selection: $dueDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .tint(.tfAccent)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showDatePicker)
                            }

                        }
                    }

                    Button(action: toggleMoreOptions) {
                        HStack(spacing: TFSpacing.sm) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14, weight: .semibold))
                            Text(showMoreOptions ? "Minder opties" : "Meer opties")
                                .font(.tfSubheadline())
                            Spacer()
                            Image(systemName: showMoreOptions ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.tfTextPrimary)
                        .padding(TFSpacing.md)
                        .background(Color.tfBgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, TFSpacing.lg)

                    if showMoreOptions {
                        advancedOptions
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // MARK: Submit button
                    Button(action: saveTask) {
                        Text(isEditing ? "Opslaan" : "Taak toevoegen")
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
                            .buttonGlowShadow(color: .tfAccent)
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
        .onChange(of: hasDueDate) { _, newValue in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                showDatePicker = newValue
                if !newValue {
                    hasDueTime = false
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func formSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: TFSpacing.sm) {
            Text(title.uppercased())
                .font(.tfCaption())
                .tracking(0.8)
                .foregroundColor(.tfTextSecondary)
                .padding(.horizontal, TFSpacing.lg)
            content()
                .padding(.horizontal, TFSpacing.lg)
        }
    }

    private var advancedOptions: some View {
        VStack(alignment: .leading, spacing: TFSpacing.xl) {
            VStack(alignment: .leading, spacing: TFSpacing.sm) {
                if showNotes {
                    TextField("Notitie...", text: $notes, axis: .vertical)
                        .font(.tfBody())
                        .foregroundColor(.tfTextPrimary)
                        .lineLimit(3...8)
                        .padding(TFSpacing.md)
                        .background(Color.tfBgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                } else {
                    Button(action: { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { showNotes = true } }) {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 14))
                            Text("Notitie toevoegen...")
                                .font(.tfBody())
                        }
                        .foregroundColor(.tfTextSecondary)
                        .padding(TFSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.tfBgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TFSpacing.lg)

            if hasDueDate {
                formSection(title: "Tijd") {
                    VStack(spacing: TFSpacing.sm) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.tfAccent)
                                .font(.system(size: 14))
                            Text("Tijd instellen")
                                .font(.tfSubheadline())
                                .foregroundColor(.tfTextSecondary)
                            Spacer()
                            CustomToggle(isOn: $hasDueTime)
                        }
                        .padding(TFSpacing.md)
                        .background(Color.tfBgSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))

                        if hasDueTime {
                            DatePicker("", selection: $dueTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .tint(.tfAccent)
                                .frame(maxWidth: .infinity)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
            }

            formSection(title: "Tijdblok") {
                HStack(spacing: TFSpacing.sm) {
                    ForEach(TFTimeBlock.allCases) { block in
                        Button(action: { timeBlock = block }) {
                            VStack(spacing: TFSpacing.xs) {
                                Text(block.emoji)
                                    .font(.system(size: 14))
                                Text(block.label)
                                    .font(.tfCaption())
                                    .foregroundColor(timeBlock == block ? .white : .tfTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TFSpacing.sm)
                            .background(timeBlock == block ? Color.tfAccent : Color.tfBgSubtle)
                            .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                            .offset(y: timeBlock == block ? -2 : 0)
                            .shadow(color: timeBlock == block ? Color.tfAccent.opacity(0.25) : .clear,
                                    radius: 6, x: 0, y: 2)
                        }
                        .buttonStyle(SpringButtonStyle())
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: timeBlock)
                    }
                }
            }

            formSection(title: "Tags") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: TFSpacing.sm) {
                        ForEach(allTags) { tag in
                            let isSelected = selectedTags.contains(where: { $0.id == tag.id })
                            Button(action: {
                                if isSelected {
                                    selectedTags.removeAll { $0.id == tag.id }
                                } else {
                                    selectedTags.append(tag)
                                }
                            }) {
                                Text(tag.name.uppercased())
                                    .font(.tfCaption())
                                    .tracking(0.5)
                                    .foregroundColor(isSelected ? .white : tag.color)
                                    .padding(.horizontal, TFSpacing.md)
                                    .padding(.vertical, TFSpacing.sm)
                                    .background(isSelected ? tag.color : tag.color.opacity(0.10))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(SpringButtonStyle())
                        }

                        if showNewTagInput {
                            HStack(spacing: TFSpacing.xs) {
                                TextField("Nieuwe tag", text: $newTagName)
                                    .font(.tfCaption())
                                    .frame(width: 80)
                                Button(action: addNewTag) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.tfAccent)
                                }
                            }
                            .padding(.horizontal, TFSpacing.sm)
                            .padding(.vertical, TFSpacing.sm)
                            .background(Color.tfBgSubtle)
                            .clipShape(Capsule())
                        } else {
                            Button(action: { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { showNewTagInput = true } }) {
                                HStack(spacing: TFSpacing.xs) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("Nieuwe tag")
                                        .font(.tfCaption())
                                }
                                .foregroundColor(.tfAccent)
                                .padding(.horizontal, TFSpacing.md)
                                .padding(.vertical, TFSpacing.sm)
                                .background(Color.tfAccent.opacity(0.10))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(SpringButtonStyle())
                        }
                    }
                    .padding(.vertical, TFSpacing.xs)
                }
            }

            formSection(title: "Project") {
                Menu {
                    Button("Geen project") { selectedProject = nil }
                    ForEach(projects) { project in
                        Button(action: { selectedProject = project }) {
                            Text("\(project.emoji) \(project.name)")
                        }
                    }
                } label: {
                    HStack {
                        if let project = selectedProject {
                            Text(project.emoji + " " + project.name)
                                .font(.tfSubheadline())
                                .foregroundColor(.tfTextPrimary)
                        } else {
                            Text("Geen project")
                                .font(.tfSubheadline())
                                .foregroundColor(.tfTextSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.tfTextSecondary)
                    }
                    .padding(TFSpacing.md)
                    .background(Color.tfBgSubtle)
                    .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                }
            }

            formSection(title: "Subtaken") {
                VStack(spacing: TFSpacing.sm) {
                    ForEach($subtasks) { $subtask in
                        HStack(spacing: TFSpacing.sm) {
                            CheckButtonView(isDone: subtask.isDone) {
                                subtask.isDone.toggle()
                            }
                            TextField("Subtaak", text: $subtask.title)
                                .font(.tfBody())
                                .foregroundColor(.tfTextPrimary)
                            Button(action: { subtasks.removeAll { $0.id == subtask.id } }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.tfTextSecondary)
                            }
                        }
                        .padding(.vertical, TFSpacing.xs)
                    }

                    HStack(spacing: TFSpacing.sm) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.tfAccent)
                        TextField("Subtaak toevoegen...", text: $newSubtaskTitle)
                            .font(.tfBody())
                            .foregroundColor(.tfTextPrimary)
                            .onSubmit { addSubtask() }
                    }
                    .padding(.vertical, TFSpacing.xs)
                }
            }

            formSection(title: "Schatting") {
                HStack {
                    Text("Schatting")
                        .font(.tfSubheadline())
                        .foregroundColor(.tfTextSecondary)
                    Spacer()
                    let options = [nil, 15, 30, 45, 60, 90]
                    HStack(spacing: TFSpacing.xs) {
                        ForEach(options, id: \.self) { mins in
                            Button(action: { estimatedMinutes = mins }) {
                                Text(mins.map { "\($0)m" } ?? "–")
                                    .font(.tfCaption())
                                    .foregroundColor(estimatedMinutes == mins ? .white : .tfTextSecondary)
                                    .padding(.horizontal, TFSpacing.sm)
                                    .padding(.vertical, TFSpacing.xs)
                                    .background(estimatedMinutes == mins ? Color.tfAccent : Color.tfBgSubtle)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(SpringButtonStyle())
                        }
                    }
                }
                .padding(TFSpacing.md)
                .background(Color.tfBgSubtle)
                .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
            }
        }
    }

    private func populateIfEditing() {
        guard let task = existingTask else {
            selectedProject = defaultProject
            return
        }
        title = task.title
        notes = task.notes
        showNotes = !task.notes.isEmpty
        priority = task.priority
        timeBlock = task.timeBlock
        if let due = task.dueDate {
            hasDueDate = true
            dueDate = due
        } else {
            hasDueDate = false
        }
        if let t = task.dueTime { hasDueTime = true; dueTime = t }
        selectedProject = task.project
        selectedTags = task.tags
        subtasks = task.subtasks
        estimatedMinutes = task.estimatedMinutes
        showMoreOptions = hasAdvancedConfiguration(task)
    }

    private func addNewTag() {
        guard !newTagName.isEmpty else { return }
        let colorHex = Color.tfTagHexColors.randomElement() ?? "#5B6EF5"
        let tag = TFTag(name: newTagName, colorHex: colorHex)
        context.insert(tag)
        selectedTags.append(tag)
        newTagName = ""
        showNewTagInput = false
    }

    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        subtasks.append(TFSubtask(title: newSubtaskTitle))
        newSubtaskTitle = ""
    }

    private func toggleMoreOptions() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showMoreOptions.toggle()
        }
    }

    private func hasAdvancedConfiguration(_ task: TFTask) -> Bool {
        !task.notes.isEmpty ||
        task.dueTime != nil ||
        task.timeBlock != .unscheduled ||
        task.project != nil ||
        !task.tags.isEmpty ||
        !task.subtasks.isEmpty ||
        task.estimatedMinutes != nil
    }

    private func saveTask() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if let task = existingTask {
            task.title = title
            task.notes = notes
            task.priority = priority
            task.timeBlock = timeBlock
            task.dueDate = hasDueDate ? dueDate : nil
            task.dueTime = (hasDueDate && hasDueTime) ? dueTime : nil
            task.project = selectedProject
            task.tags = selectedTags
            task.subtasks = subtasks
            task.estimatedMinutes = estimatedMinutes
        } else {
            let task = TFTask(
                title: title,
                notes: notes,
                priority: priority,
                timeBlock: timeBlock,
                dueDate: hasDueDate ? dueDate : nil,
                dueTime: (hasDueDate && hasDueTime) ? dueTime : nil
            )
            task.project = selectedProject
            task.tags = selectedTags
            task.subtasks = subtasks
            task.estimatedMinutes = estimatedMinutes
            context.insert(task)
        }

        dismiss()
    }
}
