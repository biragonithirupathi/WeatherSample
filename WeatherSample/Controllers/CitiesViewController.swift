//
//  CitiesViewController.swift
//  WeatherSample
//
//  Created by 1581079 on 14/03/23.
//

import UIKit

class CitiesViewController: UIViewController {

    @IBOutlet weak var citiesTableView: UITableView!
   
    // Array to hold city names
    var cities = [String]()
    let citiesKey = "cities"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalLoad()
        // Do any additional setup after loading the view.
    }
    }


// Extention to implement Add City and City list view
extension CitiesViewController {
  
    func initalLoad() {
        
        // Navigation with add city(+) option
        self.title = "Cities"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor.white

        // Fetching existing cities list from local storage
        cities = getDataFromUserdefaults(withKey: citiesKey)
        
        citiesTableView.reloadData()

    }
    
    // add city
    @objc func addTapped() {
        
        // Popover to get city as user entry
        let alertController = UIAlertController(title: "Add City", message: "", preferredStyle: .alert)
        
        // Adding textField to enter city
           alertController.addTextField { (textField : UITextField!) -> Void in
               textField.placeholder = "Enter City Name"
           }
        
        // Adding Save button to save enered city
           let save = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
               let name = alertController.textFields![0] as UITextField
               if name.text?.isEmpty == true {
                   self.showAlert(title: "", message: "Please enter city name.")
               } else {
                   
                   // Adding new city to city array and saving it in local storage i.e user defaults
                   self.cities.append(name.text ?? "")
                   self.saveDatainUserDefaults(withKey:self.citiesKey)
                   self.citiesTableView.reloadData()
               }
           })
           let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
           alertController.addAction(save)
           alertController.addAction(cancel)
           
        // Presenting Popover
           self.present(alertController, animated: true, completion: nil)
    }
    
    
    // saving cities array in local storage i.e user defaults
    func saveDatainUserDefaults(withKey: String) {
        UserDefaults.standard.set(cities, forKey: withKey)
    }
    
    // fetching cities array from local storage i.e user defaults
    func getDataFromUserdefaults(withKey: String)-> [String] {
        let savedNumbers = UserDefaults.standard.array(forKey: withKey) as? [String]
        return savedNumbers ?? []
    }
    
    // common alert with message as parameter
    func showAlert(title: String, message: String) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
           present(alertController, animated: true, completion: nil)
       }
      
    // Moving to City detailed weaer report screen
    func navigateToCityDetails(city:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CityDetailsViewController") as! CityDetailsViewController
        vc.city = city
        self.navigationController?.pushViewController(vc, animated: true)

    }
}

// Extention to implement UITableview Delagate and Datasource methods
extension CitiesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitiesCell", for: indexPath) as! CitiesCell
        cell.selectionStyle = .none
        cell.textLabel?.text = cities[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigateToCityDetails(city: cities[indexPath.row])
        
    }
}

