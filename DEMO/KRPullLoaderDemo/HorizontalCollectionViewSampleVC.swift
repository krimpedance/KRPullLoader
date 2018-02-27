//
//  HorizontalHorizontalCollectionViewSampleVC.swift
//  KRPullLoaderDemo
//
//  Copyright © 2017年 Krimpedance. All rights reserved.
//

import UIKit

import UIKit
import KRPullLoader

class HorizontalCollectionViewSampleVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.addPullLoadableView(HorizontalPullLoadView(), type: .refresh)
        collectionView.addPullLoadableView(HorizontalPullLoadView(), type: .loadMore)

        collectionView.contentInset.left = 50
        collectionView.contentInset.right = 50
    }
}

// MARK: - UICollectionView data source -------------------

extension HorizontalCollectionViewSampleVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        index += 1
        return 10 * index
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .getColor(with: indexPath.row)
        return cell
    }
}
