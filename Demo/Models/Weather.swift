//
//  Weather.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation
import CoreData

class Weather: Codable{
    var coord: Coordonate?
    var weather: [WeatherDescription]?
    var main: WeatherMain?
    var wind: Wind?
    var name: String?
    var id: Int?
    
    init(managedObject: WeatherDOM) {
        id = Int(managedObject.id)
        name = managedObject.name ?? ""
        wind = managedObject.wind != nil ? Wind(managedObject: managedObject.wind!) : nil
        main = managedObject.main != nil ? WeatherMain(managedObject: managedObject.main!) : nil
        coord = managedObject.coord != nil ? Coordonate(managedObject: managedObject.coord!) : nil
        
        if let w = managedObject.weather as? Set<WeatherDescriptionDOM>{
            weather = w.map({ (weatherDOM) -> WeatherDescription in
                return WeatherDescription(managedObject: weatherDOM)
            })
        }else{
            weather = nil
        }
    }
    
    func managedObject(context: NSManagedObjectContext) -> WeatherDOM {
        let weather = WeatherDOM(context: context)
        weather.id = Int64(id ?? 0)
        weather.name = name
        weather.wind = wind?.managedObject(context: context)
        weather.main = main?.managedObject(context: context)
        weather.coord = coord?.managedObject(context: context)
        if (self.weather == nil){
            weather.weather = nil
        }else{
            let newWeather = self.weather!.map({ (weather) -> WeatherDescriptionDOM in
                return weather.managedObject(context: context)
            })
            weather.weather = Set(newWeather) as NSSet
        }
        return weather
    }
    
    func isValidWeather() -> Bool{
        if coord == nil || coord!.lat == nil || coord?.lon == nil || name == nil || name!.isEmpty || main == nil || main!.temp == nil {
            return false
        }
        return true
    }
}
