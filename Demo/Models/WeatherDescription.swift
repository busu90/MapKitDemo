//
//  WeatherDescription.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation
import CoreData

class WeatherDescription: Codable{
    var main: String?
    var description: String?
    var icon: String?
    
    init(managedObject: WeatherDescriptionDOM) {
        main = managedObject.main
        description = managedObject.desc
        icon = managedObject.icon
    }
    
    func managedObject(context: NSManagedObjectContext) -> WeatherDescriptionDOM {
        let weather = WeatherDescriptionDOM(context: context)
        weather.main = main ?? ""
        weather.desc = description ?? ""
        weather.icon = icon ?? ""
        return weather
    }
}
