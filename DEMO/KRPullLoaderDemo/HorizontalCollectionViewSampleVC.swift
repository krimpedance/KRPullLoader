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

   override func viewDidLoad() {
      super.viewDidLoad()

      collectionView.dataSource = self
      collectionView.addPullLoadableView(HorizontalPullLoadView(), type: .refresh)
      collectionView.addPullLoadableView(HorizontalPullLoadView(), type: .loadMore)
   }
}

// MARK: - UICollectionView data source -------------------

extension HorizontalCollectionViewSampleVC: UICollectionViewDataSource {
   func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 1
   }

   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return 20
   }

   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
      cell.backgroundColor = .getRandomColor()
      return cell
   }
}
