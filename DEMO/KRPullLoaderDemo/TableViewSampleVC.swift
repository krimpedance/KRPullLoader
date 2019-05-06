//
//  TableViewSampleVC.swift
//  KRPullLoaderDemo
//
//  Copyright © 2017年 Krimpedance. All rights reserved.
//

import UIKit
import KRPullLoader

class TableViewSampleVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var index = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self

        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        tableView.addPullLoadableView(refreshView, type: .refresh)
        let loadMoreView = KRPullLoadView()
        loadMoreView.delegate = self
        tableView.addPullLoadableView(loadMoreView, type: .loadMore)

        tableView.contentInset.top = 50
        tableView.contentInset.bottom = 50
    }
}

// MARK: - UITableView data source -------------------

extension TableViewSampleVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10 * index
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.backgroundColor = .getColor(with: indexPath.row)
        return cell
    }
}

// MARK: - KRPullLoadView delegate -------------------

extension TableViewSampleVC: KRPullLoadViewDelegate {
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        if type == .loadMore {
            switch state {
            case let .loading(completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    completionHandler()
                    self.index += 1
                    self.tableView.reloadData()
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
                self.index += 1
                self.tableView.reloadData()
            }
        }
    }
}
