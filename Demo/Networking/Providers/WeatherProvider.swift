//
//  WeatherProvider.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol WeatherProvider {
    func getWeather(long: Double, lat: Double, completionHandler: @escaping (_ weather: Weather?, _ error: Error?) -> Void)
    func getLocalWeather() -> [Weather]
}

class WeatherProviderImpl: WeatherProvider {
    private var apiClient: ApiClient
    
    init(apiClient: ApiClient = ApiClientImpl()) {
        self.apiClient = apiClient
    }
    
    func getWeather(long: Double, lat: Double, completionHandler: @escaping (_ weather: Weather?, _ error: Error?) -> Void) {
        apiClient.execute(request: Router.getWeather(long: long, lat: lat)) { [weak self](result: Result<ApiResponse<Weather>>) in
            switch result {
            case let .success(response):
                //the result is insignificant in this case
                let _ = self?.saveToCache(weather: response.entity)
                completionHandler(response.entity, nil)
            case let .failure(error):
                completionHandler(nil, error)
            }
        }
    }
    
    //this caching code would normally be moved to its own provider
    //since it is only used here its just easuer to keep here
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getLocalWeather() -> [Weather]{
        let fetchRequest: NSFetchRequest<WeatherDOM> = WeatherDOM.fetchRequest()
        fetchRequest.includesPropertyValues=true
        fetchRequest.includesPendingChanges = true
        do {
            let result = try context.fetch(fetchRequest)
            return result.map({ (weatherDOM) -> Weather in
                return Weather(managedObject: weatherDOM)
            })
        } catch {
            return []
        }
    }
    
    func saveToCache(weather: Weather) -> Bool {
        if (weather.id != nil){
            let fetchRequest: NSFetchRequest<WeatherDOM> = WeatherDOM.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %i", weather.id!)
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for r in results{
                        context.delete(r)
                    }
                }
                let new = weather.managedObject(context: context)
                context.insert(new)
                try context.save()
                return true
            } catch {
                return false
            }
        }else{
            //if no id is present do not save since we wont be able to identify it and replace in the future
            return false
        }
    }
    
}

