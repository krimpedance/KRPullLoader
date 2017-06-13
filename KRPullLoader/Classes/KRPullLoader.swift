//
//  KRPullLoader.swift
//  KRPullLoader
//
//  Copyright © 2017年 Krimpedance. All rights reserved.
//

import UIKit

/**
 Type of KRPullLoader's position.

 - refresh:  At the head of UIScrollView's scroll direction
 - loadMore: At the tail of UIScrollView's scroll direction
 */
public enum KRPullLoaderType {
   case refresh, loadMore
}

/**
 State of KRPullLoader

 - none:    hides the view.
 - pulling: Pulling.
            `offset` is pull offset (always <= 0).
            This state changes to `loading` when `offset` exceeded `threshold`.
 - loading: Shows the view.
            You should call `completionHandler` when some actions have been completed.
 */
public enum KRPullLoaderState {
   case none
   case pulling(offset: CGPoint, threshold: CGFloat)
   case loading(completionHandler: ()->Void)
}

/**
 KRPullLoadable is a protocol for views added to UIScrollView.
 */
public protocol KRPullLoadable: class {
   /**
    Handler when KRPullLoaderState value changed.

    - parameter state: New state.
    - parameter type:  KRPullLoaderType.
    */
   func didChangeState(_ state: KRPullLoaderState, viewType type: KRPullLoaderType)
}

class KRPullLoader<T>: UIView where T: UIView, T: KRPullLoadable {

   let loadView: T
   let type: KRPullLoaderType
   var addedLoadingInset = CGFloat(0)

   var scrollView: UIScrollView? {
      return superview as? UIScrollView
   }

   var scrollDirection: UICollectionViewScrollDirection {
      return ((superview as? UICollectionView)?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection ?? .vertical
   }

   var state = KRPullLoaderState.none {
      didSet {
         loadView.didChangeState(state, viewType: type)
      }
   }

   init(loadView: T, type: KRPullLoaderType) {
      self.loadView = loadView
      self.type = type
      super.init(frame: loadView.bounds)
      addSubview(loadView)
   }

   required init?(coder aDecoder: NSCoder) { fatalError() }

   override func layoutSubviews() {
      super.layoutSubviews()
      adjustLayoutConstraints()
   }

   override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      guard let key = keyPath else { return }

      switch (key, state) {
      case (_, .loading): return

      case ("contentSize", _):
         checkScrollViewContentSize()

      default:
         if !isHidden { updateState() }
      }
   }
}

// MARK: - Actions -------------------

extension KRPullLoader {
   func setUp() {
      checkScrollViewContentSize()
      addObservers()
   }

   func tearDown() {
      removeObservers()
      loadView.removeFromSuperview()
      removeFromSuperview()
   }

   func addObservers() {
      superview?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
      superview?.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
   }

   func removeObservers() {
      superview?.removeObserver(self, forKeyPath: "contentOffset")
      superview?.removeObserver(self, forKeyPath: "contentSize")
   }

   func checkScrollViewContentSize() {
      guard let scrollView = scrollView, type == .loadMore else { return }
      let isHidden = self.isHidden
      self.isHidden = scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom < scrollView.bounds.height
      if self.isHidden || !isHidden { return }
      adjustLayoutConstraints()
   }

   func updateState() {
      guard let scrollView = scrollView else { return }
      let offset = type == .refresh ? scrollView.distanceOffset : scrollView.distanceEndOffset
      let offsetValue = scrollDirection == .vertical ? offset.y : offset.x
      let threshold = scrollDirection == .vertical ? bounds.height : bounds.width

      if scrollView.isDecelerating && offsetValue < -threshold {
         state = .loading(completionHandler: endLoading)
         startLoading()
      } else if offsetValue < 0 {
         state = .pulling(offset: offset, threshold: -(threshold + 12))
      } else {
         state = .none
      }
   }
}

// MARK: - Layouts -------------------

extension KRPullLoader {
   func adjustLayoutConstraints() {
      guard let scrollView = scrollView else { return }

      // clear constraints
      loadView.removeFromSuperview()
      addSubview(loadView)
      removeFromSuperview()
      scrollView.addSubview(self)

      clipsToBounds = true
      translatesAutoresizingMaskIntoConstraints = false
      loadView.translatesAutoresizingMaskIntoConstraints = false

      let attributes = [NSLayoutAttribute]([.top, .left, .right, .bottom])
      let constraints = attributes.map {
         NSLayoutConstraint(item: loadView, attribute: $0, relatedBy: .equal, toItem: self, attribute: $0, multiplier: 1.0, constant: 0.0)
      }
      addConstraints(constraints)

      scrollDirection == .vertical ? adjustVerticalScrollLayoutConstraints() : adjustHorizontalScrollLayoutConstraints()

      if addedLoadingInset == 0 { return }

      switch (scrollDirection, type) {
      case (.vertical, .refresh):
         scrollView.contentInset.top += bounds.height - addedLoadingInset
         scrollView.distanceOffset.y = 0

      case (.vertical, .loadMore):
         scrollView.contentInset.bottom += bounds.height - addedLoadingInset
         scrollView.distanceEndOffset.y = 0

      case (.horizontal, .refresh):
         scrollView.contentInset.left += bounds.width - addedLoadingInset
         scrollView.distanceOffset.x = 0

      case (.horizontal, .loadMore):
         scrollView.contentInset.bottom += bounds.width - addedLoadingInset
         scrollView.distanceEndOffset.x = 0
      }

      addedLoadingInset = scrollDirection == .vertical ? bounds.height : bounds.width
   }

   func adjustVerticalScrollLayoutConstraints() {
      guard let scrollView = scrollView else { return }

      let constant = type == .refresh ?
         -(scrollView.contentInset.top + bounds.height - addedLoadingInset) :
         scrollView.contentSize.height + scrollView.contentInset.bottom - addedLoadingInset

      let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: constant)

      scrollView.addConstraints([
         constraint,
         NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
         NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1.0, constant: 0.0)
      ])
   }

   func adjustHorizontalScrollLayoutConstraints() {
      guard let scrollView = scrollView else { return }

      let constant = type == .refresh ?
         -(scrollView.contentInset.left + bounds.width - addedLoadingInset) :
         scrollView.contentSize.width + scrollView.contentInset.right - addedLoadingInset

      let constraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1.0, constant: constant)

      scrollView.addConstraints([
         constraint,
         NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
         NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1.0, constant: 0.0)
      ])
   }
}

// MARK: - Loading actions -------------------

extension KRPullLoader {
   func startLoading() {
      addedLoadingInset = scrollDirection == .vertical ? bounds.height : bounds.width
      animateScrollViewInset(isShow: true)
   }

   func endLoading() {
      animateScrollViewInset(isShow: false) {
         self.state = .none
         self.addedLoadingInset = 0
      }
   }

   func animateScrollViewInset(isShow: Bool, completion: (() -> Void)? = nil) {
      UIView.animate(withDuration: 0.2, animations: {
         switch (self.scrollDirection, self.type) {
         case (.vertical, .refresh):
            self.scrollView?.contentInset.top += isShow ? self.addedLoadingInset : -self.addedLoadingInset
         case (.vertical, .loadMore):
            self.scrollView?.contentInset.bottom += isShow ? self.addedLoadingInset : -self.addedLoadingInset
         case (.horizontal, .refresh):
            self.scrollView?.contentInset.left += isShow ? self.addedLoadingInset : -self.addedLoadingInset
         case (.horizontal, .loadMore):
            self.scrollView?.contentInset.right += isShow ? self.addedLoadingInset : -self.addedLoadingInset
         }
      }) { _ in
         completion?()
      }
   }
}
