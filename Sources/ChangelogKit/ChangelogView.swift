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
//        .background {
//            RoundedRectangle(cornerRadius: 14)
//                .fill(.shadow(.inner(radius: 4)))
//                .foregroundStyle(.white.opacity(0.1))
//        }
    }
}


// MARK: - Changelog View

public struct ChangelogView: View {
    
    @Environment(\.dismiss) private var dismiss
    public let changelog: Changelog
    public var style: Style
    
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
                print("done")
            }, label: {
                Text("Done")
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
    
    func changelogView(changelog: Changelog, style: ChangelogView.Style = ChangelogView.Style(), show: Binding<Bool>) -> some View {
        self.sheet(isPresented: show, content: {
            ChangelogView(changelog: changelog, style: style)
        })
    }
}


// MARK: - Style

extension ChangelogView {
    public struct Style {
        public var view: View                      = View()
        public var title: Title                    = Title()
        public var features: Features              = Features()
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
        
        public struct View {
            public var spacingBetweenFeatures: CGFloat
            
            public init(spacingBetweenFeatures: CGFloat = 10) {
                self.spacingBetweenFeatures = spacingBetweenFeatures
            }
        }
        
        public struct Title {
            public var font: Font
            public var color: Color
            
            public init(
                font: Font      = .largeTitle.weight(.heavy),
                color: Color    = Color(UIColor.label))
            {
                self.font = font
                self.color = color
            }
        }
        
        public struct Features {
            public var titleFont: Font
            public var descriptionFont: Font
            public var titleTextColor: Color
            public var descriptionTextColor: Color
            
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
        
        public struct PrimaryAction {
            public var font: Font
            public var cornerRadius: CGFloat
            public var backgroundColor: Color
            public var backgroundGradient: LinearGradient?
            public var textColor: Color
            
            public init(
                font: Font                          = .title3.weight(.bold),
                cornerRadius: CGFloat               = 14,
                backgroundColor: Color              = .accentColor,
                backgroundGradient: LinearGradient? = nil,
                textColor: Color                    = .white)
            {
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
