//
//  WeatherController.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation
import UIKit

class WeatherController: UIViewController{
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var presureLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var windLbl: UILabel!
    @IBOutlet weak var directionLbl: UILabel!
    
    var weather:Weather!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLbl.text = weather.name
        tempLbl.text = "\(weather.main?.temp ?? 0) F"
        descLbl.text = weather.weather != nil ? weather.weather![0].description?.capitalized : ""
        presureLbl.text = "\(weather.main?.pressure ?? 0) hPa"
        humidityLbl.text = "\(weather.main?.humidity ?? 0) %"
        windLbl.text = "\(weather.wind?.speed ?? 0) m/s"
        directionLbl.text = "\(weather.wind?.deg ?? 0)"
    }
}
