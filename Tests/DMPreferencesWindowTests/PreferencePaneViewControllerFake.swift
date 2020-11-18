// MIT License
//
// Copyright © 2020 Darren Mo.
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

@testable import DMPreferencesWindow

import Cocoa

class PreferencePaneViewControllerFake: NSViewController, PreferencePane, ToolbarItemImageProvider {
   // MARK: - Initialization

   init(preferencePaneIdentifier: PreferencePaneIdentifier) {
      self.preferencePaneIdentifier = preferencePaneIdentifier

      super.init(nibName: nil, bundle: nil)

      title = PreferencePaneViewControllerFake.makeTitle(for: preferencePaneIdentifier)
   }

   required init?(coder: NSCoder) {
      fatalError("`init(coder:)` has not been implemented.")
   }

   // MARK: - Preference Pane

   let preferencePaneIdentifier: PreferencePaneIdentifier
   let toolbarItemImage = NSImage(named: NSImage.preferencesGeneralName)!

   // MARK: - Title

   static func makeTitle(for preferencePaneIdentifier: PreferencePaneIdentifier) -> String {
      return "`\(preferencePaneIdentifier.rawValue)` Preference Pane"
   }

   // MARK: - Loading the View

   private static let labelFontSize: CGFloat = 21

   /**
    Creates and loads the view.

    We can’t use Interface Builder because there is no Xcode command line interface to build a Swift Package Manager project.
    (Only the Xcode build system can process XIB files.)
    */
   override func loadView() {
      view = NSView()

      let label = NSTextField(labelWithString: "Fake Preference Pane")
      label.font = NSFont.systemFont(ofSize: PreferencePaneViewControllerFake.labelFontSize)
      view.addSubview(label)

      label.translatesAutoresizingMaskIntoConstraints = false
      label.setContentHuggingPriority(.required, for: .horizontal)
      label.setContentHuggingPriority(.required, for: .vertical)
      label.setContentCompressionResistancePriority(.required, for: .horizontal)
      label.setContentCompressionResistancePriority(.required, for: .vertical)
      NSLayoutConstraint.activate([
         label.topAnchor.constraint(equalTo: view.topAnchor,
                                    constant: PreferencePaneViewControllerFake.labelFontSize),
         view.bottomAnchor.constraint(equalTo: label.bottomAnchor,
                                      constant: PreferencePaneViewControllerFake.labelFontSize),
         label.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                        constant: PreferencePaneViewControllerFake.labelFontSize),
         view.trailingAnchor.constraint(equalTo: label.trailingAnchor,
                                        constant: PreferencePaneViewControllerFake.labelFontSize),
      ])
   }
}
