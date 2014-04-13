Pod::Spec.new do |s|

  s.name         = "EffectiveDataServices"
  s.version      = "0.0.1"
  s.summary      = "An Objective-C API encapsulating iOS and OSX data facilities - namely Core Data."

  s.description  = <<-DESC
                   EffectiveDataServices is an Objective-C API encapsulating iOS and OSX data facilities - namely Core Data.
                   DESC

  s.homepage     = "https://github.com/EffectiveProgramming/EffectiveDataServices"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Luther Baker" => "luther@effectiveprogramming.com" }
  s.social_media_url = "http://twitter.com/effprog"

  s.platform     = :ios, '5.0'
  s.source       = { :git => "https://github.com/EffectiveProgramming/EffectiveDataServices.git", :tag => "0.0.1" }
  s.source_files  = 'Source/**/*.{h,m}'
  s.exclude_files = 'Source/**/*Tests.{h,m}'
  s.requires_arc = true

end
