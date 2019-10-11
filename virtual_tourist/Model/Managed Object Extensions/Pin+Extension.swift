//
//  Pin+Extension.swift
//  virtual_tourist
//
//  Created by Varosyan, Anna on 07.10.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation
import MapKit

extension Pin {
    
     //Create map annotation for a <pin>
    public func createAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
     
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = "\(latitude) \(longitude)"
        annotation.subtitle = getSubtitleFromDate()

        return annotation
    }
    
    public func matchAnnotation(_ pinAnnot: MKAnnotation) -> Bool {
        return pinAnnot.coordinate.latitude == latitude && pinAnnot.coordinate.longitude == longitude
    }
    
    private func getSubtitleFromDate()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter.string(from: creationDate!)
    }
}
