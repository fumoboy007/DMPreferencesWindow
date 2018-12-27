//
//  PreferencePaneSelectionController.swift
//  DMPreferencesWindow
//
//  Created by Darren Mo on 2018-12-27.
//  Copyright © 2018 Darren Mo. All rights reserved.
//

import Cocoa

protocol PreferencePaneSelectionController: class {
   var selectedPreferencePaneIdentifier: PreferencePaneIdentifier { get set }

   var delegate: PreferencePaneSelectionControllerDelegate? { get set }
}

protocol PreferencePaneSelectionControllerDelegate: class {
   func preferencePaneSelectionControllerDidChangeSelectedPreferencePaneIdentifier(_ selectionController: PreferencePaneSelectionController)
}
