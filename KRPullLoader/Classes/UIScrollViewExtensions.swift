//
//  UIScrollViewExtensions.swift
//  KRPullLoader
//
//  Copyright © 2017 Krimpedance. All rights reserved.
//

import UIKit

extension UIScrollView {
    var distanceOffset: CGPoint {
        get {
            return CGPoint(
                x: contentOffset.x + contentInset.left,
                y: contentOffset.y + contentInset.top
            )
        }
        set {
            let point = CGPoint(
                x: newValue.x - contentInset.left,
                y: newValue.y - contentInset.top
            )
            setContentOffset(point, animated: true)
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

// MARK: - Public UIScrollView extensions ------------

public extension UIScrollView {
    /// Adds the PullLoadableView.
    ///
    /// - Parameters:
    ///   - loadView: view that contain KRPullLoadable.
    ///   - type: KRPullLoaderType. Default type is `.refresh`.
    func addPullLoadableView(_ loadView: KRPullLoadable, type: KRPullLoaderType = .refresh) {
        let loader = KRPullLoader(loadView: loadView, type: type)
        insertSubview(loader, at: 0)
        loader.setUp()
    }

    /// Remove the PullLoadableView.
    ///
    /// - Parameter type: KRPullLoaderType.
    func removePullLoadableView(type: KRPullLoaderType) {
        guard let loader = subviews.first(where: { ($0 as? KRPullLoader)?.type == type }) else { return }
        loader.removeFromSuperview()
    }

    /// Pull to refresh programmatically
    func pullToRefresh() {
        guard let loader = subviews.first(where: { ($0 as? KRPullLoader)?.type == .refresh }) as? KRPullLoader else { return }
        loader.startLoading(force: true)
    }
}
