#
# Be sure to run `pod lib lint VOGWalkthrough.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VOGWalkthrough'
  s.version          = '2.0.0'
  s.summary          = 'VOG Walkthrough.'
  s.swift_version    = '4.2'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/duypham-vog/VOGWalkthrough'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Duy Pham' => 'duy@vogcalgaryappdeveloper.com' }
  s.source           = { :git => 'https://github.com/duypham-vog/VOGWalkthrough.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'VOGWalkthrough/Classes/**/*'
  
  s.resource_bundles = {
    'VOGWalkthrough' => ['VOGWalkthrough/Assets/**/*.png']
  }

  #s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  #s.dependency 'Alamofire', '~> 4.8.1'
end
