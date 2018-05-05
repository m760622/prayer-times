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

class ViewController: UIViewController, CLLocationManagerDelegate{
 
    @IBOutlet weak var fajerPrayer: UILabel!

    
    @IBOutlet weak var prayersTableView: UITableView!
    
    @IBOutlet weak var fajerPrayerTime: UILabel!
    
    
    @IBOutlet weak var dohorPrayerTime: UILabel!
    
    @IBOutlet weak var aserPrayer: UILabel!
    
    @IBOutlet weak var dohorPrayer: UILabel!
    
    @IBOutlet weak var maghrebPrayer: UILabel!
    
    @IBOutlet weak var aserPrayerTime: UILabel!
    
    @IBOutlet weak var nextPrayer: UILabel!
    
    @IBOutlet weak var maghrebPrayerTime: UILabel!
    
    @IBOutlet weak var nextPrayerTime: UILabel!
    
    @IBOutlet weak var ishaPrayer: UILabel!
    
    @IBOutlet weak var ishaPrayerTime: UILabel!
    // create loction object
   let loctionManger = CLLocationManager()
    // create variables of latitude and longitude
    var lat : Double = 0
   var long : Double = 0
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // loction configuration
        loctionManger.delegate = self
        loctionManger.desiredAccuracy = kCLLocationAccuracyBest
        loctionManger.requestWhenInUseAuthorization()
        loctionManger.startUpdatingLocation()
        
     
       
  
       
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString: "9FDEE6"),UIColor(hexString: "539AA7")])
    //    prayersLabel.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
        
    //    dohorLabel.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
        nextPrayer.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
        
        nextPrayerTime.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
        
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

}

