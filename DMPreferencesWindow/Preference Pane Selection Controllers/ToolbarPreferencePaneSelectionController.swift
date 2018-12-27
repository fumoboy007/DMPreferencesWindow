//
//  ToolbarPreferencePaneSelectionController.swift
//  DMPreferencesWindow
//
//  Created by Darren Mo on 2018-12-27.
//  Copyright © 2018 Darren Mo. All rights reserved.
//

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
