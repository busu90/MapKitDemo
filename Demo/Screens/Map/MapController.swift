//
//  MapController.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

protocol MapView: class {
    func showError(error: Error)
    func didFetchWeather(weather: Weather, isCurrentLocation: Bool)
}

class MapController: UIViewController{
    private var presenter: MapPresenter!
    private var locationManager: CLLocationManager!
    private var progress: UIView!
    private let reachability = Reachability()!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MapPresenterImpl(view: self)
        
        let dblTap = UITapGestureRecognizer(target: self, action: #selector(handleDblTapInMap(_:)))
        dblTap.numberOfTapsRequired = 2
        dblTap.delegate = self
        map.addGestureRecognizer(dblTap)
        
        progress = UIView(frame: view.bounds)
        progress!.backgroundColor = UIColor.clear
        
        showProgress()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        removeProgress()
        let reachability = note.object as! Reachability
        if reachability.connection == .none{
            let cacheWeather = presenter.getCachedWeather()
            if (cacheWeather.count == 0){
                let error = NSError(domain:"", code:444, userInfo:[ NSLocalizedDescriptionKey: "You are not connected to the internet and you have no cached data, Please try again after you have a stable internet connection."])
                showError(error: error)
            }else{
                for w in cacheWeather{
                    map.removeAnnotations(map.annotations)
                    addAdnotation(weather: w)
                }
                map.showAnnotations(map.annotations, animated: true)
            }
        }else{
            updateCurrLocationUpInside("")
        }
    }
    
    @objc func handleDblTapInMap(_ gestureRecognizer: UIGestureRecognizer){
        if (gestureRecognizer.state != .ended){
            return
        }
        
        if (reachability.connection == .none){
            return
        }
        
        let touchPoint = gestureRecognizer.location(in: map)
        let touchMapCoordinate = map.convert(touchPoint, toCoordinateFrom: map)
        showProgress()
        presenter?.fetchWeatherData(long: touchMapCoordinate.longitude, lat: touchMapCoordinate.latitude, isCurrentLocation: false)

    }
    @IBAction func updateCurrLocationUpInside(_ sender: Any) {
        if (reachability.connection == .none){
            return
        }
        if (CLLocationManager.locationServicesEnabled())
        {
            if (locationManager == nil){
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.startUpdatingLocation()
        }else{
            let error = NSError(domain:"", code:444, userInfo:[ NSLocalizedDescriptionKey: "Location services are turned off. Please turn them on in setings and try again."])
            showError(error: error)
        }
    }
    
    func showProgress(){
        let hudBg = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        hudBg.backgroundColor = UIColor(displayP3Red: 150.0/255, green: 150.0/255, blue: 150.0/255, alpha: 0.9)
        hudBg.layer.cornerRadius = 10
        progress!.addSubview(hudBg)
        hudBg.center = progress!.center
        let progressHud = UIActivityIndicatorView()
        progressHud.style = .whiteLarge
        progressHud.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        progress!.addSubview(progressHud)
        progressHud.center = progress!.center
        progressHud.startAnimating()
        self.view.addSubview(progress!)
    }
    func removeProgress(){
        progress?.removeFromSuperview()
    }
}

extension MapController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        locationManager.stopUpdatingLocation()
        showProgress()
        presenter?.fetchWeatherData(long: location.coordinate.longitude, lat: location.coordinate.latitude, isCurrentLocation: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let error = NSError(domain:"", code:444, userInfo:[ NSLocalizedDescriptionKey: "Could not get current location. Make sure the required permission whas granted in your device settings."])
        showError(error: error)
    }
}

extension MapController: MapView{
    func showError(error: Error) {
        removeProgress()
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didFetchWeather(weather: Weather, isCurrentLocation: Bool) {
        removeProgress()
        if !weather.isValidWeather() {
            return
        }
        let center = CLLocationCoordinate2D(latitude: weather.coord!.lat!, longitude: weather.coord!.lon!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        self.map.setRegion(region, animated: true)
        map.removeAnnotations(map.annotations)
        addAdnotation(weather: weather)
        
        if (!isCurrentLocation) {
            let next = storyboard?.instantiateViewController(withIdentifier: "detail") as! WeatherController
            next.weather = weather
            navigationController?.pushViewController(next, animated: true)
        }
    }
    
    func addAdnotation(weather: Weather){
        let currAnnotation = MKPointAnnotation()
        currAnnotation.coordinate = CLLocationCoordinate2D(latitude: weather.coord!.lat!, longitude: weather.coord!.lon!)
        currAnnotation.title = weather.name! + " \(weather.main!.temp!)F"
        map.addAnnotation(currAnnotation)
    }
    
}

extension MapController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

