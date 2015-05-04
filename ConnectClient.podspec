#
# Be sure to run `pod lib lint ConnectClient.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ConnectClient"
  s.version          = "0.1.0"
  s.summary          = "A short description of ConnectClient."
  s.description      = <<-DESC
                       An optional longer description of ConnectClient

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
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
