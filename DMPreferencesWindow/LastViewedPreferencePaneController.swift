//
//  LastViewedPreferencePaneController.swift
//  DMPreferencesWindow
//
//  Created by Darren Mo on 2019-01-02.
//  Copyright © 2019 Darren Mo. All rights reserved.
//

import Cocoa

class LastViewedPreferencePaneController {
   // MARK: - Initialization

   init() {
      if let lastViewedPreferencePaneIdentifierRawValue = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastViewedPreferencePaneIdentifier) {
         self.lastViewedPreferencePaneIdentifier = PreferencePaneIdentifier(rawValue: lastViewedPreferencePaneIdentifierRawValue)
      }
   }

   // MARK: - Last Viewed Preference Pane Identifier

   var lastViewedPreferencePaneIdentifier: PreferencePaneIdentifier? {
      didSet {
         UserDefaults.standard.set(lastViewedPreferencePaneIdentifier?.rawValue,
                                   forKey: UserDefaultsKeys.lastViewedPreferencePaneIdentifier)
      }
   }
}
