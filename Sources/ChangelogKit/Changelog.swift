//
//  Changelog.swift
//
//
//  Created by Andrea Mario Lufino on 30/12/23.
//

import Foundation
import SwiftUI


/// Represents a single app version and the features introduced in it.
///
/// Create one `Changelog` per app version and collect them in a type that conforms
/// to `ChangelogsCollectionProvider`. The associated `ChangelogView` renders the
/// features in a card-based layout grouped by section.
///
/// ```swift
/// let changelog = Changelog(
///     version: "2.0",
///     features: [
///         Changelog.Feature(symbol: "star.fill", title: "Favorites", description: "..."),
///     ]
/// )
/// ```
public struct Changelog: Identifiable, Equatable, Codable, Hashable {

    /// The unique identifier of the changelog. Equal to `version`.
    public var id: String { version }
    /// The internal title of the changelog, used for legacy Codable compatibility.
    ///
    /// The `ChangelogView` no longer renders this title directly — it uses the
    /// localized "What's new" navigation title instead. This property is kept
    /// to preserve Codable round-trip compatibility.
    @available(*, deprecated, message: "The title is no longer rendered by ChangelogView. It is kept for Codable compatibility only.")
    public var title: String
    /// The version string this changelog describes (e.g. `"1.2.1"`).
    public let version: String
    /// The features introduced in this version.
    public let features: [Feature]

    /// Two changelogs are equal when they share the same version string.
    public static func ==(lhs: Changelog, rhs: Changelog) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes the changelog using its version string.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Creates a new `Changelog`.
    /// - Parameters:
    ///   - title: An internal title. Defaults to the localized "What's new in version X.Y.Z"
    ///     string. Not rendered by `ChangelogView`.
    ///   - version: The version string (e.g. `"1.2.1"`).
    ///   - features: The features to display for this version.
    public init(title: String? = nil, version: String, features: [Feature]) {
        self.title = title ?? String(format: String(localized: "What's new in version", bundle: .module), version)
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
        
        // MARK: - PinBehavior

        /// Defines how long a feature remains visible in the pinned highlights section
        /// when the app is updated to a newer version.
        public enum PinBehavior: Codable, Hashable {
            /// The feature is never shown in the pinned section. Default.
            case never
            /// The feature is shown as long as the app version matches the same
            /// major, minor, and patch as the changelog version it belongs to.
            case untilPatchChanges
            /// The feature is shown as long as the app version shares the same
            /// major and minor as the changelog version it belongs to.
            /// Survives hotfix updates (e.g. 1.2.0 → 1.2.1).
            case untilMinorChanges
            /// The feature is shown as long as the app version shares the same
            /// major as the changelog version it belongs to.
            /// Survives all minor and patch updates within the same major.
            case untilMajorChanges
            /// The feature is always shown in the pinned section until the developer
            /// explicitly removes or changes it.
            case always
        }

        /// The identifier of the feature. It is automatically generated.
        public var id: UUID = UUID()
        /// The system symbol name to be associated with the feature.
        public let symbol: String
        /// The title of the feature.
        public let title: String
        /// The description of the feature.
        public let description: String
        /// Defines how long this feature appears in the pinned highlights section
        /// when the app is updated. Defaults to `.never`.
        public let pinBehavior: PinBehavior
        /// The color associated to the feature.
        public var color: Color? {
            set {
                if let newValue {
                    var r: CGFloat = -1
                    var g: CGFloat = -1
                    var b: CGFloat = -1
                    var a: CGFloat = -1
                    if UIColor(newValue).getRed(&r, green: &g, blue: &b, alpha: &a) {
                        red = r
                        green = g
                        blue = b
                        alpha = a
                    }
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
        
        /// Two features are equal when they share the same auto-generated `id`.
        public static func ==(lhs: Feature, rhs: Feature) -> Bool {
            lhs.id == rhs.id
        }

        /// Hashes the feature using its auto-generated `id`.
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        /// Create a new instance of `Feature`.
        /// - Parameters:
        ///   - symbol: The symbol associated to the feature.
        ///   - title: The title of the feature.
        ///   - description: The description of the feature.
        ///   - color: The color associated to this feature.
        ///   - pinBehavior: Defines how long this feature appears in the pinned highlights
        ///     section when the app updates. Defaults to `.never`.
        public init(symbol: String, title: String, description: String, color: Color? = nil, pinBehavior: PinBehavior = .never) {
            self.symbol = symbol
            self.title = title
            self.description = description
            self.pinBehavior = pinBehavior
            self.color = color
        }
    }
}


// MARK: - SemVer

/// Internal utility for parsing and comparing semantic version strings.
///
/// Supports both `major.minor` and `major.minor.patch` formats.
/// Missing components default to `0` (e.g. `"1.2"` is treated as `"1.2.0"`).
struct SemVer {
    let major: Int
    let minor: Int
    let patch: Int

    /// Parses a version string into its major, minor, and patch components.
    ///
    /// Accepts both `major.minor` and `major.minor.patch` formats. Any missing
    /// component defaults to `0`, so `"1.2"` is equivalent to `"1.2.0"`.
    ///
    /// - Parameter string: A version string such as `"1.2"` or `"1.2.3"`.
    init(_ string: String) {
        let parts = string.split(separator: ".").compactMap { Int($0) }
        major = parts.count > 0 ? parts[0] : 0
        minor = parts.count > 1 ? parts[1] : 0
        patch = parts.count > 2 ? parts[2] : 0
    }
}


// MARK: - Used for preview

extension Changelog {
    
    static let versionOne: Changelog = Changelog.init(
        version: "1.0",
        features: [
            Feature(symbol: "star.fill", title: "Favorites", description: "Now you will be able to add every item to your favorites. This flag will be synced with iCloud."),
            Feature(symbol: "wand.and.stars", title: "Magic Restyle", description: "Using this feature you will be able to improve the quality of your pictures without having to know the details of photo editing.", color: .indigo),
            Feature(symbol: "bookmark.circle.fill", title: "Bookmarks", description: "Bookmark the best articles to have them available offline. You can tap on the archive to see all of your bookmarked articles.", color: .orange),
        ]
    )
}
