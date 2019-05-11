//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Muhammad Elbagoury on 24/04/2019.
//  Copyright (c) 2019 Muhammad Elbagoury. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "89067060f677b035aead08d987e7a3d4"
    

    //Declaring instance variables
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    

    //IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //getWeatherData method to send requests to get weather back
    func getWeatherData(url: String, parameters: [String:String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON: JSON = JSON(response.result.value!)
                //print("JSON: \(weatherJSON)")
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                print("Error: \(response.result.error?.localizedDescription ?? "There is an error in getting data")")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    //updateWeatherData method to congigure weatherDataModel
    func updateWeatherData(json: JSON) {
        let tempResult = json["main"]["temp"].doubleValue
        //print(tempResult)
        weatherDataModel.temperature = Int(tempResult - 273.15)
        
        weatherDataModel.city = json["name"].stringValue
        
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        updateUIWithWeatherData()
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    //updateUIWithWeatherData method to display weather data on screen
    func updateUIWithWeatherData() {
        temperatureLabel.text = String(weatherDataModel.temperature) + "°"
        cityLabel.text = weatherDataModel.city
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //didUpdateLocations method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            //print("Longitude = \(location.coordinate.longitude), Latitude = \(location.coordinate.latitude)")

            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String:String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //didFailWithError method
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    //userEnteredANewCityName Delegate method
    func userEnteredANewCityName(city: String) {
        //print(city)
        let params: [String:String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //PrepareForSegue method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
}


