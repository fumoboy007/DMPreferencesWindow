//
//  PreferencePaneViewControllers.swift
//  DMPreferencesWindow
//
//  Created by Darren Mo on 2019-01-02.
//  Copyright © 2019 Darren Mo. All rights reserved.
//

import Cocoa

struct PreferencePaneViewControllers: RandomAccessCollection {
   // MARK: - Typealiases

   typealias Element = NSViewController & PreferencePane
   typealias Index = Array<Element>.Index

   // MARK: - Private Properties

   private let viewControllers: [Element]
   private let identifierToViewControllerMap: [PreferencePaneIdentifier: Element]

   // MARK: - Initialization

   init(viewControllers: [Element]) {
      precondition(!viewControllers.isEmpty,
                   "Must provide at least one preference pane view controller.")

      self.viewControllers = viewControllers

      var identifierToViewControllerMap = [PreferencePaneIdentifier: Element]()
      for viewController in viewControllers {
         let identifier = viewController.preferencePaneIdentifier
         precondition(identifierToViewControllerMap[identifier] == nil,
                      "Preference pane identifiers must be unique.")

         identifierToViewControllerMap[identifier] = viewController
      }
      self.identifierToViewControllerMap = identifierToViewControllerMap
   }

   init(_ source: PreferencePaneViewControllersWithToolbarItemImages) {
      self = source.underlyingViewControllers
   }

   // MARK: - RandomAccessCollection Conformance

   var startIndex: Index {
      return viewControllers.startIndex
   }

   var endIndex: Index {
      return viewControllers.endIndex
   }

   subscript(position: Index) -> Element {
      return viewControllers[position]
   }

   // MARK: - Looking Up By Identifier

   func contains(_ identifier: PreferencePaneIdentifier) -> Bool {
      return identifierToViewControllerMap[identifier] != nil
   }

   subscript(identifier: PreferencePaneIdentifier) -> Element {
      return identifierToViewControllerMap[identifier]!
   }
}

struct PreferencePaneViewControllersWithToolbarItemImages: RandomAccessCollection {
   // MARK: - Typealiases

   typealias Element = NSViewController & PreferencePane & ToolbarItemImageProvider
   typealias Index = PreferencePaneViewControllers.Index

   // MARK: - Private Properties

   fileprivate let underlyingViewControllers: PreferencePaneViewControllers

   // MARK: - Initialization

   init(viewControllers: [Element]) {
      self.underlyingViewControllers = PreferencePaneViewControllers(viewControllers: viewControllers)
   }

   // MARK: - RandomAccessCollection Conformance

   var startIndex: Index {
      return underlyingViewControllers.startIndex
   }

   var endIndex: Index {
      return underlyingViewControllers.endIndex
   }

   subscript(position: Index) -> Element {
      return underlyingViewControllers[position] as! Element
   }

   // MARK: - Looking Up By Identifier

   func contains(_ identifier: PreferencePaneIdentifier) -> Bool {
      return underlyingViewControllers.contains(identifier)
   }

   subscript(identifier: PreferencePaneIdentifier) -> Element {
      return underlyingViewControllers[identifier] as! Element
   }
}
