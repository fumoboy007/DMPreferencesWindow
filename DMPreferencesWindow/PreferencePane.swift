//
//  PreferencePane.swift
//  DMPreferencesWindow
//
//  Created by Darren Mo on 2018-12-27.
//  Copyright © 2018 Darren Mo. All rights reserved.
//

public struct PreferencePaneIdentifier: RawRepresentable, Hashable {
   public typealias RawValue = String

   public init(rawValue: RawValue) {
      self.rawValue = rawValue
   }

   public var rawValue: RawValue
}

public protocol PreferencePane {
   var preferencePaneIdentifier: PreferencePaneIdentifier { get }
}
