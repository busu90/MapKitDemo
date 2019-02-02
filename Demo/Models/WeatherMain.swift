//
//  WeatherMain.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation
import CoreData

class WeatherMain: Codable{
    var temp: Double?
    var pressure: Double?
    var humidity: Double?
    
    init(managedObject: WeatherMainDOM) {
        temp = managedObject.temp
        pressure = managedObject.pressure
        humidity = managedObject.humidity
    }
    
    func managedObject(context: NSManagedObjectContext) -> WeatherMainDOM {
        let weather = WeatherMainDOM(context: context)
        weather.temp = temp ?? 0
        weather.pressure = pressure ?? 0
        weather.humidity = humidity ?? 0
        return weather
    }
}
