// swift-tools-version:5.3

import PackageDescription

let package = Package(
   name: "DMPreferencesWindow",
   defaultLocalization: "en",
   platforms: [
      .macOS(.v10_13),
   ],
   products: [
      .library(
         name: "DMPreferencesWindow",
         targets: [
            "DMPreferencesWindow",
         ]
      ),
   ],
   targets: [
      .target(
         name: "DMPreferencesWindow"
      ),
   ]
)
