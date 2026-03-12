// PreviewData.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

@MainActor
struct PreviewData {

    // MARK: - In-memory container
    static var container: ModelContainer = {
        let schema = Schema([TFTask.self, TFProject.self, TFTag.self, CheckInEntry.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        insertSampleData(into: container.mainContext)
        return container
    }()

    // MARK: - Date helpers
    private static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
    }

    private static func daysAgo(_ n: Int, hour: Int, minute: Int = 0) -> Date {
        let base = daysAgo(n)
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }

    private static func daysFromNow(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: Date()) ?? Date()
    }

    // MARK: - Tags
    static func makeTags(context: ModelContext) -> [TFTag] {
        let design    = TFTag(name: "Design",       colorHex: "#5B6EF5")
        let dev       = TFTag(name: "Ontwikkeling", colorHex: "#7C3AED")
        let mktg      = TFTag(name: "Marketing",    colorHex: "#F97316")
        let client    = TFTag(name: "Klant",        colorHex: "#10B981")
        let personal  = TFTag(name: "Persoonlijk",  colorHex: "#EC4899")
        let finance   = TFTag(name: "Financiën",    colorHex: "#F59E0B")
        [design, dev, mktg, client, personal, finance].forEach { context.insert($0) }
        return [design, dev, mktg, client, personal, finance]
    }

    // MARK: - Projects
    static func makeProjects(context: ModelContext) -> [TFProject] {
        let webshop = TFProject(
            name: "Webshop Redesign",
            emoji: "🎨",
            colorHex: "#5B6EF5",
            notes: "Volledige herontwerp van de webshop — desktop & mobiel",
            deadline: daysFromNow(5)
        )
        let brand = TFProject(
            name: "Brand Identity",
            emoji: "✏️",
            colorHex: "#EC4899",
            notes: "Logo, kleurpalet, typografie en huisstijlgids",
            deadline: daysFromNow(12)
        )
        let marketing = TFProject(
            name: "Q2 Marketing",
            emoji: "📣",
            colorHex: "#F97316",
            notes: "Campagnes en content voor Q2",
            deadline: daysFromNow(21)
        )
        let app = TFProject(
            name: "App Lancering",
            emoji: "📱",
            colorHex: "#10B981",
            notes: "iOS app klaar voor App Store lancering",
            deadline: daysFromNow(30)
        )
        let admin = TFProject(
            name: "Administratie",
            emoji: "🗂️",
            colorHex: "#F59E0B",
            notes: "Boekhouding en facturen"
        )
        [webshop, brand, marketing, app, admin].forEach { context.insert($0) }
        return [webshop, brand, marketing, app, admin]
    }

    // MARK: - Tasks
    @discardableResult
    static func makeTasks(
        context: ModelContext,
        tags: [TFTag],
        projects: [TFProject]
    ) -> [TFTask] {
        let design   = tags[0]
        let dev      = tags[1]
        let mktg     = tags[2]
        let client   = tags[3]
        let personal = tags[4]
        let finance  = tags[5]

        let webshop  = projects[0]
        let brand    = projects[1]
        let marketing = projects[2]
        let app      = projects[3]
        let admin    = projects[4]

        // ── VANDAAG – OCHTEND ─────────────────────────────────────────

        let t1 = TFTask(
            title: "Wireframes homepage afwerken",
            notes: "Navigatie, hero sectie en product grid finaliseren voor feedback",
            priority: .high,
            timeBlock: .morning,
            dueDate: Date(),
            dueTime: Date.today(hour: 9)
        )
        t1.tags = [design]
        t1.project = webshop
        t1.estimatedMinutes = 90
        var sub1a = TFSubtask(title: "Navigatiebalk"); sub1a.isDone = false
        var sub1b = TFSubtask(title: "Hero sectie");  sub1b.isDone = true
        var sub1c = TFSubtask(title: "Product grid"); sub1c.isDone = true
        var sub1d = TFSubtask(title: "Footer");       sub1d.isDone = false
        t1.subtasks = [sub1a, sub1b, sub1c, sub1d]

        let t2 = TFTask(
            title: "Client call met Petra",
            notes: "Feedback bespreken over logo varianten v3",
            priority: .high,
            timeBlock: .morning,
            dueDate: Date(),
            dueTime: Date.today(hour: 9, minute: 30)
        )
        t2.tags = [client]
        t2.project = brand
        t2.isDone = true
        t2.completedAt = Date.today(hour: 9, minute: 55)
        t2.actualMinutes = 35

        let t3 = TFTask(
            title: "E-mails beantwoorden",
            priority: .medium,
            timeBlock: .morning,
            dueDate: Date(),
            dueTime: Date.today(hour: 8)
        )
        t3.tags = [personal]
        t3.isDone = true
        t3.completedAt = Date.today(hour: 8, minute: 22)
        t3.actualMinutes = 22

        // ── VANDAAG – MIDDAG ──────────────────────────────────────────

        let t4 = TFTask(
            title: "Landingspagina design finaliseren",
            notes: "Hero, CTA knop, social proof sectie en mobile versie",
            priority: .high,
            timeBlock: .afternoon,
            dueDate: Date(),
            dueTime: Date.today(hour: 13)
        )
        t4.tags = [design]
        t4.project = webshop
        t4.estimatedMinutes = 120
        var sub4a = TFSubtask(title: "Hero sectie"); sub4a.isDone = true
        var sub4b = TFSubtask(title: "CTA knop");   sub4b.isDone = false
        var sub4c = TFSubtask(title: "Mobiel");     sub4c.isDone = false
        t4.subtasks = [sub4a, sub4b, sub4c]

        let t5 = TFTask(
            title: "Social media content plannen",
            notes: "5 posts voor Instagram en LinkedIn deze week",
            priority: .medium,
            timeBlock: .afternoon,
            dueDate: Date(),
            dueTime: Date.today(hour: 14, minute: 30)
        )
        t5.tags = [mktg]
        t5.project = marketing
        t5.estimatedMinutes = 60

        let t6 = TFTask(
            title: "Offertes opvolgen",
            notes: "2 openstaande offertes nakijken en opvolgen",
            priority: .medium,
            timeBlock: .afternoon,
            dueDate: Date(),
            dueTime: Date.today(hour: 15)
        )
        t6.tags = [client, finance]
        t6.estimatedMinutes = 30

        // ── VANDAAG – AVOND ───────────────────────────────────────────

        let t7 = TFTask(
            title: "Weekplanning opmaken",
            priority: .low,
            timeBlock: .evening,
            dueDate: Date(),
            dueTime: Date.today(hour: 19)
        )
        t7.tags = [personal]
        t7.estimatedMinutes = 20

        // ── VANDAAG – ONGEPLAND ───────────────────────────────────────

        let t8 = TFTask(
            title: "Font licentie kopen",
            priority: .low,
            timeBlock: .unscheduled,
            dueDate: Date()
        )
        t8.tags = [design]
        t8.project = webshop

        let t9 = TFTask(
            title: "Facturen verwerken",
            notes: "Maart facturen invoeren in boekhoudsoftware",
            priority: .medium,
            timeBlock: .unscheduled,
            dueDate: Date()
        )
        t9.tags = [finance]
        t9.project = admin

        // ── HISTORISCHE TAKEN – voor stats & streak kalender ──────────

        // Gisteren (4 taken)
        let h1 = hist("App prototype testen",          priority: .high,   daysAgo: 1, hour: 10, tags: [dev],            project: app,       minutes: 75)
        let h2 = hist("Newsletter schrijven",          priority: .medium, daysAgo: 1, hour: 11, tags: [mktg],           project: marketing)
        let h3 = hist("Klantfeedback verwerken",       priority: .high,   daysAgo: 1, hour: 14, tags: [client, design], project: brand,     minutes: 50)
        let h4 = hist("Agenda opruimen",               priority: .low,    daysAgo: 1, hour: 16, tags: [personal])

        // 2 dagen geleden (5 taken)
        let h5 = hist("API integratie voltooien",      priority: .high,   daysAgo: 2, hour: 9,  tags: [dev],            project: app,       minutes: 180)
        let h6 = hist("Kleurpalet finaliseren",        priority: .medium, daysAgo: 2, hour: 11, tags: [design],         project: brand)
        let h7 = hist("Pitch deck afwerken",           priority: .high,   daysAgo: 2, hour: 14, tags: [client, mktg],   project: marketing, minutes: 90)
        let h8 = hist("Maandoverzicht bijhouden",      priority: .low,    daysAgo: 2, hour: 15, tags: [finance],        project: admin)
        let h9 = hist("Sporten",                       priority: .low,    daysAgo: 2, hour: 18, tags: [personal])

        // 3 dagen geleden (3 taken)
        let h10 = hist("Homepage copy schrijven",      priority: .medium, daysAgo: 3, hour: 10, tags: [mktg, design],   project: webshop)
        let h11 = hist("Logo varianten uitwerken",     priority: .high,   daysAgo: 3, hour: 13, tags: [design],         project: brand,     minutes: 120)
        let h12 = hist("Team standup voorbereiden",    priority: .medium, daysAgo: 3, hour: 9,  tags: [client])

        // 4 dagen geleden (4 taken)
        let h13 = hist("Database schema reviewen",     priority: .high,   daysAgo: 4, hour: 9,  tags: [dev],            project: app,       minutes: 60)
        let h14 = hist("Kwartaalrapport lezen",        priority: .medium, daysAgo: 4, hour: 11, tags: [finance, client])
        let h15 = hist("Ontwerpfeedback verwerken",    priority: .medium, daysAgo: 4, hour: 14, tags: [design],         project: webshop)
        let h16 = hist("Yoga sessie",                  priority: .low,    daysAgo: 4, hour: 17, tags: [personal])

        // 5 dagen geleden (3 taken)
        let h17 = hist("Content kalender opstellen",   priority: .medium, daysAgo: 5, hour: 10, tags: [mktg],           project: marketing)
        let h18 = hist("Codebase refactor",            priority: .high,   daysAgo: 5, hour: 9,  tags: [dev],            project: app,       minutes: 150)
        let h19 = hist("Offertesjabloon bijwerken",    priority: .medium, daysAgo: 5, hour: 15, tags: [client, finance])

        // 6 dagen geleden (3 taken)
        let h20 = hist("Inspiratiebord maken",         priority: .low,    daysAgo: 6, hour: 9,  tags: [design],         project: brand)
        let h21 = hist("BTW aangifte voorbereiden",    priority: .high,   daysAgo: 6, hour: 14, tags: [finance],        project: admin,     minutes: 45)
        let h22 = hist("Klantpresentatie oefenen",     priority: .medium, daysAgo: 6, hour: 16, tags: [client, mktg])

        let today = [t1, t2, t3, t4, t5, t6, t7, t8, t9]
        let historical = [h1, h2, h3, h4, h5, h6, h7, h8, h9,
                          h10, h11, h12, h13, h14, h15, h16,
                          h17, h18, h19, h20, h21, h22]

        (today + historical).forEach { context.insert($0) }
        return today + historical
    }

    // MARK: - Historical task convenience init
    private static func hist(
        _ title: String,
        priority: TFPriority,
        daysAgo days: Int,
        hour: Int,
        tags: [TFTag] = [],
        project: TFProject? = nil,
        minutes: Int? = nil
    ) -> TFTask {
        let taskDate      = daysAgo(days)
        let completedDate = daysAgo(days, hour: hour + 1)
        let task = TFTask(
            title: title,
            priority: priority,
            timeBlock: TFTimeBlock.from(hour: hour),
            dueDate: taskDate
        )
        task.tags = tags
        task.project = project
        task.isDone = true
        task.completedAt = completedDate
        task.actualMinutes = minutes
        return task
    }

    // MARK: - Check-in entries (streak kalender — 27 van de laatste 30 dagen)
    static func makeCheckInEntries(context: ModelContext) {
        // Cyclisch mood patroon voor herkenbare maar gevarieerde data
        let moods: [(Int, String)] = [
            (4, "🤩"), (3, "😊"), (4, "😊"), (3, "🙂"), (4, "🤩"),
            (2, "😐"), (3, "🙂"), (4, "😊"), (4, "🤩"), (3, "😊")
        ]
        let goals = [
            "Focus op de twee belangrijkste taken",
            "Webshop design afronden",
            "Klantgesprekken productief houden",
            "Energie sparen voor deep work",
            "Ochtend blok volledig benutten",
            "Projectdeadline halen",
            "Inbox op nul krijgen",
        ]
        // Laat 3 willekeurige dagen leeg voor realisme (dag 9, 16, 23)
        let skippedOffsets = Set([9, 16, 23])

        for offset in 0..<30 {
            guard !skippedOffsets.contains(offset) else { continue }
            let (moodScore, moodEmoji) = moods[offset % moods.count]
            let entry = CheckInEntry(
                moodScore: moodScore,
                moodEmoji: moodEmoji,
                dailyGoal: goals[offset % goals.count]
            )
            if let entryDate = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) {
                entry.date = Calendar.current.startOfDay(for: entryDate)
            }
            context.insert(entry)
        }
    }

    // MARK: - UserDefaults demo waarden
    static func seedUserDefaults() {
        let defaults = UserDefaults.standard
        // Naam enkel overschrijven als leeg
        let name = defaults.string(forKey: "userName") ?? ""
        if name.isEmpty { defaults.set("Batiste", forKey: "userName") }
        // Streak
        defaults.set(12, forKey: "currentStreak")
        defaults.set(18, forKey: "longestStreak")
        // Datum zodat streak niet automatisch gereset wordt
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        defaults.set(formatter.string(from: Date()), forKey: "lastStreakDate")
        // Onboarding voltooid zodat ContentView direct zichtbaar is
        defaults.set(true, forKey: "hasCompletedOnboarding")
    }

    // MARK: - Alles samen invoegen
    static func insertSampleData(into context: ModelContext) {
        seedUserDefaults()
        let tags     = makeTags(context: context)
        let projects = makeProjects(context: context)
        makeTasks(context: context, tags: tags, projects: projects)
        makeCheckInEntries(context: context)
    }
}
