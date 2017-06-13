//
//  KRPullLoadView.swift
//  KRPullLoader
//
//  Copyright © 2017年 Krimpedance. All rights reserved.
//

import UIKit

/**
 Delegate for KRPullLoadView.
 */
public protocol KRPullLoadViewDelegate: class {
   /**
    Handler when KRPullLoaderState value changed.

    - parameter pullLoadView: KRPullLoadView.
    - parameter state:        New state.
    - parameter type:         KRPullLoaderType.
    */
   func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType)
}

/**
 Simple view which inherited KRPullLoadable protocol.
 This has only activity indicator and message label.
 */
open class KRPullLoadView: UIView, KRPullLoadable {

   open let activityIndicator = UIActivityIndicatorView()
   open let messageLabel = UILabel()

   open weak var delegate: KRPullLoadViewDelegate?

   var shouldSetConstraints = true

   open override func layoutSubviews() {
      super.layoutSubviews()
      if shouldSetConstraints { setUp() }
      shouldSetConstraints = false
   }

   // MARK: - Set up --------------

   open func setUp() {
      backgroundColor = .clear

      activityIndicator.activityIndicatorViewStyle = .gray
      activityIndicator.hidesWhenStopped = false
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      addSubview(activityIndicator)

      messageLabel.font = UIFont.systemFont(ofSize: 10)
      messageLabel.textAlignment = .center
      messageLabel.textColor = .gray
      messageLabel.translatesAutoresizingMaskIntoConstraints = false
      addSubview(messageLabel)

      addConstraints([
         NSLayoutConstraint(item: activityIndicator, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0),
         NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
         NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 40.0),
         NSLayoutConstraint(item: messageLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
         NSLayoutConstraint(item: messageLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0)
      ])

      messageLabel.addConstraint(
         NSLayoutConstraint(item: messageLabel, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .width, multiplier: 1.0, constant: 300)
      )
   }

   // MARK: - KRPullLoadable --------------

   open func didChangeState(_ state: KRPullLoaderState, viewType type: KRPullLoaderType) {
      switch state {
      case .none:
         activityIndicator.stopAnimating()

      case .pulling:
         break

      case .loading:
         activityIndicator.startAnimating()
      }
      delegate?.pullLoadView(self, didChangeState: state, viewType: type)
   }
}
