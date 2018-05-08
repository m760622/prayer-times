//
//  ShowCityViewController.swift
//  prayer times
//
//  Created by باسم امام on ٢١ شعبان، ١٤٣٩ هـ.
//  Copyright © ١٤٣٩ هـ hammam abdulaziz. All rights reserved.
//

import UIKit
import  Alamofire
import SwiftyJSON
class ShowCityViewController: UIViewController {
    var CityName : String = ""
  
    // labels
    @IBOutlet weak var citynamelable: UILabel!
    @IBOutlet weak var NextPrayerTime: UILabel!
    @IBOutlet weak var FajerPrayerTime: UILabel!
    @IBOutlet weak var DohorPrayerTime: UILabel!
    @IBOutlet weak var AserPrayerTime: UILabel!
    @IBOutlet weak var MaghrebPrayerTime: UILabel!
    @IBOutlet weak var IshaPrayerTime: UILabel!
    // varbles
    var lat : String = ""
    var long : String = ""
    var timeZone : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

     citynamelable.text = CityName // show city name
        
     TimeZoneAPI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    // git location zone and timezone
    func TimeZoneAPI(){
       
        let urls = "https://timezoneapi.io/api/address/?"+CityName // api TimeZone
        Alamofire.request(urls, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    // save JSON result in variable
                    let APITime : JSON = JSON(response.result.value!)
                    
                   let LoctionZone = APITime["data"]["addresses"][0]["location"].stringValue // get loction zone
                //
                   
                   
                    
                    
                    // get lat and sotry it in varbel
                    if let range = LoctionZone.range(of: ",") {
                        self.lat = String(LoctionZone[LoctionZone.startIndex..<range.lowerBound])
                       print(self.lat)
                    }
                    
                    
                       // get long and sotry it in varbel
                    if let range = LoctionZone.range(of: ",") {
                        self.long = String(LoctionZone[range.upperBound...])
                        print(self.long)
                    }
                    
                     let TZone = APITime["data"]["addresses"][0]["datetime"]["offset_gmt"].stringValue // get timezone
               
                  
                    
                    //    // get timezone and sotry it in varbel
                    if let range = TZone.range(of: ":") {
                       self.timeZone = String(TZone[TZone.startIndex..<range.lowerBound])
                        print(self.timeZone)
                    }
                    
                    
                   // call api pray method
                    self.API(lats : self.lat, longs : self.long , timeZones: Int(self.timeZone)!)
                    
                } else {
                    print("Error: \(String(describing: response.result.error))")
                    
                }
        }
    }
    
     //  api pray method
    func API ( lats : String , longs : String , timeZones : Int){
        
        print(timeZones)
        // url of API
        let urls = "http://api.islamhouse.com/v1/Xm9B2ZoddJrvoyGk/services/praytime/get-times/Makkah/"+lats+"/"+longs+"/\(timeZones)/json"
        Alamofire.request(urls, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    // save JSON result in variable
                    let APITime : JSON = JSON(response.result.value!)
                    // show pray time in UI
                
                    
                    
                    self.FajerPrayerTime.text = APITime["times"][0].stringValue
                    self.DohorPrayerTime.text = APITime["times"][2].stringValue
                    self.AserPrayerTime.text = APITime["times"][3].stringValue
                    self.MaghrebPrayerTime.text  = APITime["times"][5].stringValue
                    self.IshaPrayerTime.text =  APITime["times"][6].stringValue
                    
                } else {
                    print("Error: \(String(describing: response.result.error))")
                    
                }
        }
        
        
    }

}
