//
//  PreferencesWindowTitleController.swift
//  DMPreferencesWindow
//
//  Created by Darren Mo on 2018-12-27.
//  Copyright © 2018 Darren Mo. All rights reserved.
//

import Cocoa

class PreferencesWindowTitleController {
   // MARK: - Initialization

   init(window: NSWindow,
        viewControllers: PreferencePaneViewControllers) {
      self.window = window
      self.viewControllers = viewControllers
      self.selectedPreferencePaneIdentifier = viewControllers.first!.preferencePaneIdentifier

      didSetSelectedPreferencePaneIdentifier()
   }

   // MARK: - Private Properties

   private let window: NSWindow
   private let viewControllers: PreferencePaneViewControllers

   // MARK: - Selected Preference Pane Identifier

   var selectedPreferencePaneIdentifier: PreferencePaneIdentifier {
      didSet {
         didSetSelectedPreferencePaneIdentifier()
      }
   }

   private var viewControllerForTitle: NSViewController {
      return viewControllers[selectedPreferencePaneIdentifier]
   }

   private func didSetSelectedPreferencePaneIdentifier() {
      titleKeyValueObservation = viewControllerForTitle.observe(\.title, options: [.initial]) { [weak self] (viewController, change) in
         self?.titleDidChange()
      }
   }

   // MARK: - Responding to Title Changes

   private var titleKeyValueObservation: NSKeyValueObservation?

   private func titleDidChange() {
      var title: String?

      // According to the macOS Human Interface Guidelines, we should only show a
      // preference-pane-specific title if there are multiple preference panes.
      if viewControllers.count > 1 {
         title = viewControllerForTitle.title
      }

      if let title = title {
         window.title = title
      } else {
         let appName = NSRunningApplication.current.localizedName ?? NSLocalizedString("App",
                                                                                       bundle: .DMPreferencesWindow,
                                                                                       comment: "A generic placeholder for the app name to be shown in the preferences window title if the app name could not be found.")
         window.title = String(format: NSLocalizedString("%1$@ Preferences",
                                                         bundle: .DMPreferencesWindow,
                                                         comment: "The format string for building a generic title for the preferences window. Argument 1 is the app name."),
                               appName)
      }
   }
}
