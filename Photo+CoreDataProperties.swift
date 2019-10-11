//
//  Photo+CoreDataProperties.swift
//  virtual_tourist
//
//  Created by Varosyan, Anna on 04.10.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var data: Data?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
