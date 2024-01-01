<p align="center">
    <img src="ChangelogKit_Logo.png" width="20%" alt="Logo">
</p>

<h1 align="center">
    ChangelogKit
</h1>


A Swift package designed to easily show the new features of your app.

### Why

I had the need to develop a view to showcase the new features of my app and I did not want to rely on something external. This is why I deveoped ChangelogKit.
Take this as is and use it as you want. 

### Information

This is developed for SwiftUI and the minimum iOS target is iOS 17. The code is documented using the Xcode markup. 

### How to use it

You create a `Changelog` object that is then passed to the `ChangelogView` that will render it. 
A changelog is composed of: 
- title (that will be visible on top of the `ChangelogView`)
- version (used as a title in case title is nil)
- set of features

A `Feature` has these properties:
- symbol that is a `String` and is the image shown on the left of a feature
- title
- description
- color that is used as a tint for the symbol

There is also the possibility to style the view. You can check the `ChangelogView.Style` structure to learn more about it. 

There is also a handy modifier to show the changelog view, using `changelogView(changelog:style:show:onDismiss:)`. 

### Result

This is how a `ChangelogView` could be rendered. 

<p align="center">
    <img src="Screenshot.png" width="30%" alt="Logo">
</p>
