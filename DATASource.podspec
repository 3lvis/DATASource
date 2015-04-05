Pod::Spec.new do |s|
  s.name = "DATASource"
  s.version = "2.1"
  s.summary = "NSFetchedResultsController + UITableViewController made stupid easy"
  s.description = <<-DESC
                   * How much does it take to insert a NSManagedObject into CoreData
                   * and show it in your UITableView in an animated way
                   * (using NSFetchedResultsController, of course)?
                   * 100 LOC? 200 LOC? 300 LOC?
                   * Well, DATASource does it in 71 LOC.
                   DESC
  s.homepage         = "https://github.com/3lvis/DATASource"
  s.license          = 'MIT'
  s.author           = { "Elvis Nuñez" => "elvisnunez@me.com" }
  s.source           = { :git => "https://github.com/3lvis/DATASource.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/3lvis'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.frameworks = 'Foundation', 'UIKit', 'CoreData'
end
