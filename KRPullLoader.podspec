Pod::Spec.new do |s|
  s.name         = "KRPullLoader"
  s.version      = "1.3.0"
  s.summary      = "A 'pull to load' control for UIScrollView(, UITableView, UICollectionView, ...)."
  s.description  = "KRPullLoader is a 'pull to load' control for UIScrollView(, UITableView, UICollectionView, ...) on iOS."
  s.homepage     = "https://github.com/krimpedance/KRPullLoader"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "krimpedance" => "info@krimpedance.com" }
  s.requires_arc = true
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/krimpedance/KRPullLoader.git", :tag => s.version.to_s }
  s.source_files = "KRPullLoader/**/*.swift"
end
