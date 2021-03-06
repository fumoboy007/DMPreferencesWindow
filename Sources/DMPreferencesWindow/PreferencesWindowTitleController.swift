// MIT License
//
// Copyright © 2018-2020 Darren Mo.
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

class PreferencesWindowTitleController {
   // MARK: - Initialization

   init(window: NSWindow,
        viewControllers: PreferencePaneViewControllers,
        shouldUsePreferencePaneTitleForWindowTitle: Bool) {
      self.window = window
      self.viewControllers = viewControllers
      self.shouldUsePreferencePaneTitleForWindowTitle = shouldUsePreferencePaneTitleForWindowTitle
      self.selectedPreferencePaneIdentifier = viewControllers.first!.preferencePaneIdentifier

      configureTitleKeyValueObservation()
   }

   // MARK: - Private Properties

   private let window: NSWindow
   private let viewControllers: PreferencePaneViewControllers
   private let shouldUsePreferencePaneTitleForWindowTitle: Bool

   // MARK: - Selected Preference Pane Identifier

   var selectedPreferencePaneIdentifier: PreferencePaneIdentifier {
      didSet {
         configureTitleKeyValueObservation()
      }
   }

   private var viewControllerForTitle: NSViewController {
      return viewControllers[selectedPreferencePaneIdentifier]
   }

   private func configureTitleKeyValueObservation() {
      titleKeyValueObservation = viewControllerForTitle.observe(\.title, options: [.initial]) { [weak self] (viewController, change) in
         self?.titleDidChange()
      }
   }

   // MARK: - Responding to Title Changes

   private var titleKeyValueObservation: NSKeyValueObservation?

   private func titleDidChange() {
      var title: String?

      if shouldUsePreferencePaneTitleForWindowTitle {
         title = viewControllerForTitle.title
      }

      if let title = title {
         window.title = title
      } else {
         let appName = NSRunningApplication.current.localizedName ?? NSLocalizedString("App",
                                                                                       bundle: .module,
                                                                                       comment: "A generic placeholder for the app name to be shown in the preferences window title if the app name could not be found.")
         window.title = String(format: NSLocalizedString("%1$@ Preferences",
                                                         bundle: .module,
                                                         comment: "The format string for building a generic title for the preferences window. Argument 1 is the app name."),
                               locale: Locale.current,
                               appName)
      }
   }
}
