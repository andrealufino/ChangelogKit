//
//  View+ChangelogKit.swift
//
//
//  Created by Andrea Mario Lufino on 03/01/24.
//

import Foundation
import SwiftUI


// MARK: - View modifier

public extension View {
    
    @ViewBuilder
    /// Show the changelog view when the binding value is `true`.
    /// - Parameters:
    ///   - isPresented: The binding value used to show the view.
    ///   - changelog: The changelog object to render.
    ///   - style: The style of the user interface.
    ///   - onDismiss: The code to perform when view is dismissed. Default is `nil`.
    /// - Returns: A new view.
    func sheet(
        isPresented: Binding<Bool>,
        changelog: Changelog,
        style: ChangelogView.Style = ChangelogView.Style(),
        onDismiss: (() -> Void)? = nil) -> some View
    {
        self.modifier(
            ChangelogViewPresenter(
                isPresented: isPresented,
                changelog: changelog,
                style: style,
                onDismiss: onDismiss
            )
        )
    }
    
    @ViewBuilder
    /// This automatically shows up the `ChangelogView` if needed.
    ///
    /// This check if the changelog for this version has already been displayed to the user
    /// and, if not, it shows it. If it has already been displayed, it simply does nothing.
    ///
    /// > Note:
    /// During your debug session you can set the `debug` parameter to true to always show
    /// the view, regardless of if it has already been displayed or not.
    /// - Parameters:
    ///   - isPresented: The binding value used to show or hide the view.
    ///   - provider: The changelogs provider with the collection of changelogs.
    ///   - style: The style of the user interface.
    ///   - debug: When set to `true` this will ignore if the current version changelog has already been displayed and will display it anyway. Default is `false`.
    ///   - onDismiss: The code to perform when view dismissed. Default is `nil`.
    /// - Returns: A new view.
    func showCurrentChangelogIfNeeded(
        isPresented: Binding<Bool>,
        provider: ChangelogsCollectionProvider,
        style: ChangelogView.Style = ChangelogView.Style(),
        debug: Bool = false,
        onDismiss: (() -> Void)? = nil) -> some View
    {
        self.modifier(
            ChangelogViewPresenter(
                isPresented: isPresented,
                provider: provider,
                changelog: nil,
                style: style,
                debug: debug,
                onDismiss: onDismiss
            )
        )
    }
}
