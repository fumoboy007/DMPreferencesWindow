// MIT License
//
// Copyright © 2018-2019 Darren Mo.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa

class ToolbarPreferencePaneSelectionController: NSObject, PreferencePaneSelectionController, NSToolbarDelegate {
   // MARK: - Private Properties

   private let window: NSWindow
   private let toolbar: NSToolbar

   private let viewControllers: PreferencePaneViewControllersWithToolbarItemImages
   private var titleKeyValueObservations: [NSKeyValueObservation]!

   // MARK: - Initialization

   init(window: NSWindow,
        viewControllers: PreferencePaneViewControllersWithToolbarItemImages) {
      self.window = window
      self.viewControllers = viewControllers

      let toolbar = NSToolbar()
      toolbar.showsBaselineSeparator = true
      for (idx, viewController) in viewControllers.enumerated() {
         let identifier = NSToolbarItem.Identifier(rawValue: viewController.preferencePaneIdentifier.rawValue)
         toolbar.insertItem(withItemIdentifier: identifier, at: idx)
      }
      self.toolbar = toolbar

      self._selectedPreferencePaneIdentifier = viewControllers.first!.preferencePaneIdentifier

      super.init()

      toolbar.delegate = self
      window.toolbar = toolbar

      didSetSelectedPreferencePaneIdentifier()

      titleKeyValueObservations = viewControllers.enumerated().map { idxAndViewController in
         let (idx, viewController) = idxAndViewController
         return (viewController as NSViewController).observe(\.title, options: [.initial]) { [weak self] (viewController, change) in
            self?.titleDidChange(forViewControllerAt: idx)
         }
      }
   }

   // MARK: - Delegate

   weak var delegate: PreferencePaneSelectionControllerDelegate?

   // MARK: - Selected Preference Pane Identifier

   private var _selectedPreferencePaneIdentifier: PreferencePaneIdentifier
   var selectedPreferencePaneIdentifier: PreferencePaneIdentifier {
      get {
         return _selectedPreferencePaneIdentifier
      }

      set {
         _selectedPreferencePaneIdentifier = newValue

         didSetSelectedPreferencePaneIdentifier()
      }
   }

   private func didSetSelectedPreferencePaneIdentifier() {
      toolbar.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue: selectedPreferencePaneIdentifier.rawValue)
   }

   // MARK: - NSToolbarDelegate Conformance

   func toolbar(_ toolbar: NSToolbar,
                itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
      let viewController = viewControllers[PreferencePaneIdentifier(rawValue: itemIdentifier.rawValue)]
      let title = ToolbarPreferencePaneSelectionController.title(from: viewController)
      let image = viewController.toolbarItemImage

      let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
      toolbarItem.label = title
      toolbarItem.image = image
      toolbarItem.target = self
      toolbarItem.action = #selector(performToolbarItemAction(_:))

      return toolbarItem
   }

   func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
      return viewControllers.map { NSToolbarItem.Identifier(rawValue: $0.preferencePaneIdentifier.rawValue) }
   }

   func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
      return viewControllers.map { NSToolbarItem.Identifier(rawValue: $0.preferencePaneIdentifier.rawValue) }
   }

   func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
      return viewControllers.map { NSToolbarItem.Identifier(rawValue: $0.preferencePaneIdentifier.rawValue) }
   }

   // MARK: - Performing the Toolbar Item Action

   @objc
   private func performToolbarItemAction(_ sender: Any) {
      _selectedPreferencePaneIdentifier = PreferencePaneIdentifier(rawValue: toolbar.selectedItemIdentifier!.rawValue)

      delegate?.preferencePaneSelectionControllerDidChangeSelectedPreferencePaneIdentifier(self)
   }

   // MARK: - Responding to Title Changes

   private static func title(from viewController: NSViewController) -> String {
      return viewController.title ?? NSLocalizedString("Preferences",
                                                       bundle: .DMPreferencesWindow,
                                                       comment: "The title of the toolbar item in the preferences window if no custom title is given.")
   }

   private func titleDidChange(forViewControllerAt idx: Int) {
      let viewController = viewControllers[idx]

      let toolbarItem = toolbar.items[idx]
      toolbarItem.label = ToolbarPreferencePaneSelectionController.title(from: viewController)
   }
}
