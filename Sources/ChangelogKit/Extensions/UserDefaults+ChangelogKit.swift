//
//  UserDefaults+ChangelogKit.swift
//
//
//  Created by Andrea Mario Lufino on 02/01/24.
//

import Foundation


extension UserDefaults {
    static let changelogKit = UserDefaults(suiteName: "ChangelogKit")!
    
    enum ChangelogKitKeys {
        static let displayedChangelogVersionsKey = "displayedChangelogVersions"
    }
}
