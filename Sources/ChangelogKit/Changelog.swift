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
public struct Changelog: Identifiable, Equatable, Codable, Hashable {
    /// The identifier of the changelog. It is the version.
    public var id: String { version }
    /// The title of the changelog.
    public var title: String
    /// The version of the changelog.
    public let version: String
    /// Array of `Feature` objects.
    public let features: [Feature]
    
    public static func ==(lhs: Changelog, rhs: Changelog) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Create a new instance of `Changelog`.
    /// - Parameters:
    ///   - title: The title of the changelog. If nil, the value will be equal to "What's new in version _version_".
    ///   - version: The version of the changelog.
    ///   - features: The features associated with the changelog.
    public init(title: String? = nil, version: String, features: [Feature]) {
        self.title = title ?? String(localized: "What's new in version \(version)")
        self.version = version
        self.features = features
    }
}


// MARK: - Feature

public extension Changelog {
    
    /// The `Feature` represents a new functionality added to your app.
    ///
    /// > Note: A feature could be the addition of a "Mark as Favorite".
    struct Feature: Identifiable, Equatable, Codable, Hashable {
        
        /// The identifier of the feature. It is automatically generated.
        public var id: UUID = UUID()
        /// The system symbol name to be associated with the feature.
        public let symbol: String
        /// The title of the feature.
        public let title: String
        /// The description of the feature.
        public let description: String
        /// The color associated to the feature.
        public var color: Color? {
            set {
                if let newValue {
                    UIColor(newValue).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                }
            }
            get {
                // Return the color only if the rgba values are different from -1,
                // that is the default value when no color is saved.
                guard ![red, green, blue, alpha].contains(-1) else {
                    return nil
                }
                return Color(red: red, green: green, blue: blue, opacity: alpha)
            }
        }
        private var red: CGFloat    = -1
        private var green: CGFloat  = -1
        private var blue: CGFloat   = -1
        private var alpha: CGFloat  = -1
        
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
