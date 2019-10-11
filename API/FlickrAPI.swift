//
//  FlickrAPI.swift
//  virtual_tourist
//
//  Created by Varosyan, Anna on 07.10.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class FlickrAPI {
    struct Constants {
        static let API_KEY = "HERE_YOUR_API_KEY"
        static let API_SECRET = "HERE_YOUR_API_SECRET"
        static let BASE_URL = "https://api.flickr.com/services/rest"
        static let FLICKR_SEARCH_METHOD = "flickr.photos.search"
        static let NUM_OF_PHOTOS = 20
    }
    
    struct Connectivity {
        static var isConnectedToInternet: Bool {
            return NetworkReachabilityManager()!.isReachable
        }
        
        enum Status {
            case notConnected, connected, other
        }
    }
    
    static func getListOfPhotosIn(lat: Double, lon: Double, completionHandler: @escaping (Connectivity.Status, [String]?) -> Void) {
        
        if  checkConnectionIsAvailable(completionHandler: completionHandler) {
            Alamofire.request(composeFlickrQueryURL(lat: lat, lon: lon)).responseJSON { (response) in
                if((response.result.value) != nil) {
                    let swiftyJsonVar = JSON(response.result.value!)
                    var photosURL: [String] = []
                    
                    if let photos = swiftyJsonVar["photos"]["photo"].array {
                        for photo in photos {
                            photosURL.append(composePhotoURL(photo))
                        }
                    }
                    completionHandler(.connected, photosURL)
                } else {
                    completionHandler(.other, nil)
                }
        }
        }
        
    }
    
    static private func composeFlickrQueryURL(lat: Double, lon: Double) -> String {
        let url = "\(Constants.BASE_URL)?api_key=\(Constants.API_KEY)&method=\(Constants.FLICKR_SEARCH_METHOD)&per_page=\(Constants.NUM_OF_PHOTOS)&format=json&nojsoncallback=?&lat=\(lat)&lon=\(lon)&page=\((1...10).randomElement() ?? 1)"
        return url
    }
    static private func composePhotoURL(_ photo: JSON) -> String {
        let strFarm = photo["farm"].stringValue
        let strServer = photo["server"].stringValue
        let strSecret = photo["secret"]
        let photoURL = "https://farm\(strFarm).staticflickr.com/\(strServer)/\(photo["id"])_\(strSecret).jpg"
        return photoURL
    }
    
    static private func checkConnectionIsAvailable(completionHandler: @escaping (Connectivity.Status, [String]?) -> Void) -> Bool {
        let isConnected = Connectivity.isConnectedToInternet
        if !isConnected {
           completionHandler(.notConnected, nil)
        }
        return isConnected
    }
}


