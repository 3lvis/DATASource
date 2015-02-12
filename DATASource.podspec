Pod::Spec.new do |s|
  s.name = "DATASource"
  s.version = "2.0"
  s.summary = "NSFetchedResultsControllers + UITableViewController made stupid easy"
  s.description = <<-DESC
                   * How much does it take to insert a NSManagedObject into CoreData
                   * and show it in your UITableView in an animated way
                   * (using NSFetchedResultsController, of course)?
                   * 100 LOC? 200 LOC? 300 LOC?
                   * Well, DATASource does it in 71 LOC.
                   DESC
  s.homepage = "https://github.com/NSElvis/DATASource"
  s.license = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  s.author = { "Elvis Nunez" => "elvisnunez@me.com" }
  s.social_media_url = "http://twitter.com/NSElvis"
  s.platform = :ios, '7.0'
  s.source = {
    :git => 'https://github.com/NSElvis/DATASource.git',
    :tag => s.version.to_s
  }
  s.source_files = 'Source/'
  s.frameworks = 'Foundation', 'UIKit', 'CoreData'
  s.requires_arc = true
  
  s.dependency 'DATAStack'
end
