//
//  UIColorExtension.swift
//  KRPullLoaderDemo
//
//  Copyright © 2017年 Krimpedance. All rights reserved.
//

import UIKit

extension UIColor {
    class func getColor(with row: Int) -> UIColor {
        return [.red, .blue, .green, .orange, .yellow][(row / 10) % 5]
    }
}
