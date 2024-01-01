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
    let changelog: Changelog
    var style: Style
    
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


// MARK: - Style

public extension ChangelogView {
    struct Style {
        var view: View                      = View()
        var title: Title                    = Title()
        var features: Features              = Features()
        var primaryAction: PrimaryAction    = PrimaryAction()
        
        struct View {
            var spacingBetweenFeatures: CGFloat = 10
        }
        
        struct Title {
            var font: Font      = .largeTitle.weight(.heavy)
            var color: Color    = Color(UIColor.label)
        }
        
        struct Features {
            var titleFont: Font                 = .headline
            var descriptionFont: Font           = .subheadline
            var titleTextColor: Color           = Color(UIColor.label)
            var descriptionTextColor: Color     = Color(UIColor.label)
        }
        
        struct PrimaryAction {
            var font: Font                              = .title3.weight(.bold)
            var cornerRadius: CGFloat                   = 14
            var backgroundColor: Color                  = .accentColor
            var backgroundGradient: LinearGradient?
            var textColor: Color                        = .white
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
