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
  
    @IBOutlet weak var citynamelable: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

      citynamelable.text = CityName
        
        TimeZoneAPI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func TimeZoneAPI(){
       
        let urls = "https://timezoneapi.io/api/address/?"+CityName
        Alamofire.request(urls, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    // save JSON result in variable
                    let APITime : JSON = JSON(response.result.value!)
                    
                   let LoctionZone = APITime["data"]["addresses"][0]["location"].stringValue
                
                    var lat : String = ""
                    var long : String = ""
                    var timeZone : String = ""
                   
                    
                    
                    
                    if let range = LoctionZone.range(of: ",") {
                        lat = String(LoctionZone[LoctionZone.startIndex..<range.lowerBound])
                       print(lat)
                    }
                    
                    
                    
                    if let range = LoctionZone.range(of: ",") {
                        long = String(LoctionZone[range.upperBound...])
                        print(long) // prints "123.456.7891"
                    }
                    
                     let TZone = APITime["data"]["addresses"][0]["datetime"]["offset_gmt"].stringValue
               
                  
                    
                    
                    if let range = TZone.range(of: ":") {
                       timeZone = String(TZone[TZone.startIndex..<range.lowerBound])
                        print(timeZone)
                    }
                    
                    
                   
                    self.API(lats : lat, longs : long , timeZones: Int(timeZone)!)
                    
                } else {
                    print("Error: \(String(describing: response.result.error))")
                    
                }
        }
    }
    
    
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
                 print(APITime)
                    
                } else {
                    print("Error: \(String(describing: response.result.error))")
                    
                }
        }
        
        
    }

}
