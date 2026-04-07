//
//  ChangelogView.swift
//
//
//  Created by Andrea Mario Lufino on 31/12/23.
//

import SwiftUI
import UIKit


// MARK: - Section Header View

/// Renders a section label (e.g. "HIGHLIGHTS" or "VERSION 1.2.1").
///
/// Applies uppercasing when `style.uppercased` is `true`.
struct SectionHeaderView: View {

    /// The raw text to display. Uppercased automatically if `style.uppercased` is `true`.
    let text: String
    /// The style attributes controlling font, color, and casing.
    let style: ChangelogView.Style.SectionHeader

    var body: some View {
        Text(style.uppercased ? text.uppercased() : text)
            .font(style.font)
            .foregroundStyle(style.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(text)
    }
}


// MARK: - Feature Row View

/// A single feature row composed of an icon container on the left and the
/// feature title and description stacked vertically on the right.
///
/// Used both inside `PinnedCardView` (highlights section) and `FeatureCardView`
/// (current version section), so changes here affect both contexts.
struct FeatureRowView: View {

    /// The feature to render.
    let feature: Changelog.Feature
    /// The style controlling icon size, container shape, and text appearance.
    let style: ChangelogView.Style

    var body: some View {
        HStack(spacing: 12) {
            iconView
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(style.features.titleFont)
                    .foregroundStyle(style.features.titleTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(feature.description)
                    .font(style.features.descriptionFont)
                    .foregroundStyle(style.features.descriptionTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(style.view.contentPadding)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(feature.title). \(feature.description)")
    }

    // MARK: Private

    @ViewBuilder
    private var iconView: some View {
        let icon = style.featureIcon
        let image = Image(systemName: feature.symbol)
            .renderingMode(feature.color == nil ? .original : .template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(feature.color ?? .accentColor)
            .frame(width: icon.size, height: icon.size)

        switch icon.containerShape {
        case .none:
            image
        case .circle:
            image
                .frame(width: icon.containerSize, height: icon.containerSize)
                .background(icon.containerColor)
                .clipShape(Circle())
        case .roundedSquare(let radius):
            image
                .frame(width: icon.containerSize, height: icon.containerSize)
                .background(icon.containerColor)
                .clipShape(RoundedRectangle(cornerRadius: radius))
        }
    }
}


// MARK: - Feature Card View

/// A standalone card wrapping a single `FeatureRowView`.
///
/// Used for each feature in the current version section. Every feature gets
/// its own card, separated by `style.view.spacingBetweenFeatures`.
struct FeatureCardView: View {

    /// The feature to render inside the card.
    let feature: Changelog.Feature
    /// The style controlling card appearance and row layout.
    let style: ChangelogView.Style

    var body: some View {
        FeatureRowView(feature: feature, style: style)
            .background(style.card.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: style.card.cornerRadius))
            .shadow(
                color: style.card.shadowColor,
                radius: style.card.shadowRadius,
                x: style.card.shadowOffset.width,
                y: style.card.shadowOffset.height
            )
    }
}


// MARK: - Pinned Card View

/// A single grouped card that contains all pinned highlights features.
///
/// Features are stacked vertically and separated by optional `Divider` views
/// controlled by `style.featureDivider`. The entire group shares one card
/// background, visually distinguishing the highlights section from the
/// individual cards used for current-version features.
struct PinnedCardView: View {

    /// The pinned features to display inside the card.
    let features: [Changelog.Feature]
    /// The style controlling card appearance, divider visibility, and row layout.
    let style: ChangelogView.Style

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                FeatureRowView(feature: feature, style: style)
                if style.featureDivider.visible && index < features.count - 1 {
                    Divider()
                        .background(style.featureDivider.color)
                        .padding(.horizontal, style.view.contentPadding)
                }
            }
        }
        .background(style.card.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: style.card.cornerRadius))
        .shadow(
            color: style.card.shadowColor,
            radius: style.card.shadowRadius,
            x: style.card.shadowOffset.width,
            y: style.card.shadowOffset.height
        )
    }
}


// MARK: - Changelog View

/// The `ChangelogView` is the view that is dedicated to the rendering of a `Changelog` object.
///
/// It displays the features of the given changelog in a card-based layout. When
/// `pinnedFeatures` is provided, a dedicated highlights section appears above the
/// current-version features, grouping pinned items in a single card with dividers.
public struct ChangelogView: View {

    @Environment(\.dismiss) private var dismiss
    /// The changelog object that the view has to render.
    public let changelog: Changelog
    /// The pinned features from previous versions to show in the highlights section.
    /// When empty, the highlights section is hidden entirely. Defaults to `[]`.
    public var pinnedFeatures: [Changelog.Feature]
    /// The style of the user interface of the view.
    public var style: Style
    /// The action to perform when the view is dismissed. It is an optional value.
    public var onDismiss: (() -> Void)?

    /// Create a new instance of `ChangelogView`.
    /// - Parameters:
    ///   - changelog: The changelog to display.
    ///   - pinnedFeatures: Features from previous versions to pin in the highlights section.
    ///     Defaults to `[]` (no highlights section shown).
    ///   - style: The visual style of the view. Defaults to `Style()`.
    ///   - onDismiss: An optional closure executed when the view is dismissed.
    public init(
        changelog: Changelog,
        pinnedFeatures: [Changelog.Feature] = [],
        style: Style = Style(),
        onDismiss: (() -> Void)? = nil)
    {
        self.changelog = changelog
        self.pinnedFeatures = pinnedFeatures
        self.style = style
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: style.view.spacingBetweenSections) {

                // Highlights section — only when pinned features are present
                if !pinnedFeatures.isEmpty {
                    VStack(alignment: .leading, spacing: style.view.spacingBetweenHeaderAndCard) {
                        SectionHeaderView(
                            text: style.sectionHeader.pinnedTitle,
                            style: style.sectionHeader
                        )
                        PinnedCardView(features: pinnedFeatures, style: style)
                    }
                }

                // Current version section
                VStack(alignment: .leading, spacing: style.view.spacingBetweenHeaderAndCard) {
                    SectionHeaderView(
                        text: currentVersionLabel,
                        style: style.sectionHeader
                    )
                    VStack(spacing: style.view.spacingBetweenFeatures) {
                        ForEach(changelog.features) { feature in
                            FeatureCardView(feature: feature, style: style)
                        }
                    }
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle(String(localized: "What's new", bundle: .module))
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            if !style.primaryAction.hidden {
                Button(action: {
                    onDismiss?()
                    dismiss()
                }, label: {
                    Text(style.primaryAction.title ?? String(localized: "Continue", bundle: .module))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background { primaryActionBackground(style.primaryAction) }
                        .foregroundStyle(style.primaryAction.textColor)
                        .font(style.primaryAction.font)
                })
                .padding()
                .background(.regularMaterial)
            }
        }
    }

    // MARK: - Private

    private var currentVersionLabel: String {
        if let custom = style.sectionHeader.currentVersionTitle {
            return custom
        }
        return String(format: String(localized: "Version", bundle: .module), changelog.version)
    }
}


// MARK: - Private helpers

private extension ChangelogView {

    @ViewBuilder
    func primaryActionBackground(_ action: Style.PrimaryAction) -> some View {
        let fill = action.backgroundGradient.map { AnyShapeStyle($0) } ?? AnyShapeStyle(action.backgroundColor)
        if action.useCapsuleAsShape {
            Capsule().fill(fill)
        } else {
            RoundedRectangle(cornerRadius: action.cornerRadius).fill(fill)
        }
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


// MARK: - View Presenter Modifier

/// The backing modifier for the `.sheet(isPresented:changelog:style:onDismiss:)` view extension.
///
/// Presents the given changelog in a sheet wrapped in a `NavigationStack`, which
/// provides the large-title "What's new" navigation bar and enables the title to
/// collapse as the user scrolls. Use the public `.sheet(isPresented:changelog:)`
/// view modifier instead of instantiating this type directly.
struct ChangelogViewPresenter: ViewModifier {

    @Binding var isPresented: Bool
    /// The changelog to display.
    let changelog: Changelog
    /// The visual style passed through to `ChangelogView`.
    let style: ChangelogView.Style
    /// An optional closure executed when the sheet is dismissed.
    var onDismiss: (() -> Void)?

    init(
        isPresented: Binding<Bool>,
        changelog: Changelog,
        style: ChangelogView.Style,
        onDismiss: (() -> Void)? = nil)
    {
        self._isPresented = isPresented
        self.changelog = changelog
        self.style = style
        self.onDismiss = onDismiss
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, content: {
                NavigationStack {
                    ChangelogView(changelog: changelog, style: style, onDismiss: onDismiss)
                }
                .onDisappear { isPresented = false }
            })
    }
}

/// The backing modifier for the `.showCurrentChangelogIfNeeded(isPresented:provider:)` view extension.
///
/// Automatically determines which changelog to show and which pinned features to
/// surface by querying `provider.current` and `provider.pinnedFeatures` at init
/// time. The sheet is presented only when `provider.shouldCurrentChangelogBeDisplayed`
/// is `true`, or unconditionally when `debug` is `true`.
///
/// Use the public `.showCurrentChangelogIfNeeded(isPresented:provider:)` view modifier
/// instead of instantiating this type directly.
///
/// > Note: When `debug` is `true` the changelog is always presented, regardless of
/// > whether the current version has already been seen.
struct ProviderChangelogViewPresenter: ViewModifier {

    @Binding var isPresented: Bool
    /// The changelog matching the current app version, resolved at init time.
    private var changelog: Changelog?
    /// The pinned features resolved from the provider at init time.
    private var pinnedFeatures: [Changelog.Feature]
    /// The provider supplying changelogs and tracking display state.
    let provider: ChangelogsCollectionProvider
    /// The visual style passed through to `ChangelogView`.
    let style: ChangelogView.Style
    /// When `true`, the sheet is always presented regardless of display history.
    let debug: Bool
    /// An optional closure executed when the sheet is dismissed.
    var onDismiss: (() -> Void)?

    init(
        isPresented: Binding<Bool>,
        provider: ChangelogsCollectionProvider,
        style: ChangelogView.Style = ChangelogView.Style(),
        debug: Bool = false,
        onDismiss: (() -> Void)? = nil)
    {
        self._isPresented = isPresented
        self.provider = provider
        self.changelog = provider.current
        self.pinnedFeatures = provider.pinnedFeatures
        self.style = style
        self.debug = debug
        self.onDismiss = onDismiss
    }

    func body(content: Content) -> some View {
        if let changelog, provider.shouldCurrentChangelogBeDisplayed || debug {
            content
                .sheet(isPresented: $isPresented, onDismiss: onDismiss, content: {
                    NavigationStack {
                        ChangelogView(changelog: changelog, pinnedFeatures: pinnedFeatures, style: style)
                            .onAppear { provider.markCurrentVersionChangelogAsDisplayed() }
                    }
                    .onDisappear { isPresented = false }
                })
        } else {
            content
        }
    }
}


// MARK: - Style

extension ChangelogView {

    /// Defines the visual appearance of `ChangelogView`.
    public struct Style {
        /// The attributes related to the entire view layout.
        public var view: View                           = View()
        /// The attributes related to the view's title.
        @available(*, deprecated, message: "Style.Title has no effect. The view title is now rendered as a navigationTitle by the system.")
        public var title: Title                         = Title()
        /// The attributes related to the feature text (title and description).
        public var features: Features                   = Features()
        /// The attributes related to the main dismiss button.
        public var primaryAction: PrimaryAction         = PrimaryAction()
        /// The attributes related to the feature cards.
        public var card: Card                           = Card()
        /// The attributes related to the SF Symbol icon container.
        public var featureIcon: FeatureIcon             = FeatureIcon()
        /// The attributes related to the section header labels.
        public var sectionHeader: SectionHeader         = SectionHeader()
        /// The attributes related to the divider inside the pinned highlights card.
        public var featureDivider: FeatureDivider       = FeatureDivider()

        /// Create a new instance of `Style`.
        /// - Parameters:
        ///   - view: Layout attributes. Defaults to `View()`.
        ///   - title: Title attributes. Defaults to `Title()`.
        ///   - features: Feature text attributes. Defaults to `Features()`.
        ///   - primaryAction: Button attributes. Defaults to `PrimaryAction()`.
        ///   - card: Card attributes. Defaults to `Card()`.
        ///   - featureIcon: Icon container attributes. Defaults to `FeatureIcon()`.
        ///   - sectionHeader: Section label attributes. Defaults to `SectionHeader()`.
        ///   - featureDivider: Pinned card divider attributes. Defaults to `FeatureDivider()`.
        public init(
            view: View                      = View(),
            title: Title                    = Title(),
            features: Features              = Features(),
            primaryAction: PrimaryAction    = PrimaryAction(),
            card: Card                      = Card(),
            featureIcon: FeatureIcon        = FeatureIcon(),
            sectionHeader: SectionHeader    = SectionHeader(),
            featureDivider: FeatureDivider  = FeatureDivider())
        {
            self.view = view
            self.title = title
            self.features = features
            self.primaryAction = primaryAction
            self.card = card
            self.featureIcon = featureIcon
            self.sectionHeader = sectionHeader
            self.featureDivider = featureDivider
        }

        // MARK: View

        /// Layout attributes for the overall view.
        public struct View {
            /// The spacing between the highlights section and the current version section.
            public var spacingBetweenSections: CGFloat
            /// The spacing between a section header label and the card below it.
            public var spacingBetweenHeaderAndCard: CGFloat
            /// The spacing between individual feature cards in the current version section.
            public var spacingBetweenFeatures: CGFloat
            /// The internal padding applied to each feature row inside a card.
            public var contentPadding: CGFloat

            /// Create a new instance of `View`.
            /// - Parameters:
            ///   - spacingBetweenSections: Spacing between the highlights and current version
            ///     sections. Defaults to `24`.
            ///   - spacingBetweenHeaderAndCard: Spacing between a section label and its card.
            ///     Defaults to `8`.
            ///   - spacingBetweenFeatures: Spacing between individual feature cards. Defaults to `8`.
            ///   - contentPadding: Internal padding of each feature row. Defaults to `12`.
            public init(
                spacingBetweenSections: CGFloat         = 24,
                spacingBetweenHeaderAndCard: CGFloat    = 8,
                spacingBetweenFeatures: CGFloat         = 8,
                contentPadding: CGFloat                 = 12)
            {
                self.spacingBetweenSections = spacingBetweenSections
                self.spacingBetweenHeaderAndCard = spacingBetweenHeaderAndCard
                self.spacingBetweenFeatures = spacingBetweenFeatures
                self.contentPadding = contentPadding
            }
        }

        // MARK: Title

        /// Attributes kept for API compatibility. Has no visual effect in 2.0+.
        ///
        /// The "What's new" title is now rendered as a `navigationTitle` by `ChangelogView`
        /// and styled by the system. This struct is retained to avoid breaking existing
        /// `Style` initializers that pass a `title:` argument, but its properties are
        /// not applied to any rendered view.
        @available(*, deprecated, message: "Style.Title has no effect. The view title is now rendered as a navigationTitle by the system.")
        public struct Title {
            /// Retained for API compatibility. Not applied to any rendered view.
            public var font: Font
            /// Retained for API compatibility. Not applied to any rendered view.
            public var color: Color

            /// Create a new instance of `Title`.
            /// - Parameters:
            ///   - font: Retained for API compatibility. Defaults to `.largeTitle.weight(.bold)`.
            ///   - color: Retained for API compatibility. Defaults to `Color(UIColor.label)`.
            public init(
                font: Font      = .largeTitle.weight(.bold),
                color: Color    = Color(UIColor.label))
            {
                self.font = font
                self.color = color
            }
        }

        // MARK: Features

        /// Attributes for the feature text (title and description).
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
            ///   - titleFont: Font for feature titles. Defaults to `.headline`.
            ///   - descriptionFont: Font for feature descriptions. Defaults to `.subheadline`.
            ///   - titleTextColor: Color for feature titles. Defaults to `Color(UIColor.label)`.
            ///   - descriptionTextColor: Color for feature descriptions. Defaults to
            ///     `Color(UIColor.secondaryLabel)`.
            public init(
                titleFont: Font             = .headline,
                descriptionFont: Font       = .subheadline,
                titleTextColor: Color       = Color(UIColor.label),
                descriptionTextColor: Color = Color(UIColor.secondaryLabel))
            {
                self.titleFont = titleFont
                self.descriptionFont = descriptionFont
                self.titleTextColor = titleTextColor
                self.descriptionTextColor = descriptionTextColor
            }
        }

        // MARK: PrimaryAction

        /// Attributes for the main dismiss button.
        public struct PrimaryAction {
            /// The title of the button. When `nil`, uses the package-localized default "Continue".
            public var title: String?
            /// Whether the button is hidden. Defaults to `false`.
            public var hidden: Bool
            /// The font of the button label.
            public var font: Font
            /// When `true`, the button uses a capsule shape and the `cornerRadius` is ignored.
            public var useCapsuleAsShape: Bool
            /// The corner radius of the button background. Ignored when `useCapsuleAsShape` is `true`.
            public var cornerRadius: CGFloat
            /// The background color of the button.
            public var backgroundColor: Color
            /// The background gradient of the button. When set, overrides `backgroundColor`.
            public var backgroundGradient: LinearGradient?
            /// The label text color.
            public var textColor: Color

            /// Create a new instance of `PrimaryAction`.
            /// - Parameters:
            ///   - title: Button label. Pass `nil` to use the localized default "Continue".
            ///   - hidden: Whether to hide the button. Defaults to `false`.
            ///   - font: Button label font. Defaults to `.title3.weight(.bold)`.
            ///   - useCapsuleAsShape: Use capsule shape. Defaults to `true`.
            ///   - cornerRadius: Corner radius (ignored when capsule). Defaults to `14`.
            ///   - backgroundColor: Background color. Defaults to `.accentColor`.
            ///   - backgroundGradient: Background gradient (overrides color). Defaults to `nil`.
            ///   - textColor: Label color. Defaults to `.white`.
            public init(
                title: String?                      = nil,
                hidden: Bool                        = false,
                font: Font                          = .title3.weight(.bold),
                useCapsuleAsShape: Bool             = true,
                cornerRadius: CGFloat               = 14,
                backgroundColor: Color              = .accentColor,
                backgroundGradient: LinearGradient? = nil,
                textColor: Color                    = .white)
            {
                self.title = title
                self.hidden = hidden
                self.font = font
                self.useCapsuleAsShape = useCapsuleAsShape
                self.cornerRadius = cornerRadius
                self.backgroundColor = backgroundColor
                self.backgroundGradient = backgroundGradient
                self.textColor = textColor
            }
        }

        // MARK: Card

        /// Attributes for the feature cards (shared between pinned and current-version cards).
        public struct Card {
            /// The background color of the card.
            public var backgroundColor: Color
            /// The corner radius of the card.
            public var cornerRadius: CGFloat
            /// The color of the card's drop shadow. Defaults to `.clear` (no shadow).
            public var shadowColor: Color
            /// The blur radius of the card's drop shadow.
            public var shadowRadius: CGFloat
            /// The x and y offset of the card's drop shadow.
            public var shadowOffset: CGSize

            /// Create a new instance of `Card`.
            /// - Parameters:
            ///   - backgroundColor: Card background. Defaults to `Color(UIColor.secondarySystemBackground)`.
            ///   - cornerRadius: Card corner radius. Defaults to `16`.
            ///   - shadowColor: Shadow color. Defaults to `.clear` (no shadow).
            ///   - shadowRadius: Shadow blur radius. Defaults to `0`.
            ///   - shadowOffset: Shadow offset. Defaults to `.zero`.
            public init(
                backgroundColor: Color  = Color(UIColor.secondarySystemBackground),
                cornerRadius: CGFloat   = 16,
                shadowColor: Color      = .clear,
                shadowRadius: CGFloat   = 0,
                shadowOffset: CGSize    = .zero)
            {
                self.backgroundColor = backgroundColor
                self.cornerRadius = cornerRadius
                self.shadowColor = shadowColor
                self.shadowRadius = shadowRadius
                self.shadowOffset = shadowOffset
            }
        }

        // MARK: FeatureIcon

        /// Attributes for the SF Symbol icon displayed inside each feature row.
        public struct FeatureIcon {
            /// The size of the SF Symbol image.
            public var size: CGFloat
            /// The shape of the icon container. Use `.none` to show the icon without a container.
            public var containerShape: ContainerShape
            /// The width and height of the icon container.
            public var containerSize: CGFloat
            /// The background color of the icon container.
            public var containerColor: Color

            /// Defines the shape of the icon container.
            public enum ContainerShape {
                /// A circular container.
                case circle
                /// A rounded square container with the given corner radius.
                case roundedSquare(radius: CGFloat = 10)
                /// No container — the icon is displayed without a background.
                case none
            }

            /// Create a new instance of `FeatureIcon`.
            /// - Parameters:
            ///   - size: SF Symbol size. Defaults to `24`.
            ///   - containerShape: Container shape. Defaults to `.roundedSquare(radius: 10)`.
            ///   - containerSize: Container width and height. Defaults to `44`.
            ///   - containerColor: Container background color. Defaults to
            ///     `Color(UIColor.tertiarySystemBackground)`.
            public init(
                size: CGFloat                   = 24,
                containerShape: ContainerShape  = .roundedSquare(radius: 10),
                containerSize: CGFloat          = 44,
                containerColor: Color           = Color(UIColor.tertiarySystemBackground))
            {
                self.size = size
                self.containerShape = containerShape
                self.containerSize = containerSize
                self.containerColor = containerColor
            }
        }

        // MARK: SectionHeader

        /// Attributes for the section header labels ("HIGHLIGHTS", "VERSION 1.2.1").
        public struct SectionHeader {
            /// The font of the section label.
            public var font: Font
            /// The color of the section label.
            public var color: Color
            /// When `true`, the label text is uppercased before rendering.
            public var uppercased: Bool
            /// The title of the pinned highlights section. Defaults to the localized "Highlights".
            public var pinnedTitle: String
            /// The title of the current version section. When `nil`, the label is built
            /// automatically as "Version X.Y.Z" using the changelog's version string.
            public var currentVersionTitle: String?

            /// Create a new instance of `SectionHeader`.
            /// - Parameters:
            ///   - font: Section label font. Defaults to `.caption.weight(.semibold)`.
            ///   - color: Section label color. Defaults to `Color(UIColor.secondaryLabel)`.
            ///   - uppercased: Uppercase the label text. Defaults to `true`.
            ///   - pinnedTitle: Title for the highlights section. Defaults to the localized
            ///     "Highlights" string from the package bundle.
            ///   - currentVersionTitle: Title for the current version section. Pass `nil`
            ///     (default) to use the automatically generated "Version X.Y.Z" label.
            public init(
                font: Font                      = .caption.weight(.semibold),
                color: Color                    = Color(UIColor.secondaryLabel),
                uppercased: Bool                = true,
                pinnedTitle: String?            = nil,
                currentVersionTitle: String?    = nil)
            {
                self.font = font
                self.color = color
                self.uppercased = uppercased
                self.pinnedTitle = pinnedTitle ?? String(localized: "Highlights", bundle: .module)
                self.currentVersionTitle = currentVersionTitle
            }
        }

        // MARK: FeatureDivider

        /// Attributes for the divider rendered between pinned features inside the highlights card.
        public struct FeatureDivider {
            /// Whether the divider is visible. Defaults to `true`.
            public var visible: Bool
            /// The color of the divider. Defaults to `Color(UIColor.separator)`.
            public var color: Color

            /// Create a new instance of `FeatureDivider`.
            /// - Parameters:
            ///   - visible: Show the divider. Defaults to `true`.
            ///   - color: Divider color. Defaults to `Color(UIColor.separator)`.
            public init(
                visible: Bool   = true,
                color: Color    = Color(UIColor.separator))
            {
                self.visible = visible
                self.color = color
            }
        }
    }
}


// MARK: - Preview

#Preview("With highlights") {
    ChangelogView(
        changelog: Changelog(
            version: "1.2.1",
            features: [
                Changelog.Feature(symbol: "wand.and.stars", title: "Magic Restyle", description: "Improve the quality of your pictures without knowing photo editing.", color: .indigo),
                Changelog.Feature(symbol: "moon.fill", title: "Dark Mode", description: "Full support for system dark mode across all screens.", color: .purple),
            ]
        ),
        pinnedFeatures: [
            Changelog.Feature(symbol: "star.fill", title: "Favorites", description: "Add any item to your favorites. Synced with iCloud.", color: .yellow, pinBehavior: .untilMajorChanges),
            Changelog.Feature(symbol: "bookmark.circle.fill", title: "Bookmarks", description: "Save articles offline and read them anytime.", color: .orange, pinBehavior: .untilMinorChanges),
        ],
        style: ChangelogView.Style(
            primaryAction: ChangelogView.Style.PrimaryAction(
                backgroundGradient: LinearGradient(colors: [.blue, .indigo], startPoint: .bottomLeading, endPoint: .topTrailing)
            )
        )
    )
}

#Preview("No highlights") {
    ChangelogView(
        changelog: Changelog.versionOne,
        style: ChangelogView.Style(
            primaryAction: ChangelogView.Style.PrimaryAction(
                backgroundGradient: LinearGradient(colors: [.blue, .indigo], startPoint: .bottomLeading, endPoint: .topTrailing)
            )
        )
    )
}
