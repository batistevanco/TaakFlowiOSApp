# TaakFlow — iOS Task Manager App
### Complete Build Specification for Claude Code
> Version 1.0 · Vancoillie Studio · Roeselare, België
> Language: Swift + SwiftUI · iOS 17+ · Free, no ads, no tracking

---

## TABLE OF CONTENTS

1. [Project Overview](#1-project-overview)
2. [Design System](#2-design-system)
3. [Architecture](#3-architecture)
4. [Data Models](#4-data-models)
5. [App Structure & Navigation](#5-app-structure--navigation)
6. [Screens — Full Specification](#6-screens--full-specification)
   - 6.1 Morning Check-in Flow
   - 6.2 Today View
   - 6.3 All Tasks View
   - 6.4 Projects View
   - 6.5 Focus Mode
   - 6.6 Stats & Insights View
   - 6.7 Settings View
   - 6.8 Add / Edit Task Sheet
   - 6.9 Add / Edit Project Sheet
   - 6.10 Onboarding Flow
7. [Animations & Interactions](#7-animations--interactions)
8. [Notifications](#8-notifications)
9. [Widgets](#9-widgets)
10. [Shortcuts & Siri](#10-shortcuts--siri)
11. [iCloud Sync](#11-icloud-sync)
12. [Accessibility](#12-accessibility)
13. [Localization](#13-localization)
14. [App Icon & Assets](#14-app-icon--assets)
15. [Privacy & Data](#15-privacy--data)
16. [Testing](#16-testing)
17. [Claude Code Instructions](#17-claude-code-instructions)

---

## 1. PROJECT OVERVIEW

### What is TaakFlow?

TaakFlow is a **premium-feeling, completely free** native iOS task manager designed for freelancers, students, and professionals. It blends simple to-do lists, time-blocked daily planning, and project management into one clean, minimal interface.

**Tagline:** *"Your tasks, your flow."*

**Core philosophy:**
- Simplify the Technology (Vancoillie Studio motto)
- Color as accent only — never as background
- Every animation has a purpose
- Zero friction to add a task
- No accounts, no cloud required in v1.0, no ads, ever

**Target users:**
- Freelancers (especially Invoxa users)
- Students (like the developer)
- Productivity-focused professionals

**Monetization:** Completely free. No IAP, no subscription, no ads.

---

## 2. DESIGN SYSTEM

### 2.1 Color Palette

```swift
// Primary
let accent        = Color(hex: "#5B6EF5")   // Indigo — primary actions, active states
let accent2       = Color(hex: "#7C3AED")   // Purple — gradient pair with accent

// Semantic
let priorityHigh  = Color(hex: "#EF4444")   // Red
let priorityMed   = Color(hex: "#F97316")   // Orange
let priorityLow   = Color(hex: "#22C55E")   // Green
let priorityNone  = Color(hex: "#D1D5DB")   // Gray

// Backgrounds
let bgPrimary     = Color(hex: "#F5F6FA")   // Main app background
let bgCard        = Color.white             // Card/surface background
let bgSubtle      = Color(hex: "#F0F0F5")   // Input fields, secondary surfaces

// Text
let textPrimary   = Color(hex: "#111827")   // Main text
let textSecondary = Color(hex: "#9CA3AF")   // Subtext, labels
let textOnAccent  = Color.white             // Text on colored backgrounds

// Borders
let borderLight   = Color(hex: "#F0F0F5")   // Very subtle borders
let borderMedium  = Color(hex: "#E5E7EB")   // Slightly more visible

// Tag colors (user-assignable)
let tagIndigo  = Color(hex: "#5B6EF5")
let tagPurple  = Color(hex: "#7C3AED")
let tagRed     = Color(hex: "#EF4444")
let tagOrange  = Color(hex: "#F97316")
let tagGreen   = Color(hex: "#22C55E")
let tagBlue    = Color(hex: "#0EA5E9")
let tagPink    = Color(hex: "#EC4899")
let tagYellow  = Color(hex: "#EAB308")
```

**THE MOST IMPORTANT COLOR RULE:**
> Color is used as accent only. Backgrounds are always white or #F5F6FA. Never use a solid color as a card background. The only exception is the hero gradient card (indigo → purple gradient) which appears ONCE per screen as the main metric card.

### 2.2 Typography

**Font:** Plus Jakarta Sans (Google Fonts — import via Info.plist or use `@import`)

```swift
// Font scale
.largeTitle  → Plus Jakarta Sans, 800 weight, -1.0 tracking   // Screen titles e.g. "Today"
.title2      → Plus Jakarta Sans, 700 weight, -0.5 tracking   // Section titles
.headline    → Plus Jakarta Sans, 700 weight, -0.3 tracking   // Card titles, task names
.subheadline → Plus Jakarta Sans, 600 weight, 0 tracking      // Metadata, subtitles
.caption     → Plus Jakarta Sans, 700 weight, +0.5 tracking   // Tags, labels (UPPERCASE)
.caption2    → Plus Jakarta Sans, 600 weight, +0.3 tracking   // Timestamps, fine print
```

All titles use negative letter-spacing for a premium feel. All-caps labels always use +0.8 tracking.

### 2.3 Spacing

```
Base unit: 4pt
xs:   4pt
sm:   8pt
md:  12pt
lg:  16pt
xl:  20pt
2xl: 24pt
3xl: 32pt
```

### 2.4 Corner Radii

```
Small components (tags, badges):  99pt (fully rounded)
Inputs, small cards:              12–14pt
Standard cards:                   18pt
Large cards, hero cards:          22pt
Sheets (bottom sheets):           28pt top corners
Phone frame / full overlays:      50pt
```

### 2.5 Shadows

```swift
// Card shadow (standard)
.shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 2)

// Elevated card
.shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 4)

// Hero card glow
.shadow(color: accent.opacity(0.30), radius: 32, x: 0, y: 12)

// FAB glow
.shadow(color: accent.opacity(0.40), radius: 24, x: 0, y: 8)

// Active/focused element
.shadow(color: accent.opacity(0.20), radius: 8, x: 0, y: 0)

// Colored button glow (match button color)
.shadow(color: buttonColor.opacity(0.35), radius: 16, x: 0, y: 8)
```

### 2.6 Hero Gradient Card

Used ONCE per major screen as the primary metric display:

```swift
LinearGradient(
    colors: [Color(hex: "#5B6EF5"), Color(hex: "#7C3AED")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
.cornerRadius(22)
.shadow(color: Color(hex: "#5B6EF5").opacity(0.3), radius: 32, x: 0, y: 12)
```

Add two decorative circles inside (white, 10% opacity, blurred) at top-right and bottom-left for depth.

---

## 3. ARCHITECTURE

### 3.1 Tech Stack

```
Language:        Swift 5.9+
UI Framework:    SwiftUI
Data:            SwiftData (iOS 17+)
Notifications:   UserNotifications
Widgets:         WidgetKit
Intents:         AppIntents (Siri/Shortcuts)
Sync:            CloudKit (v1.1, optional)
Minimum iOS:     17.0
Devices:         iPhone (primary), iPad (adaptive)
```

### 3.2 Project Structure

```
TaakFlow/
├── TaakFlowApp.swift              // App entry point, scene setup
├── ContentView.swift              // Root TabView
│
├── Models/                        // SwiftData models
│   ├── Task.swift
│   ├── Project.swift
│   ├── Tag.swift
│   ├── CheckInEntry.swift
│   └── AppSettings.swift
│
├── Views/
│   ├── Today/
│   │   ├── TodayView.swift
│   │   ├── TodayHeroCard.swift
│   │   ├── TodayStatsRow.swift
│   │   └── TimeBlockSection.swift
│   ├── Tasks/
│   │   ├── AllTasksView.swift
│   │   ├── TaskCard.swift
│   │   └── TaskFilterBar.swift
│   ├── Projects/
│   │   ├── ProjectsView.swift
│   │   ├── ProjectCard.swift
│   │   └── ProjectDetailView.swift
│   ├── Focus/
│   │   ├── FocusModeView.swift
│   │   └── PomodoroTimer.swift
│   ├── Stats/
│   │   ├── StatsView.swift
│   │   ├── WeeklyChart.swift
│   │   └── StreakCalendar.swift
│   ├── CheckIn/
│   │   ├── MorningCheckInView.swift
│   │   ├── CheckInMoodStep.swift
│   │   ├── CheckInGoalStep.swift
│   │   ├── CheckInProjectsStep.swift
│   │   └── CheckInTasksStep.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── NotificationSettings.swift
│   │   └── AppearanceSettings.swift
│   ├── Shared/
│   │   ├── TaskCardView.swift
│   │   ├── PriorityDot.swift
│   │   ├── TagPill.swift
│   │   ├── CheckButton.swift
│   │   ├── GradientHeroCard.swift
│   │   ├── FilterPill.swift
│   │   └── SectionHeader.swift
│   └── Sheets/
│       ├── AddTaskSheet.swift
│       ├── EditTaskSheet.swift
│       ├── AddProjectSheet.swift
│       └── OnboardingView.swift
│
├── ViewModels/
│   ├── TaskViewModel.swift
│   ├── ProjectViewModel.swift
│   ├── StatsViewModel.swift
│   └── CheckInViewModel.swift
│
├── Services/
│   ├── NotificationService.swift
│   ├── StreakService.swift
│   └── CloudKitService.swift      // v1.1
│
├── Extensions/
│   ├── Color+Hex.swift
│   ├── Date+Helpers.swift
│   ├── View+Animations.swift
│   └── View+SpringTransition.swift
│
├── Widgets/
│   ├── TodayWidget.swift
│   ├── StreakWidget.swift
│   └── QuickAddWidget.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.strings (NL, EN)
    └── Info.plist
```

### 3.3 State Management

- Use `@Observable` (Swift 5.9 Observation framework) for ViewModels
- Use `@Environment(\.modelContext)` for SwiftData operations
- Use `@AppStorage` for simple user preferences
- Use `@State` / `@Binding` for local UI state only
- Avoid passing model objects deeply — use environment or pass IDs

---

## 4. DATA MODELS

### 4.1 Task

```swift
@Model
class Task {
    var id: UUID
    var title: String
    var notes: String
    var isDone: Bool
    var createdAt: Date
    var dueDate: Date?             // Optional due date
    var dueTime: Date?             // Optional time (used for notification + time block)
    var completedAt: Date?
    var priority: Priority         // .none .low .medium .high
    var timeBlock: TimeBlock       // .morning .afternoon .evening .unscheduled
    var isRecurring: Bool
    var recurrenceRule: RecurrenceRule?  // .daily .weekly .monthly .custom
    var subtasks: [Subtask]
    var attachments: [TaskAttachment]   // v1.1
    
    // Relationships
    var project: Project?
    var tags: [Tag]
    
    // Focus
    var estimatedMinutes: Int?     // Pomodoro estimate
    var actualMinutes: Int?        // Logged time
    
    // Computed
    var isOverdue: Bool { ... }
    var isToday: Bool { ... }
    var progressPercentage: Double { subtasks... }
}

enum Priority: String, Codable, CaseIterable {
    case none, low, medium, high
    
    var color: Color { ... }
    var label: String { ... }
    var sortOrder: Int { ... }
}

enum TimeBlock: String, Codable, CaseIterable {
    case morning      // 06:00–12:00
    case afternoon    // 12:00–17:00
    case evening      // 17:00–23:59
    case unscheduled
    
    var emoji: String { ... }
    var label: String { ... }
    var timeRange: String { ... }
}

struct Subtask: Codable, Identifiable {
    var id: UUID
    var title: String
    var isDone: Bool
}

struct RecurrenceRule: Codable {
    var frequency: Frequency       // .daily .weekly .monthly
    var interval: Int              // Every N days/weeks/months
    var daysOfWeek: [Int]?         // For weekly
    var endDate: Date?
}
```

### 4.2 Project

```swift
@Model
class Project {
    var id: UUID
    var name: String
    var emoji: String              // e.g. "💼"
    var colorHex: String           // Hex string for custom color
    var notes: String
    var createdAt: Date
    var deadline: Date?
    var isArchived: Bool
    var sortOrder: Int
    
    // Relationships
    var tasks: [Task]
    
    // Computed
    var totalTasks: Int { tasks.count }
    var completedTasks: Int { tasks.filter(\.isDone).count }
    var progressPercentage: Double { ... }
    var isOverdue: Bool { ... }
    var color: Color { Color(hex: colorHex) }
}
```

### 4.3 Tag

```swift
@Model
class Tag {
    var id: UUID
    var name: String
    var colorHex: String
    var sortOrder: Int
    
    // Relationships
    var tasks: [Task]
    
    var color: Color { Color(hex: colorHex) }
}
```

### 4.4 CheckInEntry

```swift
@Model
class CheckInEntry {
    var id: UUID
    var date: Date
    var moodScore: Int             // 1–4 (tired/okay/good/great)
    var moodEmoji: String
    var dailyGoal: String
    var plannedTaskTitles: [String]
    var selectedProjectIDs: [UUID]
    var completedAt: Date
    
    // Evening reflection (future)
    var eveningNote: String?
    var satisfactionScore: Int?    // 1–5
}
```

### 4.5 AppSettings

Stored via `@AppStorage` (UserDefaults):

```swift
// Morning Check-in
@AppStorage("checkinEnabled") var checkinEnabled = true
@AppStorage("checkinTime") var checkinTime = "08:00"
@AppStorage("checkinShowProjects") var checkinShowProjects = true
@AppStorage("checkinShowMood") var checkinShowMood = true

// Notifications
@AppStorage("notificationsEnabled") var notificationsEnabled = true
@AppStorage("dailySummaryEnabled") var dailySummaryEnabled = true
@AppStorage("dailySummaryTime") var dailySummaryTime = "20:00"
@AppStorage("overdueReminders") var overdueReminders = true

// Appearance
@AppStorage("colorScheme") var colorScheme = "system"  // system/light/dark
@AppStorage("appLanguage") var appLanguage = "nl"       // nl/en

// Focus
@AppStorage("pomodoroMinutes") var pomodoroMinutes = 25
@AppStorage("shortBreakMinutes") var shortBreakMinutes = 5
@AppStorage("longBreakMinutes") var longBreakMinutes = 15
@AppStorage("autoStartBreaks") var autoStartBreaks = false

// Streak
@AppStorage("lastStreakDate") var lastStreakDate = ""
@AppStorage("currentStreak") var currentStreak = 0
@AppStorage("longestStreak") var longestStreak = 0

// Onboarding
@AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
@AppStorage("hasSeenCheckinIntro") var hasSeenCheckinIntro = false
```

---

## 5. APP STRUCTURE & NAVIGATION

### 5.1 Tab Bar

4 tabs, bottom tab bar, white background, blur effect:

```
Tab 1: Vandaag (Today)     icon: sun.max.fill / sun.max
Tab 2: Taken (Tasks)       icon: checkmark.square.fill / checkmark.square
Tab 3: Projecten           icon: folder.fill / folder
Tab 4: Inzichten (Stats)   icon: chart.bar.fill / chart.bar
Tab 5: Instellingen        icon: gearshape.fill / gearshape  (only in Settings, accessed via Today)
```

Actually use 4 main tabs + Settings accessible via a gear icon in the Today header.

Active tab indicator: accent color icon + accent color label. The active icon gets a soft indigo background pill (rgba(91,110,245,0.10), cornerRadius 10).

### 5.2 Navigation Flow

```
App Launch
├── [First launch] → OnboardingView (3 screens)
├── [hasCompletedOnboarding] → ContentView (TabView)
│
ContentView (TabView)
├── Tab 1: TodayView
│   ├── → AddTaskSheet (FAB or + button)
│   ├── → FocusModeView (tap task body)
│   ├── → EditTaskSheet (long press task)
│   └── [On app open, if checkinEnabled && time matches] → MorningCheckInView
│
├── Tab 2: AllTasksView
│   ├── → AddTaskSheet
│   ├── → EditTaskSheet (tap task)
│   └── → FocusModeView (tap focus icon)
│
├── Tab 3: ProjectsView
│   ├── → ProjectDetailView (tap project)
│   │   ├── → AddTaskSheet
│   │   └── → EditTaskSheet
│   └── → AddProjectSheet (+ button)
│
├── Tab 4: StatsView
│   ├── WeeklyChart
│   ├── StreakCalendar
│   └── ProductivityInsights
│
└── [Gear icon in Today header] → SettingsView
    ├── → NotificationSettings
    └── → AppearanceSettings
```

---

## 6. SCREENS — FULL SPECIFICATION

---

### 6.1 Morning Check-in Flow

**Trigger conditions:**
- `checkinEnabled == true`
- Current time is within 30 minutes after `checkinTime`
- Check-in hasn't been completed today yet
- App is foregrounded (not from a background fetch)

**Presentation:** Full-screen overlay with a light gradient background (`#EEF0FF → #F5F0FF`). Slides up from bottom with spring animation. Cannot be dismissed by swiping down — only via "Skip" or completing all steps.

**Step indicator:** Row of dots at top. Active dot is wider (24pt wide, accent color). Completed dots are accent. Future dots are borderMedium gray. All dots are 4pt tall, 8pt wide, with animated width transition.

#### Step 1 — Stemming (Mood)
- Chip at top: "☀️ Ochtend Check-in" (indigo background pill)
- Title: "Hoe voel jij je\nvandaag? 👋" (large, 800 weight)
- Subtitle: "Neem even 2 minuten voor jezelf"
- White card with 4 mood buttons in a row:
  - 😴 Moe / 😐 Gaat / 🙂 Goed / 🔥 Super
  - Tapping a mood: button scales to 1.05, gets accent border + soft indigo background, box-shadow
  - Other buttons scale down slightly to 0.97
- "Volgende →" button (white card style, accent text color)
- Button disabled (opacity 0.4) until mood selected

#### Step 2 — Doel van de dag (Daily Goal)
- Title: "Wat is jouw\nhoofdoel vandaag? 🎯"
- White card with multiline text input
- Placeholder: "Bijv. De client proposal afwerken en versturen..."
- Focus ring: accent border + soft glow on focus
- "Volgende →" button (always enabled, goal is optional)

#### Step 3 — Projecten (if `checkinShowProjects == true`)
- Title: "Verder werken\naan projecten? 📁"
- White card with list of active (non-archived) projects
- Each row: project emoji + name on left, custom checkbox on right
- Selected: accent border on row, accent filled checkbox
- "Volgende →" button

#### Step 4 — Taken plannen (Top tasks)
- Title: "Welke taken wil\nje eerst doen? ⚡"
- White card with 3 text input fields ("Taak 1...", "Taak 2...", "Taak 3...")
- These tasks are added to today's task list on completion
- "Start mijn dag 🚀" — full-width gradient button (accent → accent2)
- Below button: "Overslaan" link in small gray text

**On complete:**
- Dismiss with slide-down animation
- Save `CheckInEntry` to SwiftData
- If tasks were added in step 4, create Task objects with today's date and `timeBlock: .unscheduled`
- Show a subtle confetti burst (10–15 colored dots, spring physics)
- Increment streak if applicable

---

### 6.2 Today View

**Header:**
```
[Eyebrow]  Maandag, 9 maart          [Gear icon → Settings]
[Title]    Goedemorgen, [Name] 👋
```

Name comes from `@AppStorage("userName")`. If not set, just "Goedemorgen 👋".

**Hero Card (gradient):**
- Background: indigo → purple gradient, corner radius 22
- Left side: label "X van Y taken klaar" + large percentage (28pt, 800 weight, white)
- Right side: contextual emoji (🚀 <50%, ⚡ 50–80%, 🏆 >80%, 🎉 100%)
- Bottom: progress bar (white/20% background, white/90% fill, 6pt height, animated)
- Two decorative circles inside (white 10% opacity, blurred) at top-right and bottom-left

**Stats Row (3 cards, equal width):**
```
Card 1: 🔥 [streak]     "Dag streak"
Card 2: ⚡ [urgent count] "Urgent"
Card 3: 📁 [projects]    "Projecten"
```
White cards, corner radius 16, soft shadow. Value is large (20pt, 800 weight). Label is small caption. Staggered entrance animation (50ms delay between cards).

**Time Block Sections:**

Three sections: 🌅 Ochtend / ☀️ Middag / 🌙 Avond

Section header:
- Left: emoji + block name (13pt, 700 weight, uppercase, slight tracking)
- Right: "X/Y" badge (small pill, accent color text, light indigo background)

Each section only shows if it has tasks.

An "Unscheduled" section at bottom for tasks without a time.

**Task Cards:**

```
[CheckButton] [Task Title]                    [Priority Dot]
              [🕐 Time] [Tag Pill] [Tag Pill]
```

- White card, corner radius 18, soft shadow
- Left edge has a 3pt wide colored stripe matching priority color
- Check button: rounded square (9pt radius), 26×26pt
  - Unchecked: borderMedium border, white fill
  - Checked: green fill, green border, green glow shadow, white checkmark
  - Tap animation: spring scale 1.2 → 1.0
- Task title: 14pt, 600 weight. Strikethrough + opacity 0.45 when done
- Time: small gray text with clock emoji
- Tags: small colored pills (10pt, 700 weight, uppercase)
- Priority dot: 8×8pt circle, right side, color matches priority
- Tap on task body → Focus Mode
- Long press → context menu: Edit, Duplicate, Move to Project, Delete
- Swipe right → complete (green background, checkmark icon)
- Swipe left → delete (red background, trash icon) with confirmation
- Entrance: slide up + fade, staggered by 55ms per card

**FAB (Floating Action Button):**
- Bottom right, 50×50pt, corner radius 16
- Gradient background (accent → accent2)
- "+" icon, white, 24pt
- Glow shadow
- Subtle float animation (translateY ±3pt, 3s ease-in-out infinite)
- Tap → AddTaskSheet

---

### 6.3 All Tasks View

**Header:**
```
[Eyebrow] X taken
[Title]   Alle Taken
```

**Search bar:** Rounded, bgSubtle background, magnifying glass icon. Filters tasks in real time.

**Filter pills (horizontally scrollable):**
```
[Alle] [🔴 Hoog] [🟠 Middel] [🟢 Laag] [✅ Klaar] [📅 Vandaag] [📅 Overdue]
```

Active pill: accent background, white text, accent glow shadow, slight upward translate.

**Sort options:** Small "Sort" button top-right → action sheet with: Vervaldatum, Prioriteit, Aanmaakdatum, Alfabetisch.

**Task list:** Same TaskCard component as Today View. No time blocks — flat list grouped by nothing by default, or by project if "Group by project" is toggled.

**Empty state:** Centered illustration (simple SF Symbol art), "Geen taken" title, "Tik op + om je eerste taak toe te voegen" subtitle, + button.

---

### 6.4 Projects View

**Header:**
```
[Eyebrow] X actieve projecten
[Title]   Projecten
```

**Project Cards:**

```
[Emoji Icon]  [Project Name]              [›]
              [X van Y klaar]
[Progress bar — colored, thin]
```

- White card, corner radius 20, soft shadow
- Icon: 44×44pt rounded square (cornerRadius 14), colored background (project color at 10% opacity), emoji centered
- Progress bar: 5pt tall, bgBorder background, project-colored fill with subtle glow
- Long press → Archive, Edit, Delete
- Tap → ProjectDetailView

**ProjectDetailView:**
- Back button top-left
- Project emoji + name as large title
- Progress stats: total, completed, overdue
- Deadline if set (shown as colored badge: green/orange/red depending on urgency)
- Task list filtered to this project
- FAB to add task to project
- Edit project button top-right (pencil icon)

**New Project button:** Dashed border card at bottom, "+ Nieuw project" label with accent plus icon.

---

### 6.5 Focus Mode

**Trigger:** Tap on task title/body in any task list.

**Presentation:** Full-screen dark overlay. Dark gradient background (`#1a1a2e → #16213e`). Slides up with spring animation.

**Layout (centered):**
```
[✕ close button — top right, subtle]

[FOCUS MODE chip — small, indigo tinted]

[Task Title — large, white, centered, 24pt 800 weight]

[Priority · Time — small, dim white]

[Timer display — 56pt, 800 weight, white, tabular]
  MM:SS

[Timer label — "Pomodoro Timer", tiny caps, dim]

[Session dots — e.g. ● ● ○ ○ for 4 sessions, 2nd done]

[▶ Start / ⏸ Pause]    [↺ Reset]   ← two buttons side by side

[✓ Taak afvinken]  ← full-width green-tinted button below

[Next task preview — small card at bottom if there are more tasks]
```

**Pomodoro logic:**
- Default 25 minutes work / 5 minutes break / 15 minutes long break after 4 sessions
- Configurable in Settings
- When timer ends: haptic feedback (UINotificationFeedbackGenerator .success), optional notification sound
- Session dots: filled circles = completed sessions, empty = remaining (max 4 before long break)
- Background: subtle pulsing ring animation around timer display

**On "Taak afvinken":**
- Mark task as done in SwiftData
- Log `actualMinutes` based on time elapsed
- Spring-animate the task away
- Show "Goed gedaan! 🎉" message for 1.5 seconds
- If more tasks: show next task with slide-in animation
- If no more tasks: show completion celebration

---

### 6.6 Stats & Insights View

**Header:**
```
[Eyebrow] Week van 3–9 maart
[Title]   Inzichten 📊
```

**Weekly completion chart:**
- Bar chart using Swift Charts
- X-axis: Mon–Sun abbreviated
- Y-axis: number of completed tasks
- Bars: accent color, corner radius 4 on top
- Today's bar: gradient (accent → accent2) + slightly taller scale
- Tap a bar → show tooltip with exact count

**Streak Section:**
- Large orange flame emoji + streak number (32pt, 800 weight, #D97706)
- "Dagen streak" label
- "Langste streak: X dagen" subtitle
- Calendar grid (last 30 days): small colored squares — green if tasks completed, gray if not, today outlined in accent

**Weekly Summary Cards (2×2 grid):**
```
✅ Voltooid     🔥 Streak
📁 Projecten    ⏱ Focus tijd
```

**Category breakdown:**
- Horizontal stacked bar showing tasks per tag
- Each tag colored with its own color

**Productivity insights (smart text):**
Generated based on data patterns:
- "Je bent het meest productief op dinsdag 📈"
- "Je hebt 3 taken afgerond vóór 10:00 — goedemorgen routine werkt! 🌅"
- "Hoog-prioriteit taken duren gemiddeld 45 minuten 💡"

---

### 6.7 Settings View

**Header:**
```
[Title] Instellingen ⚙️
```

**Streak badge at top:**
White/warm yellow card: 🔥 [X] dagen streak · "Blijf consistent!"

**Sections:**

#### Ochtend Check-in
| Row | Type | Detail |
|-----|------|--------|
| Check-in inschakelen | Toggle | Dagelijkse ochtend vragenlijst |
| Tijdstip | Time picker row (3 preset pills) | 07:30 / 08:00 / 08:30 / 09:00 |
| Stemming tonen | Toggle | Mood vraag in check-in |
| Projecten tonen | Toggle | Vraag welke projecten vandaag |

#### Meldingen
| Row | Type | Detail |
|-----|------|--------|
| Taak reminders | Toggle | Push notificaties voor taken |
| Dagelijkse samenvatting | Toggle | Elke avond overzicht |
| Tijd samenvatting | Time picker | 19:00 / 20:00 / 21:00 |
| Overdue reminders | Toggle | Herinnering voor verlopen taken |

#### Focus & Pomodoro
| Row | Type | Detail |
|-----|------|--------|
| Focus duur | Stepper (5–60 min) | Standaard: 25 min |
| Korte pauze | Stepper | Standaard: 5 min |
| Lange pauze | Stepper | Na 4 sessies: 15 min |
| Auto-start pauze | Toggle | Automatisch doorgaan |

#### Uiterlijk
| Row | Type | Detail |
|-----|------|--------|
| Thema | Segment (Systeem/Licht/Donker) | |
| Naam | Text input | Naam voor begroeting |
| Taal | Picker (NL / EN) | |

#### Data
| Row | Type | Detail |
|-----|------|--------|
| iCloud Sync | Toggle (grayed, "Binnenkort") | v1.1 |
| Exporteer taken | Button | Export as CSV |
| Reset alle data | Button (destructive) | Confirmation alert |

#### Over
| Row | Type | Detail |
|-----|------|--------|
| Over TaakFlow | → detail | Versie, credits |
| Privacy Policy | → Safari | |
| Vancoillie Studio | → Safari | vancoilliestudio.be |

**Toggle style:**
- Custom toggle: 46×26pt pill shape
- On: accent color background, knob slides right with spring animation (cubic-bezier 0.34,1.56,0.64,1)
- Off: borderMedium background, knob slides left
- Knob: white circle, subtle drop shadow, 20×20pt
- Transition duration: 0.3s

---

### 6.8 Add / Edit Task Sheet

**Presentation:** Bottom sheet, slides up with spring animation. Corner radius 28pt on top corners. White background.

**Handle:** 36×4pt pill, borderMedium color, centered at top.

**Title:** "Nieuwe Taak ✏️" or "Taak bewerken ✏️" (20pt, 800 weight)

**Fields:**

1. **Title input** (required)
   - Large text input, bgSubtle background, 14pt radius
   - Placeholder: "Wat moet er gedaan worden?"
   - Focus: accent border + soft glow

2. **Notes** (optional, expandable)
   - Collapsed by default, tap "Notitie toevoegen..." to expand
   - Multiline, min 3 lines

3. **Priority selector** (4 buttons in a row)
   - None / Laag / Middel / Hoog
   - Selected: colored background + glow + translateY(-2pt)

4. **Due date** (date + optional time)
   - Row with calendar icon, "Vervaldatum" label
   - Tap → inline date picker expands below with animation
   - Toggle "Tijd instellen" → time picker appears
   - "Herinnering" toggle (only visible when time is set)

5. **Time block** (4 pills: Ochtend / Middag / Avond / Ongepland)
   - Auto-selected based on due time if set

6. **Tags** (multi-select pills, horizontally scrollable)
   - Existing tags shown as pills
   - "+ Nieuwe tag" pill at end → inline tag creation

7. **Project** (optional)
   - Picker showing all active projects with emoji
   - "Geen project" option at top

8. **Subtasks** (optional)
   - Collapsible section "Subtaken"
   - Add subtask inline with small + button
   - Each subtask: checkbox + text input
   - Reorderable (drag handle)

9. **Estimated time** (optional)
   - "Schatting:" + stepper (15, 30, 45, 60, 90 min)

**Submit button:**
- "Taak toevoegen" / "Opslaan"
- Full width, gradient background when title is filled
- Gray/disabled when title is empty
- Spring scale animation on tap

---

### 6.9 Add / Edit Project Sheet

**Presentation:** Bottom sheet, same style as task sheet.

**Fields:**
1. **Name** — text input
2. **Emoji picker** — grid of 24 common emojis + custom input
3. **Color picker** — 8 preset color dots (swatches), tap to select
4. **Deadline** — optional date picker
5. **Notes** — optional multiline

---

### 6.10 Onboarding Flow

3 full-screen pages with a page indicator and "Volgende" / "Begin" buttons.

**Page 1 — Welcome**
- Large app icon (120×120pt, rounded)
- Title: "Welkom bij TaakFlow"
- Subtitle: "Jouw taken. Jouw flow."
- Animated gradient background (soft, moving)

**Page 2 — Features**
- 3 feature rows with SF Symbol icons:
  - "☀️ Ochtend Check-in" — Plan je dag elke ochtend in 2 minuten
  - "🎯 Focus Mode" — Werk geconcentreerd met een Pomodoro timer
  - "📊 Inzichten" — Zie je productiviteit groeien week na week

**Page 3 — Personalize**
- "Hoe mogen we je noemen?" text input
- "Hoe laat wil je je check-in?" time picker (preset pills)
- "Meldingen inschakelen?" toggle
- "Begin →" gradient button

---

## 7. ANIMATIONS & INTERACTIONS

### 7.1 Spring Animation Standard

All interactive transitions use:
```swift
.animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: state)

// For snappier micro-interactions (button taps, checkbox):
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: state)

// For sheet presentations:
.animation(.spring(response: 0.45, dampingFraction: 0.75), value: isShowing)
```

### 7.2 Specific Animations

**Task card entrance (staggered list):**
```swift
.transition(.asymmetric(
    insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.97)),
    removal: .move(edge: .leading).combined(with: .opacity)
))
.animation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.055), value: appeared)
```

**Checkbox completion:**
```swift
// Scale spring: 1.0 → 1.2 → 1.0
// Color fill animates in
// Glow shadow appears
withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { isDone.toggle() }
```

**Filter pill selection:**
```swift
// translateY: 0 → -2pt
// background fade: bgSubtle → accent
// shadow appears with spring
```

**Progress bar fill:**
```swift
.animation(.spring(response: 0.9, dampingFraction: 0.7).delay(0.2), value: percentage)
```

**FAB float:**
```swift
// Continuous animation:
// translateY: 0 → -3pt → 0, duration 3s, ease-in-out, infinite
// Shadow intensity pulses in sync
```

**Sheet slide up:**
```swift
.transition(.move(edge: .bottom))
.animation(.spring(response: 0.45, dampingFraction: 0.78))
```

**Focus mode entrance:**
```swift
// Full screen dark overlay fades in (opacity 0→1, 0.3s)
// Content slides up (translateY 30 → 0) with spring
```

**Morning check-in step transition:**
```swift
// Current step: slides left + fades out
// Next step: slides in from right + fades in
// Step dots animate width with spring
```

**Task completion confetti (on check-in complete):**
```swift
// 12 colored circles explode from center
// Random velocities, gravity applied
// Fade out over 1.5s
// Uses TimelineView or Canvas
```

**Swipe to complete (task card):**
```swift
// SwiftUI swipeActions: leading → complete (green, checkmark)
// Trailing → delete (red, trash) with confirmation
```

**Long press context menu:**
```swift
.contextMenu {
    Button("Bewerken") { ... }
    Button("Focus Mode") { ... }
    Button("Dupliceer") { ... }
    Menu("Verplaats naar project") { ... }
    Divider()
    Button("Verwijder", role: .destructive) { ... }
}
```

### 7.3 Haptic Feedback

```swift
// Task completed:
UINotificationFeedbackGenerator().notificationOccurred(.success)

// Task deleted:
UINotificationFeedbackGenerator().notificationOccurred(.warning)

// Button tap (primary actions):
UIImpactFeedbackGenerator(style: .medium).impactOccurred()

// Toggle:
UIImpactFeedbackGenerator(style: .light).impactOccurred()

// Error / validation:
UINotificationFeedbackGenerator().notificationOccurred(.error)

// Pomodoro timer end:
UINotificationFeedbackGenerator().notificationOccurred(.success)
// + vibration pattern for emphasis
```

---

## 8. NOTIFICATIONS

### 8.1 Types

| ID | Trigger | Content |
|----|---------|---------|
| `checkin-daily` | Every day at checkinTime | "☀️ Goedemorgen! Klaar voor je check-in?" |
| `task-reminder` | Task dueTime - 10 minutes | "[Task title] is over 10 minuten!" |
| `task-overdue` | Task dueTime + 1 hour (if not done) | "[Task title] is verlopen. Nu afwerken?" |
| `daily-summary` | Every day at dailySummaryTime | "Je hebt X/Y taken afgerond vandaag. Morgen wacht [N] taken." |
| `streak-risk` | At 21:00 if no tasks completed | "🔥 Je streak staat op het spel! Rond een taak af." |
| `pomodoro-end` | After focus timer | "⏱ Pomodoro klaar! Neem een pauze." |

### 8.2 Implementation

```swift
class NotificationService {
    func scheduleCheckIn(at time: DateComponents) { ... }
    func scheduleTaskReminder(for task: Task) { ... }
    func scheduleDailySummary(at time: DateComponents) { ... }
    func scheduleStreakRisk() { ... }
    func cancelNotification(id: String) { ... }
    func cancelAllTaskNotifications() { ... }
    func requestPermission() async -> Bool { ... }
}
```

Notifications should be re-scheduled whenever tasks or settings change. Use `UNUserNotificationCenter.current().pendingNotificationRequests()` to avoid duplicates.

---

## 9. WIDGETS

### 9.1 Today Widget (Small + Medium)

**Small:**
- Gradient background (accent → accent2)
- "Vandaag" label
- Large percentage complete
- Compact progress bar

**Medium:**
- Same header
- Shows next 3 uncompleted tasks
- Each task: priority dot + title + time

### 9.2 Streak Widget (Small)

- Warm yellow/orange background
- 🔥 emoji large
- Streak number huge
- "Dag streak" label

### 9.3 Quick Add Widget (Medium, interactive — iOS 17)

- Input field (interactive widget)
- "Taak toevoegen" button
- Opens AddTaskSheet on tap

### 9.4 Implementation

```swift
struct TodayWidgetEntry: TimelineEntry {
    let date: Date
    let completedCount: Int
    let totalCount: Int
    let nextTasks: [WidgetTask]
    let streak: Int
}

// Use App Groups for shared SwiftData access:
// group.be.vancoilliestudio.taakflow
```

---

## 10. SHORTCUTS & SIRI

### 10.1 App Intents

```swift
struct AddTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Taak toevoegen"
    @Parameter(title: "Taak") var title: String
    @Parameter(title: "Prioriteit") var priority: Priority?
    func perform() async throws -> some IntentResult { ... }
}

struct GetTodayTasksIntent: AppIntent {
    static var title: LocalizedStringResource = "Taken van vandaag"
    func perform() async throws -> some IntentResult & ReturnsValue<[String]> { ... }
}

struct StartFocusIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Focus Mode"
    @Parameter(title: "Taak") var taskTitle: String?
    func perform() async throws -> some IntentResult { ... }
}
```

### 10.2 Spotlight Search

Register tasks and projects with `CSSearchableItem` so they appear in Spotlight.

---

## 11. ICLOUD SYNC (v1.1)

- Use CloudKit with `NSPersistentCloudKitContainer`
- Sync is opt-in (toggle in Settings)
- Conflict resolution: last-write-wins with timestamp
- Works across iPhone and iPad
- Offline-first: all changes work locally, sync when online

---

## 12. ACCESSIBILITY

- All interactive elements have `.accessibilityLabel` and `.accessibilityHint`
- Custom checkboxes: `.accessibilityRole(.button)`, `.accessibilityValue(isDone ? "Afgevinkt" : "Niet afgevinkt")`
- Support Dynamic Type: all fonts use relative sizing
- Support VoiceOver navigation with logical reading order
- Minimum tap target: 44×44pt for all buttons
- Color is never the only indicator (priority also has text label)
- Reduce Motion: disable spring animations, use simple fades instead
  ```swift
  @Environment(\.accessibilityReduceMotion) var reduceMotion
  ```
- Increase Contrast: use darker border colors, stronger shadows

---

## 13. LOCALIZATION

Support Dutch (nl) and English (en). Dutch is the default.

**Key strings to localize:**
```
"today_greeting_morning" = "Goedemorgen, %@ 👋" / "Good morning, %@ 👋"
"today_greeting_afternoon" = "Goedemiddag, %@ ☀️" / "Good afternoon, %@ ☀️"
"today_greeting_evening" = "Goedeavond, %@ 🌙" / "Good evening, %@ 🌙"
"tab_today" = "Vandaag" / "Today"
"tab_tasks" = "Taken" / "Tasks"
"tab_projects" = "Projecten" / "Projects"
"tab_insights" = "Inzichten" / "Insights"
"priority_high" = "Hoog" / "High"
"priority_medium" = "Middel" / "Medium"
"priority_low" = "Laag" / "Low"
"priority_none" = "Geen" / "None"
```

All UI strings go in `Localizable.strings`. Never hardcode Dutch/English strings in views.

---

## 14. APP ICON & ASSETS

### App Icon

- Background: white or very light indigo (#F0F2FF)
- Symbol: A stylized checkmark or flow-like shape in the indigo → purple gradient
- Style: Clean, minimal, rounded square (standard iOS shape)
- Size: 1024×1024pt master, all required sizes generated

### Launch Screen

- White background
- Centered app icon (120×120pt)
- App name below in Plus Jakarta Sans 700
- Fades into the app

### SF Symbols used

```swift
// Tab bar
"sun.max.fill" / "sun.max"
"checkmark.square.fill" / "checkmark.square"
"folder.fill" / "folder"
"chart.bar.fill" / "chart.bar"
"gearshape.fill" / "gearshape"

// Actions
"plus" (FAB)
"pencil" (edit)
"trash" (delete)
"doc.on.doc" (duplicate)
"magnifyingglass" (search)
"arrow.left" (back)
"xmark" (close)
"checkmark" (done)
"flame.fill" (streak, orange)
"bolt.fill" (urgent, yellow)
"calendar" (due date)
"clock" (time)
"bell" (notifications)
"moon.fill" (dark mode)
"globe" (language)
"person.fill" (profile)
"icloud" (sync)
"square.and.arrow.up" (export)
"play.fill" / "pause.fill" (timer)
"arrow.counterclockwise" (reset)
```

---

## 15. PRIVACY & DATA

- **No analytics** of any kind
- **No third-party SDKs** (no Firebase, no Crashlytics, etc.)
- **All data local** by default (SwiftData on device)
- **iCloud Sync** is opt-in and only syncs to user's own iCloud account
- **No user accounts** required
- **Minimal permissions:** Only Notifications (requested at onboarding)
- **Privacy manifest** (`PrivacyInfo.xcprivacy`): declare local storage, no tracking

---

## 16. TESTING

### Unit Tests

```swift
// TaskViewModelTests
func testAddTask() { ... }
func testCompleteTask() { ... }
func testStreakIncrement() { ... }
func testTimeBlockAssignment() { ... }
func testRecurrenceGeneration() { ... }

// NotificationServiceTests
func testScheduleReminder() { ... }
func testCancelNotification() { ... }
```

### UI Tests

```swift
func testTodayViewLoads() { ... }
func testAddTaskFlow() { ... }
func testCheckInFlow() { ... }
func testFocusModeTimerStartsAndStops() { ... }
func testSettingsToggle() { ... }
```

### Preview Data

Create a `PreviewData.swift` with sample tasks, projects, and tags for SwiftUI Previews.

---

## 17. CLAUDE CODE INSTRUCTIONS

> This section is specifically for Claude Code. Follow these instructions carefully when generating this app.

### Step-by-step build order

1. **Set up project** — New Xcode project, SwiftUI, SwiftData, iOS 17+, bundle ID `be.vancoilliestudio.taakflow`
2. **Add Plus Jakarta Sans** — Download from Google Fonts, add to project, register in Info.plist
3. **Create Color+Hex extension** — All colors as hex strings
4. **Create all SwiftData models** — Task, Project, Tag, CheckInEntry
5. **Create AppSettings** — All @AppStorage keys
6. **Build shared components** — TaskCardView, PriorityDot, TagPill, CheckButton, GradientHeroCard, FilterPill, SectionHeader, Toggle
7. **Build TodayView** — Hero card, stats row, time block sections
8. **Build AllTasksView** — Search, filters, task list
9. **Build ProjectsView + ProjectDetailView**
10. **Build AddTaskSheet + EditTaskSheet**
11. **Build Morning Check-in flow** (4 steps)
12. **Build Focus Mode + Pomodoro timer**
13. **Build Stats/Insights view** — Swift Charts
14. **Build Settings view** — All sections
15. **Build Onboarding** — 3 screens
16. **Implement NotificationService**
17. **Implement StreakService**
18. **Add Widgets** (separate Widget Extension target)
19. **Add App Intents** (Siri/Shortcuts)
20. **Write tests**
21. **Add localization** (NL + EN)
22. **Polish animations** — Apply spring animations everywhere per spec

### Design rules Claude Code must follow

1. **ALWAYS use Plus Jakarta Sans** for all text. Never SF Pro, never system font for display text.
2. **NEVER use a solid color as a card background** — cards are always white, the screen bg is #F5F6FA.
3. **The hero gradient card appears ONCE per major screen**, never twice on the same screen.
4. **All spring animations** use `response: 0.4, dampingFraction: 0.7` or closer variants. Never linear or ease-in-out for interactive elements.
5. **Stagger list entrance animations** by 55ms per item.
6. **All primary buttons** are gradient (accent → accent2) with glow shadow.
7. **FAB** is always gradient with a pulsing float animation.
8. **Priority** is shown as a small colored dot (8pt) on the right side of task cards AND as a 3pt left-edge stripe.
9. **Tags** are always small rounded pills with the tag's color as text and 10% opacity background.
10. **Section headers** are uppercase, small, 700 weight, with a count badge on the right.
11. **The check button** is a rounded square (not circle), 26×26pt, with spring scale animation on tap.
12. **Sheets** have a 36×4pt drag handle at top, corner radius 28 on top corners only.
13. **Empty states** have a centered SF Symbol, a title, and a subtitle. Never just an empty list.
14. **All destructive actions** require confirmation (Alert or destructive button style).
15. **Haptic feedback** on every state change (completion, deletion, toggle, error).

### Code quality rules

1. Extract every reusable UI element into its own View struct in the Shared/ folder.
2. No business logic in Views — all logic goes in ViewModels.
3. Use `@Observable` (not ObservableObject) for all ViewModels.
4. Use `#Preview` macros with `PreviewData` for every View.
5. All strings in Localizable.strings — no hardcoded NL/EN strings.
6. Every SwiftData query in a ViewModel, never directly in a View.
7. Handle all async operations with `async/await`, never callbacks.
8. Add `// MARK: -` comments to separate sections in files longer than 100 lines.

### File naming

- Views: `[Screen]View.swift` or `[Component]View.swift`
- Sheets: `[Action]Sheet.swift`
- ViewModels: `[Domain]ViewModel.swift`
- Services: `[Domain]Service.swift`
- Extensions: `[Type]+[Feature].swift`

### SwiftData tips

```swift
// Correct way to fetch tasks for today:
@Query(filter: #Predicate<Task> { task in
    task.dueDate != nil &&
    Calendar.current.isDateInToday(task.dueDate!)
}, sort: \.dueTime) var todayTasks: [Task]

// Don't forget to inject modelContainer in App:
.modelContainer(for: [Task.self, Project.self, Tag.self, CheckInEntry.self])
```

### Known pitfalls to avoid

- SwiftData relationships: always set both sides of a relationship when creating objects
- `@Query` with complex predicates: test on device, not just Simulator
- `UNUserNotificationCenter`: always check authorization before scheduling
- Spring animations: don't nest animated views inside `List` — use `LazyVStack` + `ScrollView` for full animation control
- Plus Jakarta Sans: register all weights in Info.plist under `UIAppFonts`
- Widget data: use App Groups container for shared SwiftData, not the main app container
- Pomodoro timer: use `Timer.publish` combined with `onReceive`, pause with `.autoconnect()` / cancelling the subscription

---

## APPENDIX A — Sample Data for Previews

```swift
// PreviewData.swift
struct PreviewData {
    static let tag1 = Tag(name: "Work", colorHex: "#5B6EF5")
    static let tag2 = Tag(name: "Personal", colorHex: "#7C3AED")
    static let tag3 = Tag(name: "Urgent", colorHex: "#EF4444")

    static let project1 = Project(name: "Client Work", emoji: "💼", colorHex: "#5B6EF5")
    static let project2 = Project(name: "Admin", emoji: "🗂️", colorHex: "#F97316")

    static let task1: Task = {
        let t = Task(title: "Client proposal afwerken")
        t.priority = .high
        t.dueDate = Date()
        t.dueTime = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date())
        t.timeBlock = .morning
        t.tags = [tag1]
        t.project = project1
        return t
    }()

    static let task2: Task = {
        let t = Task(title: "Website designs reviewen")
        t.priority = .medium
        t.dueDate = Date()
        t.dueTime = Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())
        t.timeBlock = .afternoon
        t.tags = [tag1, tag3]
        t.project = project1
        return t
    }()

    static let task3: Task = {
        let t = Task(title: "Sporten")
        t.priority = .low
        t.dueDate = Date()
        t.timeBlock = .morning
        t.isDone = true
        t.tags = [tag2]
        return t
    }()

    static var sampleTasks: [Task] { [task1, task2, task3] }
}
```

---

## APPENDIX B — Color Extension

```swift
// Color+Hex.swift
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

---

## APPENDIX C — Spring Animation Extension

```swift
// View+SpringTransition.swift
import SwiftUI

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
}

extension View {
    func cardEntrance(delay: Double = 0) -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: .bottom)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.97)),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(
            .spring(response: 0.4, dampingFraction: 0.7).delay(delay),
            value: true
        )
    }
}
```

---

*TaakFlow README — Vancoillie Studio · be.vancoilliestudio.taakflow*
*Generated for Claude Code — follow every section precisely for a production-quality result.*
