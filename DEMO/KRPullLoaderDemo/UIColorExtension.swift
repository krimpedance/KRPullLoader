//
//  UIColorExtension.swift
//  KRPullLoaderDemo
//
//  Copyright © 2017年 Krimpedance. All rights reserved.
//

import UIKit

extension UIColor {
   class func getRandomColor() -> UIColor {
      let red = CGFloat(arc4random_uniform(256))
      let green = CGFloat(arc4random_uniform(256))
      let blue = CGFloat(arc4random_uniform(256))
      return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
   }
}
