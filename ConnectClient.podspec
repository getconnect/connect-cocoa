Pod::Spec.new do |s|
  s.name             = "ConnectClient"
  s.version          = "0.1.1"
  s.summary          = "The Connect iOS and OSX SDK"
  s.description      = <<-DESC
                       Use Connect to build beautiful visualizations for your users.
                       The Connect SDK makes it easy to push events to Connect ready for querying and visualizing.
                       DESC
  s.homepage         = "https://github.com/getconnect/connect-cocoa"
  s.license          = "MIT"
  s.author           = { "Chad Edrupt" => "chad@tipihq.com" }
  s.source           = { :git => "https://github.com/getconnect/connect-cocoa.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = "*.{h,m}", "Utilities/*.{h,m}"
  s.exclude_files = "Example/**/*"

  s.dependency 'YapDatabase', '~> 2.6'
end
