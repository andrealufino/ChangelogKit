//
//  ChangelogsCollectionProvider.swift
//
//
//  Created by Andrea Mario Lufino on 02/01/24.
//

import Foundation


// MARK: - ChangelogsCollectionProvider

public protocol ChangelogsCollectionProvider {
    var changelogs: [Changelog] { get }
}


// MARK: - Internal methods

extension ChangelogsCollectionProvider {
    
    private var displayedChangelogVersions: [String] {
        UserDefaults.changelogKit.value(forKey: UserDefaults.ChangelogKitKeys.displayedChangelogVersionsKey) as? [String] ?? []
    }
    
    var current: Changelog? {
        changelogs.first { $0.version == Bundle.appVersion }
    }
    
    func markCurrentVersionChangelogAsDisplayed() {
        if let current {
            markChangelogAsDisplayed(current)
        }
    }
    
    func markChangelogAsDisplayed(_ changelog: Changelog) {
        var changelogs = Set(displayedChangelogVersions)
        if changelogs.insert(changelog.version).inserted {
            UserDefaults.changelogKit.setValue(Array(changelogs), forKey: UserDefaults.ChangelogKitKeys.displayedChangelogVersionsKey)
        }
    }
    
    func isVersionAlreadyDisplayed(_ version: String) -> Bool {
        displayedChangelogVersions.contains(version)
    }
    
    func isChangelogAlreadyDisplayed(_ changelog: Changelog) -> Bool {
        isVersionAlreadyDisplayed(changelog.version)
    }
    
    func shouldChangelogBeDisplayed(_ changelog: Changelog) -> Bool {
        !isChangelogAlreadyDisplayed(changelog)
    }
    
    func shouldVersionBeDisplayed(_ version: String) -> Bool {
        !isVersionAlreadyDisplayed(version)
    }
    
    func isCurrentChangelogAlreadyDisplayed() -> Bool {
        if let current {
            return isChangelogAlreadyDisplayed(current)
        }
        
        return false
    }
    
    func isCurrentVersionAlreadyDisplayed() -> Bool {
        isCurrentChangelogAlreadyDisplayed()
    }
    
    func shouldCurrentChangelogBeDisplayed() -> Bool {
        !isCurrentChangelogAlreadyDisplayed()
    }
    
    func shouldCurrentVersionBeDisplayed() -> Bool {
        !isCurrentVersionAlreadyDisplayed()
    }
}


// MARK: - Public methods

public extension ChangelogsCollectionProvider {
    
    /// Reset all the displayed version.
    /// > Warning: This is a destructive method, use it only if really needed.
    func resetDisplayedChangelogs() {
        UserDefaults.changelogKit.removeObject(forKey: UserDefaults.ChangelogKitKeys.displayedChangelogVersionsKey)
    }
    
    func markChangelogAsNotDisplayed(_ changelog: Changelog) {
        var changelogs = Set(displayedChangelogVersions)
        if changelogs.remove(changelog.version) != nil {
            // Set the array again only if the element was actually removed.
            // This will skip if element is not present in the array.
            UserDefaults.changelogKit.setValue(changelogs, forKey: UserDefaults.ChangelogKitKeys.displayedChangelogVersionsKey)
        }
    }
}
