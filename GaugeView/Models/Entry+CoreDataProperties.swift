//
//  Entry+CoreDataProperties.swift
//  GaugeView
//
//  Created by Ben Huggins on 4/17/19.
//  Copyright © 2019 User. All rights reserved.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var decibels: Float
    @NSManaged public var recordings: Double
    @NSManaged public var score: String?
    @NSManaged public var sst: String?

}
