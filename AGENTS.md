# ChangelogKit — Project Context

This file is the source of truth for project-level context — structure, public API surface, build & branching conventions, implementation notes. It is consumed both by humans browsing the repo and by AI coding assistants (Claude Code, Codex, etc.) via the `AGENTS.md` convention.

## Overview

SwiftUI package for displaying "What's New" / changelog screens in iOS apps. Zero external dependencies.

- **Platform**: iOS 17+
- **Swift tools**: 5.9
- **Default localization**: English (`en`), Italian (`it`) also bundled
- **Latest released version**: see git tags on `main`

## Project Structure

```
Package.swift
Sources/ChangelogKit/
    Changelog.swift                          — Changelog + Feature models (Codable, Hashable, Identifiable)
    ChangelogView.swift                      — SwiftUI view, Style system, ViewModifier presenters
    ChangelogsCollectionProvider.swift        — Protocol for managing changelog collections + UserDefaults tracking
    Extensions/
        Bundle+ChangelogKit.swift            — internal Bundle.appVersion helper (reads CFBundleShortVersionString)
        UserDefaults+ChangelogKit.swift      — internal UserDefaults suite "ChangelogKit" + keys
        View+ChangelogKit.swift              — public View extensions: .sheet() and .showCurrentChangelogIfNeeded()
    Resources/
        Base.lproj/Localizable.strings
        en.lproj/Localizable.strings
        it.lproj/Localizable.strings
Tests/ChangelogKitTests/
    ChangelogKitTests.swift                  — placeholder, test coverage is a good first contribution
```

## Public API

### Models

```swift
// Main changelog for a version
Changelog(title: String? = nil, version: String, features: [Feature])

// A single feature entry
Changelog.Feature(symbol: String, title: String, description: String, color: Color? = nil, pinBehavior: PinBehavior = .never)
// - symbol: SF Symbol name
// - color: stored as RGBA CGFloat internally to support Codable
// - pinBehavior: controls visibility in the pinned highlights section across versions
```

#### `Changelog.Feature.PinBehavior`

```swift
enum PinBehavior {
    case never              // never shown in highlights (default)
    case untilPatchChanges  // shown while major.minor.patch matches the feature's changelog version
    case untilMinorChanges  // shown while major.minor matches — survives hotfix updates
    case untilMajorChanges  // shown while major matches — survives all minor/patch updates
    case always             // always shown until explicitly removed by the developer
}
```

### View

```swift
ChangelogView(
    changelog: Changelog,
    pinnedFeatures: [Changelog.Feature] = [],  // from ChangelogsCollectionProvider.pinnedFeatures
    style: ChangelogView.Style = .init(),
    onDismiss: (() -> Void)? = nil
)
// or builder style:
ChangelogView(changelog: changelog).onDismiss { ... }
```

The view title is always the generic localized "What's new" (not version-specific).
The version appears in the section header label ("VERSION 1.2.1").
When `pinnedFeatures` is empty, the highlights section is hidden entirely.

### Style system

```swift
ChangelogView.Style(
    view: .init(
        spacingBetweenSections: 24,       // spacing between highlights and current version sections
        spacingBetweenHeaderAndCard: 8,   // spacing between a section label and its card
        spacingBetweenFeatures: 8,        // spacing between individual feature cards
        contentPadding: 12                // internal padding of each feature row
    ),
    title: .init(font: .largeTitle.weight(.bold), color: Color(UIColor.label)),
    features: .init(
        titleFont: .headline,
        descriptionFont: .subheadline,
        titleTextColor: Color(UIColor.label),
        descriptionTextColor: Color(UIColor.secondaryLabel)
    ),
    primaryAction: .init(
        title: nil,             // nil = localized "Continue"
        hidden: false,
        font: .title3.weight(.bold),
        useCapsuleAsShape: true,
        cornerRadius: 14,
        backgroundColor: .accentColor,
        backgroundGradient: nil,
        textColor: .white
    ),
    card: .init(
        backgroundColor: Color(UIColor.secondarySystemBackground),
        cornerRadius: 16,
        shadowColor: .clear,
        shadowRadius: 0,
        shadowOffset: .zero
    ),
    featureIcon: .init(
        size: 24,
        containerShape: .roundedSquare(radius: 10),  // .circle / .roundedSquare(radius:) / .none
        containerSize: 44,
        containerColor: Color(UIColor.tertiarySystemBackground)
    ),
    sectionHeader: .init(
        font: .caption.weight(.semibold),
        color: Color(UIColor.secondaryLabel),
        uppercased: true,
        pinnedTitle: nil,            // nil = localized "Highlights"
        currentVersionTitle: nil     // nil = automatic "Version X.Y.Z"
    ),
    featureDivider: .init(
        visible: true,
        color: Color(UIColor.separator)
    )
)
```

### Protocol

```swift
protocol ChangelogsCollectionProvider {
    var changelogs: [Changelog] { get }
}
// Default extension provides (all public):
// - current: Changelog?                                   ← changelog matching CFBundleShortVersionString
// - isCurrentVersionAlreadyDisplayed: Bool
// - shouldCurrentChangelogBeDisplayed: Bool
// - pinnedFeatures: [Changelog.Feature]                   features to pass to ChangelogView
// - markCurrentVersionChangelogAsDisplayed()
// - markChangelogAsDisplayed(_ changelog:)
// - markChangelogAsNotDisplayed(_ changelog:)
// - resetDisplayedChangelogs()
```

### View modifiers

```swift
// Manual — show a specific changelog in a sheet
.sheet(isPresented: $show, changelog: myChangelog, style: style, onDismiss: { })

// Automatic — show current version's changelog once per install, tracked via UserDefaults
// Also automatically passes pinnedFeatures from the provider
.showCurrentChangelogIfNeeded(isPresented: $show, provider: myProvider, debug: false, onDismiss: { })
```

## Build & Test

```bash
swift build
swift test
```

## Branching Model (git-flow)

- `main` — release branch, version tags live here
- `develop` — integration branch, all PRs target this
- `release/X.Y` — cut from `develop`, merged into both `main` and `develop` on release
- `hotfix/X.Y.Z` — cut from `main` for urgent fixes, merged into both `main` and `develop`

## Key Implementation Notes

- Version tracking uses `UserDefaults(suiteName: "ChangelogKit") ?? .standard` under key `displayedChangelogVersions` (stored as `[String]`)
- `Bundle.appVersion` reads `CFBundleShortVersionString` from `Bundle.main` — returns `""` in test targets (safe, `current` will return `nil`, `pinnedFeatures` will return `[]`)
- `ChangelogView.Style.View` is a nested struct that shadows `SwiftUI.View` — keep this as-is to avoid API breakage
- The `.sheet(isPresented:changelog:)` modifier shadows SwiftUI's own `.sheet()` — distinguishable by the `changelog:` label
- Localized strings must use `bundle: .module` for package resources
- `Bundle.module` cannot be used as a default argument value — use `nil` as sentinel and resolve inside `init` (see `SectionHeader.init`)
- `Feature.color` is computed over private RGBA `CGFloat` fields (sentinel `-1` = no color) to satisfy `Codable` — `Color` itself is not `Codable`
- `Feature.pinBehavior` is evaluated by `ChangelogsCollectionProvider.pinnedFeatures` using `SemVer` (internal struct) — supports `major.minor` and `major.minor.patch`, missing components default to `0`
- `ProviderChangelogViewPresenter` passes `pinnedFeatures` from the provider directly into `ChangelogView`
- `ProviderChangelogViewPresenter` does NOT pass `onDismiss` into `ChangelogView` — the sheet's own `onDismiss:` parameter handles it to avoid double-fire
