Pod::Spec.new do |s|
  s.name = "DATASource"
  s.version = "7.0.2"
  s.summary = "Core Data's NSFetchedResultsController wrapper for UITableView and UICollectionView"
  s.description  = <<-EOS
  If you are not familiarized with NSFetchedResultsController, it allows you to efficiently manage the results returned from a Core Data fetch request to provide data for a UITableView or a UICollectionView. NSFetchedResultsController monitors changes in Core Data objects and notifies the view about those changes allowing you to be reactive about them.

  Using NSFetchedResultsController and NSFetchedResultsControllerDelegate is awesome, but sadly it involves a lot of boilerplate. Well, luckily with DATASource not anymore.

  - Encapsulates NSFetchedResultsController and NSFetchedResultsControllerDelegate boilerplate
  - Supports indexed tables out of the box
  - Supports sectioned collections out of the box
  - Swift
  - Objective-C compatibility
  EOS
  s.homepage         = "https://github.com/3lvis/DATASource"
  s.license          = 'MIT'
  s.author           = { "Elvis Nuñez" => "elvisnunez@me.com" }
  s.source           = { :git => "https://github.com/3lvis/DATASource.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/3lvis'
  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.frameworks = 'Foundation', 'UIKit', 'CoreData'
end
