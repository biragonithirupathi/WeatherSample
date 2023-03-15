//
//  CityDetailsViewController.swift
//  WeatherSample
//
//  Created by 1581079 on 14/03/23.
//

import UIKit
import CoreLocation

class CityDetailsViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var weatherResult: Result?

    @IBOutlet weak var rightNowView: RightNowView!
    @IBOutlet weak var weatherDetailView: WeatherDetailView!
    var city = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func initialLoad() {
        clearAll()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.getLocation(forPlaceCalled: city) { location in
                    guard let location = location else { return }
                    
                    NetworkManager.shared.setLatitude(location.coordinate.latitude)
                    NetworkManager.shared.setLongitude(location.coordinate.longitude)
                    self.getWeatherData()

                }

    }
    
    func clearAll() {
        rightNowView.clear()
        weatherDetailView.clear()
    }
    
    func showAlert(title: String, message: String) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
           present(alertController, animated: true, completion: nil)
       }
    
    func getLocation(forPlaceCalled name: String,
                        completion: @escaping(CLLocation?) -> Void) {
           
           let geocoder = CLGeocoder()
           geocoder.geocodeAddressString(name) { placemarks, error in
               
               guard error == nil else {
                   // if we recieve error then enters this block
                   self.showAlert(title: "", message: error!.localizedDescription)
                   print("*** Error in \(#function): \(error!.localizedDescription)")
                   completion(nil)
                   return
               }
               
               guard let placemark = placemarks?[0] else {
                   print("*** Error in \(#function): placemark is nil")
                   self.showAlert(title: "", message: "placemark is nil")

                   completion(nil)
                   return
               }
               
               guard let location = placemark.location else {
                   self.showAlert(title: "", message: "placemark is nil")

                   print("*** Error in \(#function): placemark is nil")
                   completion(nil)
                   return
               }

               // Reaches here if we get valide location
               completion(location)
           }
       }
    
    // If Today and Weekly toggle changed
    @IBAction func todayWeeklyValueChanged(_ sender: UISegmentedControl) {
        clearAll()
        updateViews()
    }
    
    // If tapped on Refresh button
    @IBAction func getWeatherTapped(_ sender: UIButton) {
        clearAll()
        getWeatherData()
    }
}


extension CityDetailsViewController {
  
    func getWeatherData() {
        
        // Calling Weather API to get weather data
        NetworkManager.shared.getWeather(onSuccess: { (result) in
            
            self.weatherResult = result
            
            self.weatherResult?.sortDailyArray()
            self.weatherResult?.sortHourlyArray()
            
            self.updateViews()
            
        }) { (errorMessage) in
            debugPrint(errorMessage)
            self.showAlert(title: "", message: errorMessage)

        }
       
    }
    
    func updateViews() {
        updateTopView()
        updateBottomView()
    }
    
    func updateTopView() {
        guard let weatherResult = weatherResult else {
            return
        }
        
        rightNowView.updateView(currentWeather: weatherResult.current, city: city)
    }
    
    func updateBottomView() {
        guard let weatherResult = weatherResult else {
            return
        }
        
        // Checking for Weekly or Today selection and loading data accordingly
        let title = weatherDetailView.getSelectedTitle()
        
        if title == "Today" {
            weatherDetailView.updateViewForToday(weatherResult.hourly)
        } else if title == "Weekly" {
            weatherDetailView.updateViewForWeekly(weatherResult.daily)
        }
    }
    
}

