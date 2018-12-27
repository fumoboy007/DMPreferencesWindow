//
//  PreferencesWindowViewController.swift
//  DMPreferencesWindow
//
//  Created by Darren Mo on 2018-12-27.
//  Copyright © 2018 Darren Mo. All rights reserved.
//

import Cocoa

class PreferencesWindowViewController: NSViewController {
   // MARK: - Private Properties

   private let viewControllers: PreferencePaneViewControllers

   // MARK: - Initialization

   init(viewControllers: PreferencePaneViewControllers) {
      self.viewControllers = viewControllers

      self._visiblePreferencePaneIdentifier = viewControllers.first!.preferencePaneIdentifier

      super.init(nibName: nil, bundle: nil)

      for viewController in viewControllers {
         addChild(viewController)
      }

      setVisiblePreferencePaneIdentifierWithoutAnimation(visiblePreferencePaneIdentifier)
   }

   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   override func loadView() {
      view = NSView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
   }

   override func viewDidLoad() {
      super.viewDidLoad()

      let maxSubviewWidth = calculateMaxSubviewWidth()
      activateWidthConstraints(maxSubviewWidth: maxSubviewWidth)
   }

   // MARK: - Activating the Width Constraints

   private var requiredPriorityWidthConstraint: NSLayoutConstraint!
   private var highPriorityWidthConstraint: NSLayoutConstraint!

   private func calculateMaxSubviewWidth() -> CGFloat {
      return viewControllers.lazy.map { $0.view.fittingSize.width }.max()!.rounded()
   }

   private func activateWidthConstraints(maxSubviewWidth: CGFloat) {
      requiredPriorityWidthConstraint = view.widthAnchor.constraint(greaterThanOrEqualToConstant: maxSubviewWidth)

      highPriorityWidthConstraint = view.widthAnchor.constraint(equalToConstant: maxSubviewWidth)
      highPriorityWidthConstraint.priority = .defaultHigh

      NSLayoutConstraint.activate([
         requiredPriorityWidthConstraint,
         highPriorityWidthConstraint
      ])
   }

   // MARK: - Visible Preference Pane Identifier

   private var _visiblePreferencePaneIdentifier: PreferencePaneIdentifier
   var visiblePreferencePaneIdentifier: PreferencePaneIdentifier {
      get {
         return _visiblePreferencePaneIdentifier
      }

      set {
         setVisiblePreferencePaneIdentifier(newValue, animated: false)
      }
   }

   func setVisiblePreferencePaneIdentifier(_ newVisiblePreferencePaneIdentifier: PreferencePaneIdentifier,
                                           animated: Bool) {
      guard newVisiblePreferencePaneIdentifier != visiblePreferencePaneIdentifier else {
         return
      }

      currentAnimationUUID = nil

      if animated {
         setVisiblePreferencePaneIdentifierWithAnimation(newVisiblePreferencePaneIdentifier)
      } else {
         setVisiblePreferencePaneIdentifierWithoutAnimation(newVisiblePreferencePaneIdentifier)
      }
   }

   // MARK: - With Animation

   private var currentAnimationUUID: UUID?

   // For consistency, use the same animation as Safari:
   //   1. Hide old subview.
   //   2. Animate window to new height.
   //   3. Show new subview.
   private func setVisiblePreferencePaneIdentifierWithAnimation(_ newVisiblePreferencePaneIdentifier: PreferencePaneIdentifier) {
      let oldVisibleViewController = viewControllers[visiblePreferencePaneIdentifier]
      oldVisibleViewController.view.removeFromSuperview()

      _visiblePreferencePaneIdentifier = newVisiblePreferencePaneIdentifier

      let newVisibleViewController = viewControllers[newVisiblePreferencePaneIdentifier]
      let newVisibleSubview = newVisibleViewController.view
      view.addSubview(newVisibleSubview)

      newVisibleSubview.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
         newVisibleSubview.topAnchor.constraint(equalTo: view.topAnchor),
         newVisibleSubview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         newVisibleSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor)
      ])

      guard let window = view.window else {
         return
      }

      let animationUUID = UUID()
      currentAnimationUUID = animationUUID

      newVisibleSubview.isHidden = true
      NSAnimationContext.runAnimationGroup({ context in
         let newWindowFrame = PreferencesWindowViewController.estimateFrame(for: window,
                                                                            visibleSubview: newVisibleSubview)
         context.duration = window.animationResizeTime(newWindowFrame)
         context.allowsImplicitAnimation = true

         window.layoutIfNeeded()
      }, completionHandler: {
         let isCancelled = self.currentAnimationUUID != animationUUID
         guard !isCancelled else {
            return
         }
         self.currentAnimationUUID = nil

         newVisibleSubview.isHidden = false
      })
   }

   // MARK: - Without Animation

   private func setVisiblePreferencePaneIdentifierWithoutAnimation(_ newVisiblePreferencePaneIdentifier: PreferencePaneIdentifier) {
      let oldVisibleViewController = viewControllers[visiblePreferencePaneIdentifier]
      oldVisibleViewController.view.removeFromSuperview()

      _visiblePreferencePaneIdentifier = newVisiblePreferencePaneIdentifier

      let newVisibleViewController = viewControllers[newVisiblePreferencePaneIdentifier]
      let newVisibleSubview = newVisibleViewController.view
      newVisibleSubview.isHidden = false
      view.addSubview(newVisibleSubview)

      newVisibleSubview.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
         newVisibleSubview.topAnchor.constraint(equalTo: view.topAnchor),
         newVisibleSubview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         newVisibleSubview.centerXAnchor.constraint(equalTo: view.centerXAnchor)
      ])
   }

   // MARK: - Estimating the Window Frame

   private static func estimateFrame(for window: NSWindow,
                                     visibleSubview: NSView) -> NSRect {
      var newWindowContentSize = visibleSubview.fittingSize
      newWindowContentSize.width.round()
      newWindowContentSize.height.round()

      let newWindowContentRect = NSRect(origin: CGPoint.zero,
                                        size: newWindowContentSize)
      let newWindowFrameSize = window.frameRect(forContentRect: newWindowContentRect).size

      // Maintain the top-left point of the window
      let windowFrameHeightDelta = newWindowFrameSize.height - window.frame.height
      var newWindowFrameOrigin = window.frame.origin
      newWindowFrameOrigin.y -= windowFrameHeightDelta

      return NSRect(origin: newWindowFrameOrigin,
                    size: NSSize(width: window.frame.width,
                                 height: newWindowFrameSize.height))
   }
}