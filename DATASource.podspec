Pod::Spec.new do |s|
  s.name = "DataSource"
  s.version = "5.0.0"
  s.summary = "NSFetchedResultsController made stupid easy "
  s.homepage         = "https://github.com/3lvis/DataSource"
  s.license          = 'MIT'
  s.author           = { "Elvis Nuñez" => "elvisnunez@me.com" }
  s.source           = { :git => "https://github.com/3lvis/DataSource.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/3lvis'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.frameworks = 'Foundation', 'UIKit', 'CoreData'
end
