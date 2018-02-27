//
//  KRPullLoadView.swift
//  KRPullLoader
//
//  Copyright © 2017 Krimpedance. All rights reserved.
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

    private lazy var oneTimeSetUp: Void = { self.setUp() }()

    open let activityIndicator = UIActivityIndicatorView()
    open let messageLabel = UILabel()

    open weak var delegate: KRPullLoadViewDelegate?

    open override func layoutSubviews() {
        super.layoutSubviews()
        _ = oneTimeSetUp
    }

    // MARK: - Set up --------------

    open func setUp() {
        backgroundColor = .clear

        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)

        messageLabel.font = .systemFont(ofSize: 10)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)

        addConstraints([
            NSLayoutConstraint(item: activityIndicator, attribute: .top, toItem: self, constant: 15.0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerX, toItem: self),
            NSLayoutConstraint(item: messageLabel, attribute: .top, toItem: self, constant: 40.0),
            NSLayoutConstraint(item: messageLabel, attribute: .centerX, toItem: self),
            NSLayoutConstraint(item: messageLabel, attribute: .bottom, toItem: self, constant: -15.0)
        ])

        messageLabel.addConstraint(
            NSLayoutConstraint(item: messageLabel, attribute: .width, relatedBy: .lessThanOrEqual, constant: 300)
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
