//
//  KRPullLoader.swift
//  KRPullLoader
//
//  Copyright © 2017 Krimpedance. All rights reserved.
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

    private var observations = [NSKeyValueObservation]()
    private var addedLoadingInset = CGFloat(0)

    let loadView: T
    let type: KRPullLoaderType

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

    override func willRemoveSubview(_ subview: UIView) {
        guard subview == loadView else { return }
        observations = []
    }
}

// MARK: - Actions -------------------

extension KRPullLoader {
    func setUp() {
        checkScrollViewContentSize()
        addObservers()
    }
}

// MARK: - Private Actions -------------------

private extension KRPullLoader {
    func addObservers() {
        guard let scrollView = self.scrollView else { return }

        let contentOffsetObservation = scrollView.observe(\.contentOffset) { _, _ in
            if case .loading = self.state, self.isHidden { return }
            self.updateState()
        }

        let contentSizeObservation = scrollView.observe(\.contentSize) { _, _ in
            if case .loading = self.state { return }
            self.checkScrollViewContentSize()
        }

        observations = [contentOffsetObservation, contentSizeObservation]
    }

    func checkScrollViewContentSize() {
        guard let scrollView = scrollView, type == .loadMore else { return }
        self.isHidden = scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom < scrollView.bounds.height
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

private extension KRPullLoader {
    func adjustLayoutConstraints() {
        guard let scrollView = scrollView else { return }

        // clear constraints
        loadView.constraints.forEach {
            guard ($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self else { return }
            loadView.removeConstraint($0)
        }
        removeFromSuperview()
        scrollView.addSubview(self)

        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        loadView.translatesAutoresizingMaskIntoConstraints = false

        let attributes: [NSLayoutAttribute] = [.top, .left, .right, .bottom]
        addConstraints(attributes.map { NSLayoutConstraint(item: loadView, attribute: $0, toItem: self) })

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

        let constant = (type == .refresh) ?
            -(scrollView.contentInset.top + bounds.height - addedLoadingInset) :
            scrollView.contentSize.height + scrollView.contentInset.bottom - addedLoadingInset

        scrollView.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, toItem: scrollView, constant: constant),
            NSLayoutConstraint(item: self, attribute: .centerX, toItem: scrollView),
            NSLayoutConstraint(item: self, attribute: .width, toItem: scrollView)
        ])
    }

    func adjustHorizontalScrollLayoutConstraints() {
        guard let scrollView = scrollView else { return }

        let constant = type == .refresh ?
            -(scrollView.contentInset.left + bounds.width - addedLoadingInset) :
            scrollView.contentSize.width + scrollView.contentInset.right - addedLoadingInset

        scrollView.addConstraints([
            NSLayoutConstraint(item: self, attribute: .left, toItem: scrollView, constant: constant),
            NSLayoutConstraint(item: self, attribute: .centerY, toItem: scrollView),
            NSLayoutConstraint(item: self, attribute: .height, toItem: scrollView)
            ])
    }
}

// MARK: - Loading actions -------------------

private extension KRPullLoader {
    func startLoading() {
        switch state {
        case .loading:
            addedLoadingInset = scrollDirection == .vertical ? bounds.height : bounds.width
            animateScrollViewInset(isShow: true)
        default: break
        }
    }

    func endLoading() {
        state = .none
        animateScrollViewInset(isShow: false) { _ in
            self.addedLoadingInset = 0
            self.adjustLayoutConstraints()
        }
    }

    func animateScrollViewInset(isShow: Bool, completion: ((Bool) -> Void)? = nil) {
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
        }, completion: completion)
    }
}
