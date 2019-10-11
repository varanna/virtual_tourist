# virtual_tourist
Udacity Nanodegree Virtual Torurist project

This app is created as a final project of the [iOS Nanodegree - Udacity](https://www.udacity.com/course/ios-developer-nanodegree--nd003).

## Build
### Requirements
* Xcode 10.1
* iOS 12.1
* Swift 4.2

### Steps to build
1. Clone repo 
2. Install dependences (**CocoaPods needed**)
```
pod install
```
3. Insert flicker API key & secret inside -> (API/FlickrAPI.swift) 
```swift
class FlickrAPI {
    struct Constants {
        static let API_KEY = // Here
        static let API_SECRET = // Here
        ....
    }
    ....
```
4. Open `virtual_tourist.xcworkspace`
5. Build app for your device or simulator

## About the app
This app allows users specify travel locations around the world, and create virtual photo albums for each location. The locations and photo albums will be stored in Core Data.

The app will have two view controller scenes.

    Travel Locations Map View: Allows the user to drop pins around the world
    Photo Album View: Allows the users to download and edit an album for a location 

## Resources
This app uses the following frameworks and APIs:

### Third-party frameworks

| Framework | Description |
| --- | --- 
| [CocoaPods](https://github.com/CocoaPods/CocoaPods) | The Cocoa Dependency Manager. |
| [Alamofire](https://github.com/Alamofire/Alamofire) | Easy HTTP networking in Swift. |
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) | The better way to deal with JSON data in Swift.|
| [Kingfisher](https://github.com/onevcat/Kingfisher) | A lightweight, pure-Swift library for downloading and caching images from the web.|

### APIs
| Framework | Description |
| --- | --- |
| [Flickr API](https://www.flickr.com/services/api/) | It is used to retrieve photos related to the locations. |

