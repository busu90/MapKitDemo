//
//  MapPresenter.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation

protocol MapPresenter{
    func fetchWeatherData(long: Double, lat: Double, isCurrentLocation: Bool)
    func getCachedWeather() -> [Weather]
}

class MapPresenterImpl: MapPresenter{
    private weak var view: MapView!
    let provider: WeatherProvider
    
    init(view: MapView, weatherProvider: WeatherProvider = WeatherProviderImpl()) {
        self.view = view
        self.provider = weatherProvider
    }
    
    func fetchWeatherData(long: Double, lat: Double, isCurrentLocation: Bool) {
        provider.getWeather(long: long, lat: lat) { [weak self](weather, error) in
            if error != nil{
                self?.view?.showError(error: error!)
            }else{
                self?.view?.didFetchWeather(weather: weather!, isCurrentLocation: isCurrentLocation)
            }
        }
    }
    
    func getCachedWeather() -> [Weather]{
        return provider.getLocalWeather()
    }
}
