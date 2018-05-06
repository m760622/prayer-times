//
//  ViewController.swift
//  prayer times
//
//  Created by hammam abdulaziz on 15/08/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//

import UIKit
import ChameleonFramework


import Alamofire
import SwiftyJSON
import CoreLocation
import EasyTimer
import GooglePlaces
class ViewController: UIViewController, CLLocationManagerDelegate{

 
    //MARK: Labels
    //MARK: Prayers
    @IBOutlet weak var nextPrayer: UILabel!
    @IBOutlet weak var fajerPrayer: UILabel!
    @IBOutlet weak var dohorPrayer: UILabel!
    @IBOutlet weak var aserPrayer: UILabel!
    @IBOutlet weak var maghrebPrayer: UILabel!
    @IBOutlet weak var ishaPrayer: UILabel!
    //MARK: Times of prayers
    @IBOutlet weak var nextPrayerTime: UILabel!
    @IBOutlet weak var fajerPrayerTime: UILabel!
    @IBOutlet weak var dohorPrayerTime: UILabel!
    @IBOutlet weak var aserPrayerTime: UILabel!
    @IBOutlet weak var maghrebPrayerTime: UILabel!
    @IBOutlet weak var ishaPrayerTime: UILabel!


    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    var countriesEN: [String] = []
    var countriesAR: [String] = []
    //forgoogleplaces
    var placesClient: GMSPlacesClient!

  
  
     // create loction object
   let loctionManger = CLLocationManager()
    // create variables of latitude and longitude
    var lat : Double = 0
   var long : Double = 0
  
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // loction configuration
        loctionManger.delegate = self
        loctionManger.desiredAccuracy = kCLLocationAccuracyBest
        loctionManger.requestWhenInUseAuthorization()
        loctionManger.startUpdatingLocation()
        
        //make the labels black to let the user destinguesh between prayers
        dohorPrayer.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
        dohorPrayerTime.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)

        
        
        //fetch the countries of the worled
        //fetchCountries()
       
        
        placesClient = GMSPlacesClient.shared()
    
    
    }

    
    
    
    func fetchCountries(){
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let englishName = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            let arabicName = NSLocale(localeIdentifier: "ar").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countriesEN.append(englishName)
            countriesAR.append(arabicName)
        }
    }

    
    
    
    
    
    // Add a UIButton in Interface Builder, and connect the action to this function.
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.nameLabel.text = "No current place"
            self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.nameLabel.text = place.name
                    self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                }
            }
        })
    }
    
    

    

 
    

// Api pray Time method
    func API ( lat : Double , long : Double , timeZone : String){
        // url of API
        let urls = "http://api.islamhouse.com/v1/Xm9B2ZoddJrvoyGk/services/praytime/get-times/Makkah/\(lat)/\(long)/\(timeZone)/json"
        Alamofire.request(urls, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                   // save JSON result in variable
                    let APITime : JSON = JSON(response.result.value!)
                   // show pray time in UI
                    self.fajerPrayerTime.text = APITime["times"][0].stringValue
                    self.dohorPrayerTime.text = APITime["times"][2].stringValue
                   self.aserPrayerTime.text = APITime["times"][3].stringValue
                  self.maghrebPrayerTime.text  = APITime["times"][5].stringValue
                   self.ishaPrayerTime.text =  APITime["times"][6].stringValue
                    
                } else {
                    print("Error: \(String(describing: response.result.error))")
                    
                }
        }
        
        
    }
    
    // get latitude longitude data method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        // if data not = 0
        if location.horizontalAccuracy > 0 {
            loctionManger.stopUpdatingLocation()
            // save latitude longitude data
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            
            // call TimeZone Method
          timezone()
            
            
        }
    }
    // timezone method
    func timezone(){
      // get timezone data
        var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
 
      // git only number of timezone using substring
        let timeZone : String = String(localTimeZoneAbbreviation.suffix(2))
        
        
        // call API method
     API( lat: lat, long: long, timeZone: timeZone)
        
        
    }


    
        
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString: "9FDEE6"),UIColor(hexString: "539AA7")])
    }

    
}







