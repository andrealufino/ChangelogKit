//
//  ChangelogsCollectionProvider.swift
//
//
//  Created by Andrea Mario Lufino on 02/01/24.
//

import Foundation


// MARK: - ChangelogsCollectionProvider

/// A type that provides a collection of changelogs and manages their display state.
///
/// Adopt this protocol to integrate ChangelogKit into your app. The only required
/// property is `changelogs` — all tracking logic is provided automatically via
/// default protocol extensions.
///
/// ```swift
/// struct MyChangelogsProvider: ChangelogsCollectionProvider {
///     var changelogs: [Changelog] {
///         [
///             Changelog(version: "2.0", features: [...]),
///             Changelog(version: "1.5", features: [...]),
///         ]
///     }
/// }
/// ```
///
/// Use the `.showCurrentChangelogIfNeeded(isPresented:provider:)` view modifier
/// to present the changelog automatically when the user updates to a new version.
public protocol ChangelogsCollectionProvider {
    /// The ordered collection of changelogs, typically from newest to oldest.
    var changelogs: [Changelog] { get }
}


// MARK: - Internal

extension ChangelogsCollectionProvider {

    /// The set of version strings that have already been displayed to the user,
    /// persisted in the ChangelogKit UserDefaults suite.
    private var displayedChangelogVersions: [String] {
        UserDefaults.changelogKit.value(forKey: UserDefaults.ChangelogKitKeys.displayedChangelogVersionsKey) as? [String] ?? []
    }

    /// The changelog whose version matches the current app version, or `nil` if
    /// no matching changelog exists or the app version cannot be determined.
    public var current: Changelog? {
        changelogs.first { $0.version == Bundle.appVersion }
    }

    /// Marks the changelog for the current app version as displayed.
    ///
    /// Has no effect if no changelog matches the current version.
    public func markCurrentVersionChangelogAsDisplayed() {
        if let current {
            markChangelogAsDisplayed(current)
        }
    }

    /// Marks the given changelog as displayed by persisting its version string.
    ///
    /// - Parameter changelog: The changelog to mark as displayed.
    func markChangelogAsDisplayed(_ changelog: Changelog) {
        var changelogs = Set(displayedChangelogVersions)
        if changelogs.insert(changelog.version).inserted {
            UserDefaults.changelogKit.setValue(Array(changelogs), forKey: UserDefaults.ChangelogKitKeys.displayedChangelogVersionsKey)
        }
    }

    /// Returns `true` if the given version string has already been displayed.
    ///
    /// - Parameter version: The version string to check.
    func isVersionAlreadyDisplayed(_ version: String) -> Bool {
        displayedChangelogVersions.contains(version)
    }

    /// Returns `true` if the given changelog has already been displayed.
    ///
    /// - Parameter changelog: The changelog to check.
    func isChangelogAlreadyDisplayed(_ changelog: Changelog) -> Bool {
        isVersionAlreadyDisplayed(changelog.version)
    }

    /// Returns `true` if the given version string has not yet been displayed.
    ///
    /// - Parameter version: The version string to check.
    func shouldVersionBeDisplayed(_ version: String) -> Bool {
        !isVersionAlreadyDisplayed(version)
    }

    /// Returns `true` if the given changelog has not yet been displayed.
    ///
    /// - Parameter changelog: The changelog to check.
    func shouldChangelogBeDisplayed(_ changelog: Changelog) -> Bool {
        !isChangelogAlreadyDisplayed(changelog)
    }

    /// Returns `true` if the changelog for the current app version has already been displayed.
    ///
    /// Returns `false` when no changelog matches the current version.
    func isCurrentChangelogAlreadyDisplayed() -> Bool {
        if let current {
            return isChangelogAlreadyDisplayed(current)
        }
        return false
    }
}


// MARK: - Public

public extension ChangelogsCollectionProvider {
    
    /// Check if changelog for current version has already been displayed.
    var isCurrentVersionAlreadyDisplayed: Bool {
        isCurrentChangelogAlreadyDisplayed()
    }
    
    /// Check if changelog for current version should be displayed or not.
    var shouldCurrentChangelogBeDisplayed: Bool {
        guard current != nil else { return false }
        return !isCurrentChangelogAlreadyDisplayed()
    }
    
    /// Returns the features from past changelog versions that should appear in the
    /// pinned highlights section, based on each feature's `pinBehavior` and the
    /// current app version.
    ///
    /// Features are collected from all changelogs whose version differs from the
    /// current app version. A feature is included when its `pinBehavior` condition
    /// is still satisfied relative to `Bundle.appVersion`.
    ///
    /// Returns an empty array when the app version cannot be determined (e.g. in
    /// test targets where `Bundle.main` has no `CFBundleShortVersionString`).
    var pinnedFeatures: [Changelog.Feature] {
        guard !Bundle.appVersion.isEmpty else { return [] }
        let current = SemVer(Bundle.appVersion)
        return changelogs
            .filter { $0.version != Bundle.appVersion }
            .flatMap { changelog -> [Changelog.Feature] in
                let featureVersion = SemVer(changelog.version)
                return changelog.features.filter { feature in
                    switch feature.pinBehavior {
                    case .never:
                        return false
                    case .always:
                        return true
                    case .untilPatchChanges:
                        return current.major == featureVersion.major
                            && current.minor == featureVersion.minor
                            && current.patch == featureVersion.patch
                    case .untilMinorChanges:
                        return current.major == featureVersion.major
                            && current.minor == featureVersion.minor
                    case .untilMajorChanges:
                        return current.major == featureVersion.major
                    }
                }
            }
    }

    /// Reset all the displayed version.
    /// > Warning: This is a destructive method, use it only if really needed.
    func resetDisplayedChangelogs() {
        UserDefaults.changelogKit.removeObject(forKey: UserDefaults.ChangelogKitKeys.displayedChangelogVersionsKey)
    }
    
    /// Mark the passed changelog as not displayed, removing it from the already displayed changelogs.
    /// - Parameter changelog: The changelog to set as not displayed.
    func markChangelogAsNotDisplayed(_ changelog: Changelog) {
        var changelogs = Set(displayedChangelogVersions)
        if changelogs.remove(changelog.version) != nil {
            // Set the array again only if the element was actually removed.
            // This will skip if element is not present in the array.
            UserDefaults.changelogKit.setValue(Array(changelogs), forKey: UserDefaults.ChangelogKitKeys.displayedChangelogVersionsKey)
        }
    }
}
