[English](./README.md)

# KRPullLoader

[![Version](https://img.shields.io/cocoapods/v/KRPullLoader.svg?style=flat)](http://cocoapods.org/pods/KRPullLoader)
[![License](https://img.shields.io/cocoapods/l/KRPullLoader.svg?style=flat)](http://cocoapods.org/pods/KRPullLoader)
[![Platform](https://img.shields.io/cocoapods/p/KRPullLoader.svg?style=flat)](http://cocoapods.org/pods/KRPullLoader)
[![Download](https://img.shields.io/cocoapods/dt/KRPullLoader.svg?style=flat)](http://cocoapods.org/pods/KRPullLoader)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CI Status](http://img.shields.io/travis/krimpedance/KRPullLoader.svg?style=flat)](https://travis-ci.org/krimpedance/KRPullLoader)

<img src="https://github.com/krimpedance/Resources/blob/master/KRPullLoader/demo.gif" height=400>

## 特徴
- 使いやすさ
- `引っ張って更新`, `もっと読み込む`の両アクションに対応

## 必要環境
- iOS 8.0+
- Xcode 10.2+
- Swift 5.0+

## デモ
`DEMO/`以下にあるサンプルプロジェクトから確認してください．

または，[Appetize.io](https://appetize.io/app/d17hjrvt0fm9mfg2crmqbu4qx4)にてシュミレートしてください．

## インストール
KRPullLoaderは[CocoaPods](http://cocoapods.org)と[Carthage](https://github.com/Carthage/Carthage)で
インストールすることができます．

```ruby
# Podfile
pod "KRPullLoader"
```

```ruby
# Cartfile
github "Krimpedance/KRPullLoader"
```

## 使い方
(`/Demo`以下のサンプルを見てみてください)

#### ビューの追加

最もシンプルな方法:

```swift
let refreshView = KRPullLoadView()
refreshView.delegate = self
tableView.addPullLoadableView(refreshView, type: .refresh)
```

`KRPullLoadView`は`UIActivityIndicatorView`と`UILabel`からなる, 最もシンプルなローディングビューです.

デリゲートメソッドで状態の変更を監視できます.

`type`は`.refresh`と`.loadMore`があり, 上部/下部のどちらにでも追加できます.

#### カスタムビューの追加

ローディングビューは, `KRPullLoadable`プロトコルを継承したUIViewを作成することで,
自由にデザインすることができます.

[KRPullLoadView.swift](./KRPullLoader/Classes/KRPullLoadView.swift)や[HorizontalPullLoadView.swift](./DEMO/KRPullLoaderDemo/HorizontalPullLoadView.swift)を参考にしてください.

#### KRPullLoadable

このプロトコルは以下のメソッドのみを持っています.

```swift
/**
 KRPullLoaderStateが変わる時に呼ばれる関数

 - parameter state: 新しい状態
 - parameter type:  自身のタイプ.
*/
func didChangeState(_ state: KRPullLoaderState, viewType type: KRPullLoaderType)
```

#### KRPullLoaderState

スクロールの状態を表すEnumです.

```swift
.none
  // ローディングビューが隠れている状態(タップなし, または通常のスクロール中)
.pulling(offset: CGPoint, threshold: CGFloat)
  // ScrollViewのContentSizeを超えて画面を引っ張っている状態
  // offset: オーバースクロール量
  // threshold: タップをやめた時に`.loading`へ移行する閾値
.loading(completionHandler: ()->Void)
  // ローディング中
  // `completionHandler`を呼ぶとローディングを終了します.
```

## ライブラリに関する質問等
バグや機能のリクエストがありましたら，気軽にコメントしてください．

## リリースノート
+ 1.3.0
  - Swift 5.0 に対応.
  - コードからローディングビューを表示できるように変更（上部のみ）

+ 1.2.0
  - Swift 4.2 に対応.

## ライセンス
KRPullLoaderはMITライセンスに準拠しています.

詳しくは`LICENSE`ファイルをみてください.
