//
//  Changelog.swift
//
//
//  Created by Andrea Mario Lufino on 30/12/23.
//

import Foundation
import SwiftUI


/// A `Changelog` is a structure that represents a version and the
/// features associated with it. 
///
/// For example you can create a `Changelog` object to represents
/// the update of your app to the version `1.2`. You will add the
/// features to the `features` property then and they will be rendered
/// with the `ChangelogView`.
public struct Changelog: Identifiable, Equatable {
    
    /// The identifier of the changelog. It is automatically generated.
    public let id: UUID = UUID()
    /// The title of the changelog.
    ///
    /// > Example: This could be "Version 1.2".
    public var title: String? = nil
    /// The version of the changelog.
    public let version: String
    /// Array of `Feature` objects.
    public let features: [Feature]
    
    public static func ==(lhs: Changelog, rhs: Changelog) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Create a new instance of `Changelog`.
    /// - Parameters:
    ///   - title: The title of the changelog.
    ///   - version: The version of the changelog.
    ///   - features: The features associated with the changelog.
    public init(title: String? = nil, version: String, features: [Feature]) {
        self.title = title
        self.version = version
        self.features = features
    }
    
    /// The `Feature` represents a new functionality added to your app.
    ///
    /// A feature could be the addition of a "Mark as Favorite`.
    public struct Feature: Identifiable, Equatable {
        
        /// The identifier of the feature. It is automatically generated.
        public let id: UUID = UUID()
        /// The system symbol name to be associated with the feature.
        public let symbol: String
        /// The title of the feature.
        public let title: String
        /// The description of the feature.
        public let description: String
        /// The color associated to the feature.
        public var color: Color?
        
        public static func ==(lhs: Feature, rhs: Feature) -> Bool {
            lhs.id == rhs.id
        }
        
        /// Create a new instance of `Feature`.
        /// - Parameters:
        ///   - symbol: The symbol associated to the feature.
        ///   - title: The title of the feature.
        ///   - description: The description of the feature.
        ///   - color: The color associated to this feature.
        public init(symbol: String, title: String, description: String, color: Color? = nil) {
            self.symbol = symbol
            self.title = title
            self.description = description
            self.color = color
        }
    }
}


// MARK: - Used for preview

extension Changelog {
    
    static let versioneOne: Changelog = Changelog.init(
        version: "1.0",
        features: [
            Feature(symbol: "star.fill", title: "Favorites", description: "Now you will be able to add every item to your favorites. This flag will be synced with iCloud."),
            Feature(symbol: "wand.and.stars", title: "Magic Restyle", description: "Using this feature you will be able to improve the quality of your pictures without having to know the details of photo editing.", color: .indigo),
            Feature(symbol: "bookmark.circle.fill", title: "Bookmarks", description: "Bookmark the best articles to have them available offline. You can tap on the archive to see all of your bookmarked articles.", color: .orange),
        ]
    )
}
