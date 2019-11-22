# VOGWalkthrough

[![CI Status](https://img.shields.io/travis/duypham-vog/VOGWalkthrough.svg?style=flat)](https://travis-ci.org/duypham-vog/VOGWalkthrough)
[![Version](https://img.shields.io/cocoapods/v/VOGWalkthrough.svg?style=flat)](https://cocoapods.org/pods/VOGWalkthrough)
[![License](https://img.shields.io/cocoapods/l/VOGWalkthrough.svg?style=flat)](https://cocoapods.org/pods/VOGWalkthrough)
[![Platform](https://img.shields.io/cocoapods/p/VOGWalkthrough.svg?style=flat)](https://cocoapods.org/pods/VOGWalkthrough)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 9.0<br>Swift 4.2
## Installation

VOGWalkthrough is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'VOGWalkthrough'
```
**Import Library** </br>Open AppDelegate.swiif and insert bellow code
```ruby
import VOGWalkthrough
```
**Config VOGWalkthroung**
</br>Go to
```ruby
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
```
Insert below code to config VOGWalkthrough

```ruby
var config = VOGWalkthroughConfig()
config.url = "Walkthrough URL"
config.outsidePadding = 20
config.insidePadding = 20
config.delay = 0.6
config.iconSize = CGSize(width: 20, height: 20)

let walkthrough = VOGWalkthrough.shared
walkthrough.setConfig(config: config)
```

**Config ViewController**
</br>Open ViewController which you want to display Walkthrough. Insert the viewDidLoad() function. Insert this code

```ruby
VOGWalkthrough.shared.showStep(on: self, screenId: "SCREENID")
```
</br>
SCREENID is screenID that is setup on admin panel

## Configuration
| Field | Type  | Description  | Default |
| ------------ | ------------ | ------------ | ------------ |
|  url | String  | url of endpoint to get walkthrough data  | NA|
|  outsidePadding| CGFloat  |  Outside padding | 20|
|  insidePadding |  CGFloat |  Inside padding | 20|
|  tapFont |  UIFont |  Tap font or title font | UIFont.systemFont(ofSize: 13)|
|  font |  UIFont |  Content font | UIFont.systemFont(ofSize: 15)|
|  delay |  Double | Animation delay time  | 0.5|
|  iconSize |  CGSize | Icon size  | CGSize(20,20)|
|  color.title | UIColor  |  Title color | Back|
|  color.content | UIColor  | Content color  |Back |
|  color.icon | UIColor  | Icon color  |Back |
|  color.background | UIColor  | Background color  | Light Gray|



## Author

Duy Pham

## License

VOGWalkthrough is available under the MIT license. See the LICENSE file for more info.
