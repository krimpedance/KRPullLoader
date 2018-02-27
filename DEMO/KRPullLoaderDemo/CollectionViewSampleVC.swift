//
//  CollectionViewSampleVC.swift
//  KRPullLoaderDemo
//
//  Copyright © 2017年 Krimpedance. All rights reserved.
//

import UIKit
import KRPullLoader

class CollectionViewSampleVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        collectionView.addPullLoadableView(refreshView, type: .refresh)
        let loadMoreView = KRPullLoadView()
        loadMoreView.delegate = self
        collectionView.addPullLoadableView(loadMoreView, type: .loadMore)
    }
}

// MARK: - UICollectionView data source -------------------

extension CollectionViewSampleVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.index += 1
        return 10 * index
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .getColor(with: indexPath.row)
        return cell
    }
}

// MARK: - KRPullLoadView delegate -------------------

extension CollectionViewSampleVC: KRPullLoadViewDelegate {
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        if type == .loadMore {
            switch state {
            case let .loading(completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    completionHandler()
                    self.collectionView.reloadData()
                }
            default: break
            }
            return
        }

        switch state {
        case .none:
            pullLoadView.messageLabel.text = ""

        case let .pulling(offset, threshould):
            if offset.y > threshould {
                pullLoadView.messageLabel.text = "Pull more. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            } else {
                pullLoadView.messageLabel.text = "Release to refresh. offset: \(Int(offset.y)), threshould: \(Int(threshould)))"
            }

        case let .loading(completionHandler):
            pullLoadView.messageLabel.text = "Updating..."
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                completionHandler()
                self.collectionView.reloadData()
            }
        }
    }
}
