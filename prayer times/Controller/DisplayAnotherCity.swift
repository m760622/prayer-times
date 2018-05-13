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

import SVProgressHUD

class DisplayAnotherCity: UIViewController {
    var CityName : String = ""
  
    //MARK: Prayers labels
    @IBOutlet weak var nextPrayer: UILabel!
    @IBOutlet weak var fajerPrayer: UILabel!
    @IBOutlet weak var dohorPrayer: UILabel!
    @IBOutlet weak var aserPrayer: UILabel!
    @IBOutlet weak var maghrebPrayer: UILabel!
    @IBOutlet weak var ishaPrayer: UILabel!
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

    //MARK: variables of counting the time
    var countDownSeconds = 59
    var countDownMinute = 0
    var countDownHour = 0
    var currentMinute : Int?
    var currentHour : Int?
    var timer = Timer()
    var timesOfPrayers = [String]()
    var indexOfNextPrayer = 0
    var hourOfPrayerTime: Int?
    var minuteOfPrayTime: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayInWeek = formatter.string(from: date)
        
        if (dayInWeek == "Friday"){
            dohorPrayer.text = "Friday"
        }
        
        

        SVProgressHUD.show()
     citynamelable.text = CityName // show city name
        
     TimeZoneAPI()
        
    }

    @IBAction func homeButtonPressed(_ sender: UIBarButtonItem) {
        
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
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

             
                    let fetchedPrayerTimes : JSON = JSON(response.result.value!)
                    // show pray time in UI
                
                    
                    

                    self.FajerPrayerTime.text = fetchedPrayerTimes["times"][0].stringValue
                    self.DohorPrayerTime.text = fetchedPrayerTimes["times"][2].stringValue
                    self.AserPrayerTime.text = fetchedPrayerTimes["times"][3].stringValue
                    self.MaghrebPrayerTime.text  = fetchedPrayerTimes["times"][5].stringValue
                    self.IshaPrayerTime.text =  fetchedPrayerTimes["times"][6].stringValue
                    
                    
                    self.timesOfPrayers.removeAll()
                    self.timesOfPrayers.append(fetchedPrayerTimes["times"][0].stringValue )
                    self.timesOfPrayers.append(fetchedPrayerTimes["times"][2].stringValue )
                    self.timesOfPrayers.append(fetchedPrayerTimes["times"][3].stringValue )
                    self.timesOfPrayers.append(fetchedPrayerTimes["times"][5].stringValue )
                    self.timesOfPrayers.append(fetchedPrayerTimes["times"][6].stringValue )
                   
                    self.determineTheNextPrayer()

                    
                } else {
                    print("Error: \(String(describing: response.result.error))")
                    
                }
        }
        
        
    }

    
    
    
    
    //MARK:- show updates on screen
    //chek which is the next prayer
    func determineTheNextPrayer(){
        fetchCurrentTime()
        for index in 0...4{
            getPrayerTime(at: index)
            
            if currentHour! <= hourOfPrayerTime! {
                
                if currentMinute! < minuteOfPrayTime!{
                    setCountDownTime(at: index)
                    
                }else {
                    // if current minutes is greater so it will count to the next pray
                    getPrayerTime(at: index + 1)
                    setCountDownTime(at: index + 1)
                }
                break
            }
        }
        
        //to show the result on screen and update it every second
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(DisplayAnotherCity.updateTimer)), userInfo: nil, repeats: true)
        SVProgressHUD.dismiss()
    }
    
    
    
    
    //fetch the date and time
    func fetchCurrentTime(){
        let date = Date()
        let calendar = Calendar.current
        currentHour = calendar.component(.hour, from: date)
        currentMinute = calendar.component(.minute, from: date)
    }
    
    
    
    
    //get prayer time of the determined prayer to compare it with current time
    func getPrayerTime(at index: Int){
        hourOfPrayerTime = Int(timesOfPrayers[index].split(separator: ":")[0])!
        minuteOfPrayTime = Int(timesOfPrayers[index].split(separator: ":")[1])!
        
    }
    
    
    
    
    
    //set the Values of count down numbers to the next prayer
    func setCountDownTime(at index: Int){
        countDownHour = hourOfPrayerTime! - currentHour!
        countDownMinute = minuteOfPrayTime! - currentMinute!
        if countDownMinute < 0 {
            countDownMinute = 59 - countDownMinute
            countDownHour = countDownHour - 1
        }
        indexOfNextPrayer = index
        updateNextPrayerColores()
    }
    
    
    
    //make the next prayer  bold to destinguish it
    func updateNextPrayerColores(){
        switch(indexOfNextPrayer){
        case 0 :do {
            makeBold(atPrayer: fajerPrayer, atTime: FajerPrayerTime)
            makeBright(atPrayer: ishaPrayer, atTime: IshaPrayerTime)
            }
        case 1 :do {
            makeBold(atPrayer: dohorPrayer, atTime: DohorPrayerTime)
            makeBright(atPrayer: fajerPrayer, atTime: FajerPrayerTime)
            }
        case 2 :do {
            makeBold(atPrayer: aserPrayer, atTime: AserPrayerTime)
            makeBright(atPrayer: dohorPrayer, atTime: DohorPrayerTime)
            }
        case 3 :do {
            makeBold(atPrayer: maghrebPrayer, atTime: MaghrebPrayerTime)
            makeBright(atPrayer: aserPrayer, atTime: AserPrayerTime)
            }
        case 4 :do {
            makeBold(atPrayer: ishaPrayer, atTime: IshaPrayerTime)
            makeBright(atPrayer: maghrebPrayer, atTime: MaghrebPrayerTime)
            }
        default:print("error")
            
            
        }
    }
    
    
    
    
    func makeBold(atPrayer prayerLabel: UILabel ,atTime prayerTime: UILabel){
        //make the labels black to let the user destinguesh between prayers
        prayerLabel.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0.5)
        prayerTime.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0.5)
        
    }
    
    
    
    
    func makeBright(atPrayer prayerLabels: UILabel, atTime prayerTime: UILabel){
        prayerLabels.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0)
        prayerTime.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0)
    }
    
    
    
    
    //the function runs every seconed to show the rest time to nearest prayer
    @objc func updateTimer() {
        
        if countDownSeconds == 0 {
            
            if countDownMinute == 0{
                //  countDownMinute = 59
                if countDownHour == 0 {
                    // here is the time for azan
                    if indexOfNextPrayer == 4 {
                        //if it is isha pray so next will be fajer
                        indexOfNextPrayer = -1
                    }
                    
                    getPrayerTime(at: indexOfNextPrayer + 1)
                    setCountDownTime(at: indexOfNextPrayer + 1)
                    
                }else{
                    countDownHour -= 1
                    countDownMinute = 59
                    countDownSeconds = 59
                }
            }else{
                countDownMinute -= 1
                countDownSeconds = 59
            }
        }else{
            countDownSeconds -= 1
        }
        NextPrayerTime.text = "\(countDownHour):\(countDownMinute):\(countDownSeconds)"
        
    }

}
