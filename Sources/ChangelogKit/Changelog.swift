//
//  Changelog.swift
//
//
//  Created by Andrea Mario Lufino on 30/12/23.
//

import Foundation
import SwiftUI


public struct Changelog: Identifiable, Equatable {
    
    public let id: UUID = UUID()
    public var title: String? = nil
    public let version: String
    public let features: [Feature]
    
    public static func ==(lhs: Changelog, rhs: Changelog) -> Bool {
        lhs.id == rhs.id
    }
    
    public struct Feature: Identifiable, Equatable {
        
        public let id: UUID = UUID()
        public let symbol: String
        public let title: String
        public let description: String
        public var color: Color?
        
        public static func ==(lhs: Feature, rhs: Feature) -> Bool {
            lhs.id == rhs.id
        }
    }
}


extension Changelog {
    
    static let versioneOne: Changelog = Changelog.init(
        version: "1.0",
        features: [
            Feature(symbol: "star.fill", title: "Favorites", description: "Now you will be able to add every item to your favorites. This flag will be synced with iCloud."),
            Feature(symbol: "wand.and.stars", title: "Magic Restyle", description: "Using this feature you will be able to improve the quality of your pictures without having to knnow the details of photo editing.", color: .indigo),
            Feature(symbol: "bookmark.circle.fill", title: "Bookmarks", description: "Bookmark the best articles to have them available offline. You can tap on the archive to see all of your bookmarked articles.", color: .orange),
        ]
    )
}
