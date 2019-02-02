//
//  Wind.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation
import CoreData

class Wind: Codable{
    var speed: Double?
    var deg: Double?
    
    init(managedObject: WindDOM) {
        speed = managedObject.speed
        deg = managedObject.deg
    }
    
    func managedObject(context: NSManagedObjectContext) -> WindDOM {
        let wind = WindDOM(context: context)
        wind.speed = speed ?? 0
        wind.deg = deg ?? 0
        return wind
    }
}
