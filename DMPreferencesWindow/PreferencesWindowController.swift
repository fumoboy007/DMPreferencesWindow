//
//  PreferencesWindowController.swift
//  DMPreferencesWindow
//
//  Created by Darren Mo on 2018-12-27.
//  Copyright © 2018 Darren Mo. All rights reserved.
//

import Cocoa

public class PreferencesWindowController: NSWindowController, PreferencePaneSelectionControllerDelegate {
   // MARK: - Private Properties

   private let lastViewedPreferencePaneController = LastViewedPreferencePaneController()
   private let selectionController: PreferencePaneSelectionController
   private let windowViewController: PreferencesWindowViewController
   private var windowTitleController: PreferencesWindowTitleController

   // MARK: - Initialization

   public convenience init(preferencePaneViewControllers: [NSViewController & PreferencePane & ToolbarItemImageProvider]) {
      let window = PreferencesWindowController.makeWindow()
      let viewControllers = PreferencePaneViewControllersWithToolbarItemImages(viewControllers: preferencePaneViewControllers)

      let selectionController = ToolbarPreferencePaneSelectionController(window: window,
                                                                         viewControllers: viewControllers)

      self.init(window: window,
                selectionController: selectionController,
                viewControllers: PreferencePaneViewControllers(viewControllers))
   }

   private static func makeWindow() -> NSWindow {
      let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
                            styleMask: [.closable, .titled],
                            backing: .buffered,
                            defer: true)
      window.identifier = NSUserInterfaceItemIdentifier(rawValue: "DMPreferencesWindow.window")
      return window
   }

   private init(window: NSWindow,
                selectionController: PreferencePaneSelectionController,
                viewControllers: PreferencePaneViewControllers) {
      self.selectionController = selectionController
      self.windowViewController = PreferencesWindowViewController(viewControllers: viewControllers)
      self.windowTitleController = PreferencesWindowTitleController(window: window,
                                                                    viewControllers: viewControllers)

      super.init(window: window)

      let initialSelectedPreferencePaneIdentifier = self.initialSelectedPreferencePaneIdentifier(viewControllers: viewControllers)
      selectionController.selectedPreferencePaneIdentifier = initialSelectedPreferencePaneIdentifier
      windowViewController.visiblePreferencePaneIdentifier = initialSelectedPreferencePaneIdentifier
      windowTitleController.selectedPreferencePaneIdentifier = initialSelectedPreferencePaneIdentifier
      lastViewedPreferencePaneController.lastViewedPreferencePaneIdentifier = initialSelectedPreferencePaneIdentifier

      window.contentViewController = windowViewController
      selectionController.delegate = self
   }

   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   private func initialSelectedPreferencePaneIdentifier(viewControllers: PreferencePaneViewControllers) -> PreferencePaneIdentifier {
      if let lastViewedPreferencePaneIdentifier = lastViewedPreferencePaneController.lastViewedPreferencePaneIdentifier {
         if viewControllers.contains(lastViewedPreferencePaneIdentifier) {
            return lastViewedPreferencePaneIdentifier
         }
      }

      return viewControllers.first!.preferencePaneIdentifier
   }

   // MARK: - Showing the Window

   private var hasBeenShown = false

   public override func showWindow(_ sender: Any?) {
      super.showWindow(sender)

      if !hasBeenShown {
         hasBeenShown = true

         if let window = window {
            window.layoutIfNeeded()
            window.center()
         }
      }
   }

   public func showWindow(_ sender: Any?,
                          selecting preferencePaneIdentifier: PreferencePaneIdentifier) {
      selectionController.selectedPreferencePaneIdentifier = preferencePaneIdentifier
      preferencePaneSelectionControllerDidChangeSelectedPreferencePaneIdentifier(selectionController)

      showWindow(sender)
   }

   // MARK: - Responding to Selected Preference Pane Identifier Changes

   func preferencePaneSelectionControllerDidChangeSelectedPreferencePaneIdentifier(_ selectionController: PreferencePaneSelectionController) {
      let selectedPreferencePaneIdentifier = selectionController.selectedPreferencePaneIdentifier

      windowViewController.setVisiblePreferencePaneIdentifier(selectedPreferencePaneIdentifier,
                                                              animated: true)
      windowTitleController.selectedPreferencePaneIdentifier = selectedPreferencePaneIdentifier
      lastViewedPreferencePaneController.lastViewedPreferencePaneIdentifier = selectedPreferencePaneIdentifier
   }
}
