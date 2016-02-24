//
//  CurrentWeather.swift
//  DevTest
//
//  Created by Seth Rininger on 2/23/16.
//  Copyright © 2016 Seth Rininger. All rights reserved.
//

import Foundation
import UIKit

enum Icon: String {
    case ClearDay = "clear-day"
    case ClearNight = "clear-night"
    case Rain = "rain"
    case Snow = "snow"
    case Sleet = "sleet"
    case Wind = "wind"
    case Fog = "fog"
    case Cloudy = "cloudy"
    case PartlyCloudyDay = "partly-cloudy-day"
    case PartlyCloudyNight = "partly-cloudy-night"
    
    func toImage() -> UIImage? {
        var imageName: String
        switch self {
        case .ClearDay:
            imageName = "clear-day.png"
        case .ClearNight:
            imageName = "clear-night.png"
        case .Rain:
            imageName = "rain.png"
        case .Snow:
            imageName = "snow.png"
        case .Sleet:
            imageName = "sleet.png"
        case .Wind:
            imageName = "wind.png"
        case .Fog:
            imageName = "fog.png"
        case .Cloudy:
            imageName = "cloudy.png"
        case .PartlyCloudyDay:
            imageName = "cloudy-day.png"
        case .PartlyCloudyNight:
            imageName = "cloudy-night.png"
        }
        
        return UIImage(named: imageName)
    }
}


struct CurrentWeather {
    
    let temperature: Int?
    var tempMin: [Int?] = [Int?]()
    var tempMax: [Int?] = [Int?]()
    var icon: [UIImage?] = [UIImage]()
    
    init(weatherDictionary: [String: AnyObject], dailyDictionary: [String: AnyObject]) {
        temperature = weatherDictionary["temperature"] as? Int
        
        for i in 0..<7{
            if let minTemp = dailyDictionary["data"]![i]!["temperatureMin"] as? Double {
                tempMin.append(Int(minTemp))
            }
            if let maxTemp = dailyDictionary["data"]![i]!["temperatureMax"] as? Double {
                tempMax.append(Int(maxTemp))
            }
            
            if let iconString = dailyDictionary["data"]![i]!["icon"] as? String,
                let weatherIcon: Icon = Icon(rawValue: iconString) {
                    icon.append(weatherIcon.toImage())
            } else {
                print("Icon failed to load")
                icon.append(UIImage(named: "default.png"))
            }
        }
    }
}