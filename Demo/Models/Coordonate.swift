//
//  Coordonate.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation
import CoreData

class Coordonate: Codable{
    var lon: Double?
    var lat: Double?
    
    init(managedObject: CoordonateDOM) {
        lon = managedObject.lon
        lat = managedObject.lat
    }
    
    func managedObject(context: NSManagedObjectContext) -> CoordonateDOM {
        let wind = CoordonateDOM(context: context)
        wind.lon = lon ?? 0
        wind.lat = lat ?? 0
        return wind
    }
}
