//
//  ChangelogView.swift
//
//
//  Created by Andrea Mario Lufino on 31/12/23.
//

import SwiftUI
import UIKit


// MARK: - Feature View

struct FeatureView: View {
    
    var feature: Changelog.Feature
    var style: ChangelogView.Style.Features = ChangelogView.Style.Features()
    
    var body: some View {
        HStack {
            Image(systemName: feature.symbol)
                .renderingMode(feature.color == nil ? .original : .template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(feature.color ?? .accentColor)
                .frame(width: 40)
            VStack(alignment: .leading) {
                Text(feature.title)
                    .font(style.titleFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(style.titleTextColor)
                Text(feature.description)
                    .font(style.descriptionFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(style.descriptionTextColor)
            }
            .padding(.leading)
        }
        .padding()
    }
}


// MARK: - Changelog View

/// The `ChangelogView` is the view that is dedicated to the rendering of a `Changelog` object.
public struct ChangelogView: View {
    
    @Environment(\.dismiss) private var dismiss
    /// The changelog object that the view has to render.
    public let changelog: Changelog
    /// The style of the user interface of the view.
    public var style: Style
    /// The action to perform when the view is dimissed. It is an optional value.
    public var onDismiss: (() -> Void)?
    
    public init(changelog: Changelog, style: Style = ChangelogView.Style(), onDismiss: (() -> Void)? = nil) {
        self.changelog = changelog
        self.style = style
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack {
            Text(changelog.title ?? changelog.version)
                .font(style.title.font)
            ScrollView {
                VStack(spacing: style.view.spacingBetweenFeatures) {
                    ForEach(changelog.features) { feature in
                        FeatureView(feature: feature, style: style.features)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            
            Button(action: {
                dismiss()
                onDismiss?()
            }, label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        if let gradient = style.primaryAction.backgroundGradient {
                            RoundedRectangle(cornerRadius: style.primaryAction.cornerRadius)
                                .fill(gradient)
                        } else {
                            RoundedRectangle(cornerRadius: style.primaryAction.cornerRadius)
                                .fill(style.primaryAction.backgroundColor)
                        }
                    }
                    .foregroundStyle(.white)
                    .font(.title3.weight(.bold))
            })
        }
        .padding()
    }
}


// MARK: - View modifier

public extension View {
    
    /// Show the changelog view when the binding value is `true`.
    /// - Parameters:
    ///   - changelog: The changelog object to render.
    ///   - style: The style of the user interface.
    ///   - show: The binding value used to show the view.
    ///   - onDismiss: The code to perform when view is dismissed. Default is `nil`.
    /// - Returns: A new view.
    func changelogView(
        changelog: Changelog,
        style: ChangelogView.Style = ChangelogView.Style(),
        show: Binding<Bool>,
        onDismiss: (() -> Void)? = nil) -> some View
    {
        self.sheet(isPresented: show, content: {
            ChangelogView(changelog: changelog, style: style, onDismiss: onDismiss)
        })
    }
}


// MARK: - On dismiss

public extension ChangelogView {
    
    /// Perform code when view is dismissed.
    /// - Parameter action: The code to perform when a changelog view is dismissed.
    /// - Returns: The changelog view.
    func onDismiss(_ action: @escaping () -> Void) -> ChangelogView {
        var new = self
        new.onDismiss = action
        return new
    }
}


// MARK: - Style

extension ChangelogView {
    
    /// This structure define the interface of the `ChangelogView`.
    public struct Style {
        /// The struct `View` that defines the attributes of the entire view.
        public var view: View                      = View()
        /// The struct `Title` that defines the attributes of the view's title.
        public var title: Title                    = Title()
        /// The struct `Features` that defines the attributes of the features view.
        public var features: Features              = Features()
        /// The struct `PrimaryAction` that defines the attributes of the main button.
        public var primaryAction: PrimaryAction    = PrimaryAction()
        
        public init(
            view: View = View(),
            title: Title = Title(),
            features: Features = Features(),
            primaryAction: PrimaryAction = PrimaryAction())
        {
            self.view = view
            self.title = title
            self.features = features
            self.primaryAction = primaryAction
        }
        
        /// The attributes related to the entire view.
        public struct View {
            /// The spacing between every feature in the list.
            public var spacingBetweenFeatures: CGFloat
            
            public init(spacingBetweenFeatures: CGFloat = 10) {
                self.spacingBetweenFeatures = spacingBetweenFeatures
            }
        }
        
        /// The attributes related to the view's title.
        public struct Title {
            /// The font of the title.
            public var font: Font
            /// The color of the title.
            public var color: Color
            
            /// Create a new instance of `Title`.
            /// - Parameters:
            ///   - font: The font of the title. Default is `.largeTitle.weight(.heavy)`.
            ///   - color: The color of the title. Default is `Color(UIColor.label)`.
            public init(
                font: Font      = .largeTitle.weight(.heavy),
                color: Color    = Color(UIColor.label))
            {
                self.font = font
                self.color = color
            }
        }
        
        /// The attributes related to the single features.
        public struct Features {
            /// The font of the feature's title.
            public var titleFont: Font
            /// The font of the feature's description.
            public var descriptionFont: Font
            /// The text color of the feature's title.
            public var titleTextColor: Color
            /// The text color of the feature's description.
            public var descriptionTextColor: Color
            
            /// Create a new instance of `Features`.
            /// - Parameters:
            ///   - titleFont: The font of the feature's title. Default is `.headline`.
            ///   - descriptionFont: The font of the feature's description. Default is `.subheadline`.
            ///   - titleTextColor: The text color of the feature's title. Default is `Color(UIColor.label)`.
            ///   - descriptionTextColor: The text color of the feature's description. Default is `Color(UIColor.label)`.
            public init(
                titleFont: Font                 = .headline,
                descriptionFont: Font           = .subheadline,
                titleTextColor: Color           = Color(UIColor.label),
                descriptionTextColor: Color     = Color(UIColor.label))
            {
                self.titleFont = titleFont
                self.descriptionFont = descriptionFont
                self.titleTextColor = titleTextColor
                self.descriptionTextColor = descriptionTextColor
            }
        }
        
        /// The attributes related to the main button.
        public struct PrimaryAction {
            /// The title of the button.
            var title: String
            /// The font of the button.
            public var font: Font
            /// The corner radius of the button.
            public var cornerRadius: CGFloat
            /// The background color of the button.
            public var backgroundColor: Color
            /// The background gradient of the button.
            /// If set, this overrides the background color.
            public var backgroundGradient: LinearGradient?
            /// The text color.
            public var textColor: Color
            
            /// Create a new instance of `PrimaryAction`.
            /// - Parameters:
            ///   - title: The title of the button. Default is `Continue`, declared as `String(localized: "Continue").`.
            ///   - font: The font of the button. Default is `.title3.weight(.bold)`.
            ///   - cornerRadius: The corner radius of the button. Default is `14`.
            ///   - backgroundColor: The background color of the button. Default is `.accentColor`.
            ///   - backgroundGradient: The background gradient of the button. If set, this overrides the `backgroundColor`. Default is nil.
            ///   - textColor: The text color. Default is `.white`.
            public init(
                title: String                       = String(localized: "Continue"),
                font: Font                          = .title3.weight(.bold),
                cornerRadius: CGFloat               = 14,
                backgroundColor: Color              = .accentColor,
                backgroundGradient: LinearGradient? = nil,
                textColor: Color                    = .white)
            {
                self.title = title
                self.font = font
                self.cornerRadius = cornerRadius
                self.backgroundColor = backgroundColor
                self.backgroundGradient = backgroundGradient
                self.textColor = textColor
            }
        }
    }
}


// MARK: - Preview

#Preview {
    ChangelogView(
        changelog: Changelog.versioneOne,
        style: ChangelogView.Style(
            primaryAction: ChangelogView.Style.PrimaryAction(
                backgroundGradient: LinearGradient(colors: [.blue, .indigo], startPoint: .bottomLeading, endPoint: .topTrailing)
            )
        )
    )
}
