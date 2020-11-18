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

import XCTest

final class PreferencesWindowControllerTests: XCTestCase {
   // MARK: - Tests

   func testSinglePreferencePane() {
      let preferencePaneIdentifier = PreferencePaneIdentifier(rawValue: "fake")
      let preferencesWindowController = makePreferencesWindowController(
         preferencePaneIdentifiers: [
            .init(rawValue: "fake")
         ]
      )

      preferencesWindowController.showWindow(nil)

      XCTAssertNotEqual(preferencesWindowController.window?.title,
                        PreferencePaneViewControllerFake.makeTitle(for: preferencePaneIdentifier),
                        "According to the macOS Human Interface Guidelines, the preferences window title should be “[App Name] Preferences” if there is only one preference pane.")
   }

   func testMultiplePreferencePanes() {
      let preferencePaneIdentifier1 = PreferencePaneIdentifier(rawValue: "fake1")
      let preferencePaneIdentifier2 = PreferencePaneIdentifier(rawValue: "fake2")
      let preferencesWindowController = makePreferencesWindowController(
         preferencePaneIdentifiers: [
            preferencePaneIdentifier1,
            preferencePaneIdentifier2
         ]
      )

      preferencesWindowController.showWindow(selecting: preferencePaneIdentifier1)

      XCTAssertEqual(preferencesWindowController.window?.title,
                     PreferencePaneViewControllerFake.makeTitle(for: preferencePaneIdentifier1))

      preferencesWindowController.showWindow(selecting: preferencePaneIdentifier2)

      XCTAssertEqual(preferencesWindowController.window?.title,
                     PreferencePaneViewControllerFake.makeTitle(for: preferencePaneIdentifier2))
   }

   // MARK: - Private

   private func makePreferencesWindowController(preferencePaneIdentifiers: [PreferencePaneIdentifier]) -> PreferencesWindowController {
      let preferencePaneViewControllers = preferencePaneIdentifiers.map(PreferencePaneViewControllerFake.init(preferencePaneIdentifier:))
      let preferencesWindowController = PreferencesWindowController(preferencePaneViewControllers: preferencePaneViewControllers)

      addTeardownBlock {
         preferencesWindowController.close()
      }

      return preferencesWindowController
   }
}
