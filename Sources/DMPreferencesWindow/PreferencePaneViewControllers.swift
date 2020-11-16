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
