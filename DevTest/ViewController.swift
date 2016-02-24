//
//  ViewController.swift
//  DevTest
//
//  Created by Seth Rininger on 2/20/16.
//  Copyright © 2016 Seth Rininger. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {

    //days of week
    @IBOutlet weak var day1: UILabel!
    @IBOutlet weak var day2: UILabel!
    @IBOutlet weak var day3: UILabel!
    @IBOutlet weak var day4: UILabel!
    @IBOutlet weak var day5: UILabel!
    @IBOutlet weak var day6: UILabel!
    @IBOutlet weak var day7: UILabel!

    //weather icons describing weather
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var icon2: UIImageView!
    @IBOutlet weak var icon3: UIImageView!
    @IBOutlet weak var icon4: UIImageView!
    @IBOutlet weak var icon5: UIImageView!
    @IBOutlet weak var icon6: UIImageView!
    @IBOutlet weak var icon7: UIImageView!
    
    //hi and low temperatures of the day
    @IBOutlet weak var hiLow1: UILabel!
    @IBOutlet weak var hiLow2: UILabel!
    @IBOutlet weak var hiLow3: UILabel!
    @IBOutlet weak var hiLow4: UILabel!
    @IBOutlet weak var hiLow5: UILabel!
    @IBOutlet weak var hiLow6: UILabel!
    @IBOutlet weak var hiLow7: UILabel!
    
    //location/orientation info
    @IBOutlet weak var coordinates: UILabel?
    @IBOutlet weak var slope: UILabel?
    @IBOutlet weak var azimuth: UILabel?
    @IBOutlet weak var temperature: UILabel?
    
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    
    //variables
    var slo: Double?
    var lat: Double?
    var lon: Double?
    var azi: Double?
    var temp: Int?
    var haveRetrievedForecast: Bool = false
    
    private let forecastAPIKey : String = "4b0324a6ed0c367123374acdc3476970"
    var coordinate: (lat: Double, long: Double)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.headingFilter = kCLHeadingFilterNone
        
        //begin updating statistics
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        findMySlope()
    }
    
    func findMySlope(){
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                data, error in
                
                if error == nil {
                    self.slo = Double(data!.gravity.z * 90.0)
                    self.slope?.text = "\(Int(data!.gravity.z * 90.0))°"
                } else {
                    print("Motion manager failed with error" + error!.localizedDescription)
                }
            }
        }
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
            motionManager.stopDeviceMotionUpdates()
            swapHiddenOutlets(true)
            haveRetrievedForecast = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.azi = newHeading.magneticHeading
        self.azimuth!.text = "\(Int(newHeading.magneticHeading))°"
    }
        
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.lat = pm.location!.coordinate.latitude
                self.lon = pm.location!.coordinate.longitude
                self.coordinate = (self.lat!, self.lon!)
                self.coordinates?.text = "Lat: \(self.lat!)\nLon: \(self.lon!)"
                if self.haveRetrievedForecast == false {
                    self.retrieveWeatherForecast()
                    self.haveRetrievedForecast = true
                }
                
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func retrieveWeatherForecast() {
        let forecastService = ForecastService(APIKey: forecastAPIKey)
        forecastService.getForecast(coordinate!.lat, long: coordinate!.long) {
            (let currently) in
            if let currentWeather = currently {
                dispatch_async(dispatch_get_main_queue()) {
                    if let currentTemperature = currentWeather.temperature {
                        self.temperature?.text = "\(currentTemperature)°"
                        self.temp = currentTemperature
                    }
                    
                    // Arrays for Outlet ease of use.
                    var dayArray: [UILabel!] =  { [self.day1, self.day2, self.day3, self.day4, self.day5, self.day6, self.day7] }()
                    var hiLowArray: [UILabel!] =  { [self.hiLow1, self.hiLow2, self.hiLow3, self.hiLow4, self.hiLow5, self.hiLow6, self.hiLow7] }()
                    var iconViewArray: [UIImageView!] =  { [self.icon1, self.icon2, self.icon3, self.icon4, self.icon5, self.icon6, self.icon7] }()
                    
                    //dateFormatter
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "EEE"
                    var now = NSDate()
                    
                    
                    for i in 0..<7 {
                        let dayOfWeekString = formatter.stringFromDate(now)
                        dayArray[i].text = "\(dayOfWeekString)."
                        now = now.dateByAddingTimeInterval(60*60*24*1)
                    }
                    if let hi: [Int?] = currentWeather.tempMax,
                        let low: [Int?] = currentWeather.tempMin {
                        for i in 0..<7 {
                            hiLowArray[i].text = "\(low[i]!)°-\(hi[i]!)°"
                        }
                    }
                    if let icons: [UIImage?] = currentWeather.icon {
                        for i in 0..<7 {
                            iconViewArray[i].image = icons[i]!
                        }
                    }
                }
            }
            
        }
        
    }
    
    func swapHiddenOutlets(shouldHide: Bool) {
        coordinates?.hidden = shouldHide
        slope?.hidden = shouldHide
        azimuth?.hidden = shouldHide
        temperature?.hidden = shouldHide
        
        var dayArray: [UILabel!] =  { [self.day1, self.day2, self.day3, self.day4, self.day5, self.day6, self.day7] }()
        var hiLowArray: [UILabel!] =  { [self.hiLow1, self.hiLow2, self.hiLow3, self.hiLow4, self.hiLow5, self.hiLow6, self.hiLow7] }()
        var iconViewArray: [UIImageView!] =  { [self.icon1, self.icon2, self.icon3, self.icon4, self.icon5, self.icon6, self.icon7] }()
        
        for i in 0..<7 {
        dayArray[i].hidden = shouldHide
        iconViewArray[i].hidden = shouldHide
        hiLowArray[i].hidden = shouldHide
        }
    }
    
    @IBAction func refreshButtonWasPressed(sender: AnyObject) {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        findMySlope()
        swapHiddenOutlets(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

