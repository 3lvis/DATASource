Pod::Spec.new do |s|
  s.name = "DATASource"
  s.version = "3.2.1"
  s.summary = "NSFetchedResultsController made stupid easy "
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
