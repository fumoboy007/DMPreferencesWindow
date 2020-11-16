# DMPreferencesWindow

A preferences window suitable for a macOS app. Its user experience adheres to the [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/app-architecture/preferences/).

Requires Swift 5.3+. Tested on macOS 11. MIT license.

## User Features

- Toolbar for switching between preference panes.
- Safari-like animation when switching between preference panes.
- Automatic window title updates based on the selected preference pane.
- Restores the last viewed preference pane.
- Automatically hides the toolbar if there is only one preference pane.

## Developer Features

- Fully written in Swift. Higher confidence in code correctness.
- Implement your preference panes using view controllers.
- Use Auto Layout in your preference pane view controllers.
- Optionally pre-select a preference pane before showing the preferences window (e.g. when linking to a preference pane).
- Easy to develop a new interaction mechanism for selecting preference panes (e.g. segmented control instead of toolbar).
- Easy localization.

## Usage

```swift
class GeneralPreferencePaneViewController: NSViewController, PreferencePane, ToolbarItemImageProvider {
   init() {
      // …

      title = NSLocalizedString("General",
                                comment: "The title of the General preference pane.")
   }

   let preferencePaneIdentifier = PreferencePaneIdentifier(rawValue: "general")
   let toolbarItemImage = NSImage(named: NSImage.preferencesGeneralName)!
}
```

```swift
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
   private let preferencesWindowController: PreferencesWindowController = {
      let preferencePaneViewControllers: [NSViewController & PreferencePane & ToolbarItemImageProvider] = [
         GeneralPreferencePaneViewController(),
         // …
      ]
      return PreferencesWindowController(preferencePaneViewControllers: preferencePaneViewControllers)
   }()

   @IBAction
   private func showPreferencesWindow(_ sender: Any) {
      preferencesWindowController.showWindow(self)
   }
}
```

**Important:** Ensure that each of your preference panes has an unambiguous and fixed width and height, explicitly via width/height constraints and/or implicitly via the constraints of the subviews.
