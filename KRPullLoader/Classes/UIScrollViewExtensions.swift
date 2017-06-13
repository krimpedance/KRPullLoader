//
//  UIScrollViewExtensions.swift
//  KRPullLoader
//
//  Copyright © 2017年 Krimpedance. All rights reserved.
//

import UIKit

// MARK: - Public extensions ---------------

extension UIScrollView {
   /**
    Adds the PullLoadableView.

    - parameter loadView: view that contain KRPullLoadable.
    - parameter type:     KRPullLoaderType. Default type is `.refresh`.
    */
   public func addPullLoadableView<T>(_ loadView: T, type: KRPullLoaderType = .refresh) where T: UIView, T: KRPullLoadable {
      let loader = KRPullLoader(loadView: loadView, type: type)
      insertSubview(loader, at: 0)
      loader.setUp()
   }

   /**
    Remove the PullLoadableView.

    - parameter loadView: view which inherited KRPullLoadable protocol.
    */
   public func removePullLoadableView<T>(_ loadView: T) where T: UIView, T: KRPullLoadable {
      guard let loader = loadView.superview as? KRPullLoader<T> else { return }
      loader.tearDown()
   }
}

// MARK: - Internal extensions ---------------

extension UIScrollView {
   var distanceOffset: CGPoint {
      get {
         return CGPoint(
            x: contentOffset.x + contentInset.left,
            y: contentOffset.y + contentInset.top
         )
      }
      set {
         contentOffset = CGPoint(
            x: newValue.x - contentInset.left,
            y: newValue.y - contentInset.top
         )
      }
   }

   var distanceEndOffset: CGPoint {
      get {
         return CGPoint(
            x: (contentSize.width + contentInset.right) - (contentOffset.x + bounds.width),
            y: (contentSize.height + contentInset.bottom) - (contentOffset.y + bounds.height)
         )
      }
      set {
         contentOffset = CGPoint(
            x: newValue.x - (bounds.width - (contentSize.width + contentInset.right)),
            y: newValue.y - (bounds.height - (contentSize.height + contentInset.bottom))
         )
      }
   }
}
