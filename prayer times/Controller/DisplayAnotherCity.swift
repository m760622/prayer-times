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
    //MARK:- Labels
    //MARK: label of the name of the city
    @IBOutlet weak var cityNameLabel: UILabel!
    //MARK: Prayers labels
    @IBOutlet weak var nextPrayer: UILabel!
    @IBOutlet weak var fajerPrayer: UILabel!
    @IBOutlet weak var dohorPrayer: UILabel!
    @IBOutlet weak var aserPrayer: UILabel!
    @IBOutlet weak var maghrebPrayer: UILabel!
    @IBOutlet weak var ishaPrayer: UILabel!
    //MARK: Times of prayers labels
    @IBOutlet weak var nextPrayerTime: UILabel!
    @IBOutlet weak var fajerPrayerTime: UILabel!
    @IBOutlet weak var dohorPrayerTime: UILabel!
    @IBOutlet weak var aserPrayerTime: UILabel!
    @IBOutlet weak var maghrebPrayerTime: UILabel!
    @IBOutlet weak var ishaPrayerTime: UILabel!
    //MARK: spaces of prayers vews
    @IBOutlet weak var fajerPrayerSpace: UIView!
    @IBOutlet weak var dohorPrayerSpace: UIView!
    @IBOutlet weak var aserPrayerSpace: UIView!
    @IBOutlet weak var maghrebPrayerSpace: UIView!
    @IBOutlet weak var ishaPrayerSpace: UIView!
    
    @IBOutlet var fajerPrayerSpaceLeft: UIView!
    @IBOutlet var dohorPrayerSpaceLeft: UIView!
    @IBOutlet var aserPrayerSpaceLeft: UIView!
    @IBOutlet var maghrebPrayerSpaceLeft: UIView!
    @IBOutlet var ishaPrayerSpaceLeft: UIView!
    //MARK: translation
    @IBOutlet var rightWatch: UIButton!
    @IBOutlet var leftWatch: UIButton!
    @IBOutlet var homeButton: UIBarButtonItem!
    var arabicLanguage : Bool = false
    //MARK:- varibels
    //MARK: locations varibels
    var CityName : String = ""
    // create variables of latitude and longitude
    var lat : String = ""
    var long : String = ""
    var timeZone : String = ""
    //MARK: variables of counting the time
    //MARK: variables of counting the time
    var countDownSeconds = 59
    var countDownMinute = 0
    var countDownHour = 0
    var currentMinute : Int?
    var currentHour : Int?
    var timer = Timer()
    //MARK: varible of prayers times
    var timesOfPrayers = [String]()
    var timesOfPrayersEN = [String]()
    var indexOfNextPrayer = 0
    var hourOfPrayerTime: Int?
    var minuteOfPrayTime: Int?
    //MARK: bool varibels
    var isAM : Bool = false
    var isTimerRunning : Bool = false
    
    
    
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        cityNameLabel.text = CityName // show city name
        
        TimeZoneAPI()
        checkIfJumaaOrNot()
        
    }
    
    
    
    
    func getTheLanguage(){
        var languegeDictionary = ["Fajer":"الفجر","Dohor":"الظهر","Aser":"العصر","Maghreb":"المغرب","Isha":"العشاء","":""]

        if !arabicLanguage{
            //convert the time to the left
            setPrayerNameLabels(fajer: timesOfPrayers[0], dohor: timesOfPrayers[1], aser: timesOfPrayers[2], maghreb: timesOfPrayers[3], isha: timesOfPrayers[4])
            
            //assighn the translation and convert it to right
            setPrayerTimeLabels(fajer: languegeDictionary["Fajer"]!, dohor: languegeDictionary["Dohor"]!, aser: languegeDictionary["Aser"]!, maghreb: languegeDictionary["Maghreb"]!, isha: languegeDictionary["Isha"]!)
            nextPrayerTime.text = "الأذان"
            nextPrayer.text = "\(countDownHour):\(countDownMinute):\(countDownSeconds)"
            
            leftWatch.isHidden = false
            rightWatch.isHidden = true
            
            homeButton.title = "الرئيسية"

        }else {
            //convert the time to the rihgt      hint: the time now is in prayers name label
            setPrayerTimeLabels(fajer: fajerPrayer.text!, dohor: dohorPrayer.text!, aser: aserPrayer.text!, maghreb: maghrebPrayer.text!, isha: ishaPrayer.text!)
            
            setPrayerNameLabels(fajer: "Fajer", dohor: "Dohor", aser: "Aser", maghreb: "Maghreb", isha: "Isha")
            
            
            nextPrayer.text = "Next Prayer"
            nextPrayerTime.text = "\(countDownHour):\(countDownMinute):\(countDownSeconds)"
            
            leftWatch.isHidden = true
            rightWatch.isHidden = false
          
            
            homeButton.title = "Home"
        }
    }
    
    
    
    
    // git location zone and timezone
    func TimeZoneAPI(){
        let urls = "https://timezoneapi.io/api/address/?"+CityName // api TimeZone
        Alamofire.request(urls, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    // save JSON result in variable
                    let APITime : JSON = JSON(response.result.value!)
                    // get loction zone
                    let LoctionZone = APITime["data"]["addresses"][0]["location"].stringValue
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
                    // get timezone
                    let TZone = APITime["data"]["addresses"][0]["datetime"]["offset_gmt"].stringValue
                    // get timezone and sotry it in varbel
                    if let range = TZone.range(of: ":") {
                       self.timeZone = String(TZone[TZone.startIndex..<range.lowerBound])
                        print(self.timeZone)
                    }
                    // call api pray method
                    self.API(lats : self.lat, longs : self.long , timeZone: Int(self.timeZone)!)
                } else {
                    print("Error: \(String(describing: response.result.error))")
                }
        }
    }
    
    
    
    
    //FIXME: get times without internet
    //MARK: fetch prayers times from ISLAMHOUS API
    // Api pray Time method
    func API ( lats : String , longs : String , timeZone : Int){
        // url of API
        let urls = "http://api.islamhouse.com/v1/Xm9B2ZoddJrvoyGk/services/praytime/get-times/Makkah/\(lat)/\(long)/\(timeZone)/json"
        Alamofire.request(urls, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    // save JSON result in variable
                    let fetchedPrayerTimes : JSON = JSON(response.result.value!)
                    // show pray time in UI
                    
                    self.timesOfPrayersEN.removeAll()
                    self.timesOfPrayersEN.append(fetchedPrayerTimes["times"][0].stringValue )
                    self.timesOfPrayersEN.append(fetchedPrayerTimes["times"][2].stringValue )
                    self.timesOfPrayersEN.append(fetchedPrayerTimes["times"][3].stringValue )
                    self.timesOfPrayersEN.append(fetchedPrayerTimes["times"][5].stringValue )
                    self.timesOfPrayersEN.append(fetchedPrayerTimes["times"][6].stringValue )
                    self.timesOfPrayers.removeAll()
                    for item in self.timesOfPrayersEN{
                        let arabic = self.convertToArabic(item)
                        self.timesOfPrayers.append(arabic)
                    }
                    
                    if self.arabicLanguage{
                        self.setPrayerTimeLabels(fajer: self.timesOfPrayersEN[0], dohor: self.timesOfPrayersEN[1], aser: self.timesOfPrayersEN[2], maghreb: self.timesOfPrayersEN[3], isha: self.timesOfPrayersEN[4])
                    }else{
                        self.setPrayerNameLabels(fajer: self.timesOfPrayers[0], dohor: self.timesOfPrayers[1], aser: self.timesOfPrayers[2], maghreb: self.timesOfPrayers[3], isha: self.timesOfPrayers[4])
                    }
                    self.determineTheNextPrayer()
                    self.getTheLanguage()
                    
                } else {
                    print("Error: \(String(describing: response.result.error))")
                }
        }
    }
    
    
    
    
    //to set all the labels on the right by values
    func setPrayerTimeLabels(fajer:String,dohor:String,aser:String,maghreb:String,isha:String){
        fajerPrayerTime.text = fajer
        dohorPrayerTime.text = dohor
        aserPrayerTime.text = aser
        maghrebPrayerTime.text = maghreb
        ishaPrayerTime.text = isha
    }
    
    
    
    
    //to set all the labels on the left by values
    func setPrayerNameLabels(fajer:String,dohor:String,aser:String,maghreb:String,isha:String){
        fajerPrayer.text = fajer
        dohorPrayer.text = dohor
        aserPrayer.text = aser
        maghrebPrayer.text = maghreb
        ishaPrayer.text = isha
    }
    
    
    
    
    //MARK:- get and calculate data from fetched data
    //chick which is the next prayer
    func determineTheNextPrayer(){
        fetchCurrentTime()
        
        for index in 0...4{
            getPrayerTime(at: index)
            
            if currentHour! < hourOfPrayerTime! {
                setCountDownTime(at: index)
                break
            }else if currentHour! == hourOfPrayerTime!{
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
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(MainCity.updateTimer)), userInfo: nil, repeats: true)
        SVProgressHUD.dismiss()
    }
    
    
    
    
    //get the currunt time
    func fetchCurrentTime(){
        let date = Date()
        let calendar = Calendar.current
        currentHour = calendar.component(.hour, from: date)
        currentMinute = calendar.component(.minute, from: date)
        countDownSeconds = 59 - calendar.component(.second, from: date)
    }
    
    
    
    
    //get prayer time of the determined prayer from results of api
    func getPrayerTime(at index: Int){
        hourOfPrayerTime = Int(timesOfPrayersEN[index].split(separator: ":")[0])!
        minuteOfPrayTime = Int(timesOfPrayersEN[index].split(separator: ":")[1])!
    }
    
    
    
    
    //compare current time to prayers time to determine the next prayer
    func setCountDownTime(at index: Int){
        countDownHour = hourOfPrayerTime! - currentHour!
        countDownMinute = minuteOfPrayTime! - currentMinute!
        if countDownMinute < 0 {
            countDownMinute = 59 + countDownMinute
            countDownHour = countDownHour - 1
        }
        indexOfNextPrayer = index
        updateNextPrayerColores()
    }
    
    
    
    
    //MARK:- show updates on screen
    //make the next prayer bold to destinguish it
    func updateNextPrayerColores(){
        switch(indexOfNextPrayer){
        case 0 :do {
            makeBold(atPrayer: fajerPrayer, atTime: fajerPrayerTime, atright: fajerPrayerSpace, atLeft: fajerPrayerSpaceLeft)
            makeBright(atPrayer: ishaPrayer, atTime: ishaPrayerTime, atright: ishaPrayerSpace, atLeft: ishaPrayerSpaceLeft)
            }
        case 1 :do {
            makeBold(atPrayer: dohorPrayer, atTime: dohorPrayerTime, atright: dohorPrayerSpace, atLeft: dohorPrayerSpaceLeft)
            makeBright(atPrayer: fajerPrayer, atTime: fajerPrayerTime, atright: fajerPrayerSpace, atLeft: fajerPrayerSpaceLeft)
            }
        case 2 :do {
            makeBold(atPrayer: aserPrayer, atTime: aserPrayerTime, atright: aserPrayerSpace, atLeft: aserPrayerSpaceLeft)
            makeBright(atPrayer: dohorPrayer, atTime: dohorPrayerTime, atright: dohorPrayerSpace, atLeft: dohorPrayerSpaceLeft)
            }
        case 3 :do {
            makeBold(atPrayer: maghrebPrayer, atTime: maghrebPrayerTime, atright: maghrebPrayerSpace, atLeft: maghrebPrayerSpaceLeft)
            makeBright(atPrayer: aserPrayer, atTime: aserPrayerTime, atright: aserPrayerSpace, atLeft: aserPrayerSpaceLeft)
            }
        case 4 :do {
            makeBold(atPrayer: ishaPrayer, atTime: ishaPrayerTime, atright: ishaPrayerSpace, atLeft: ishaPrayerSpaceLeft)
            makeBright(atPrayer: maghrebPrayer, atTime: maghrebPrayerTime, atright: maghrebPrayerSpace, atLeft: maghrebPrayerSpaceLeft)
            }
        default:print("error")
        }
    }
    
    
    
    
    //make the determined prayer bold to distinguesh it between the others
    func makeBold(atPrayer prayerLabel: UILabel ,atTime prayerTime: UILabel ,atright prayerSpace: UIView,atLeft prayerSpaceLeft: UIView){
        //make the labels black to let the user destinguesh between prayers
        prayerLabel.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0.5)
        prayerTime.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0.5)
        prayerSpace.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0.5)
        prayerSpaceLeft.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0.5)
    }
    
    
    
    
    //if the pray is boled and no need for it make it go back to original
    func makeBright(atPrayer prayerLabel: UILabel ,atTime prayerTime: UILabel ,atright prayerSpace: UIView,atLeft prayerSpaceLeft: UIView){
        prayerLabel.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0)
        prayerTime.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0)
        prayerSpace.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0)
        prayerSpaceLeft.backgroundColor = UIColor(hexString: "023F56").withAlphaComponent(0)
    }
    
    
    
    
    //updates the time on next prayer every second
    @objc func updateTimer() {
        isTimerRunning = !isTimerRunning ? isTimerRunning : isTimerRunning
        if countDownSeconds == 0 {
            
            if countDownMinute == 0{
                //  countDownMinute = 59
                if countDownHour == 0 {
                    // here is the time for azan
                    determineTheNextPrayer()
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
        
        
        if arabicLanguage{
            nextPrayerTime.text = "\(countDownHour):\(countDownMinute):\(countDownSeconds)"
        }else{
            nextPrayer.text = "\(convertToArabic("\(countDownHour)")):\(convertToArabic("\(countDownMinute)")):\(convertToArabic("\(countDownSeconds)"))"
        }
        //set the notification
    }
    
    
    
    
    //check jumaa
    func checkIfJumaaOrNot(){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayInWeek = formatter.string(from: date)
        
        if (dayInWeek == "Friday"){
            dohorPrayer.text = "Friday"
        }
    }
    
    
    
    
    //MARK:- Buttons
    //convert the time form
    @IBAction func convertionBetweenAMAndPM(_ sender: UIButton) {
        if isAM {
            
            if !arabicLanguage{
                setPrayerNameLabels(fajer: timesOfPrayers[0], dohor: timesOfPrayers[1], aser: timesOfPrayers[2], maghreb: timesOfPrayers[3], isha: timesOfPrayers[4])
            }else{
                setPrayerTimeLabels(fajer: timesOfPrayersEN[0], dohor: timesOfPrayersEN[1], aser: timesOfPrayersEN[2], maghreb: timesOfPrayersEN[3], isha: timesOfPrayersEN[4])
            }
            
            isAM = !isAM
        }else{
            var fajer = convertToAM(time: getHour(prayNumber: 0), prayNumber: 0)
            var dohor = convertToAM(time: getHour(prayNumber: 1), prayNumber: 1)
            var aser = convertToAM(time: getHour(prayNumber: 2), prayNumber: 2)
            var maghreb = convertToAM(time: getHour(prayNumber: 3), prayNumber: 3)
            var isha = convertToAM(time: getHour(prayNumber: 4), prayNumber: 4)
            if !arabicLanguage{
                fajer = convertToArabic(fajer)
                dohor = convertToArabic(dohor)
                aser = convertToArabic(aser)
                maghreb = convertToArabic(maghreb)
                isha = convertToArabic(isha)
                setPrayerNameLabels(fajer: fajer, dohor: dohor, aser: aser, maghreb: maghreb, isha: isha)
            }else{
                setPrayerTimeLabels(fajer: fajer, dohor: dohor, aser: aser, maghreb: maghreb, isha: isha)
            }
            
            isAM = !isAM
        }
    }
    
    
    @IBAction func homeButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    //git the prayer time and convert it in am,pm mode
    func convertToAM(time : Int , prayNumber: Int) -> String{
        if time > 12 {
            
            if arabicLanguage{
                
            }else{
                
            }
            if time < 22{
                return "0\(time - 12):\(Int(timesOfPrayersEN[prayNumber].split(separator: ":")[1])!) PM"
            }else{
                return "\(time - 12):\(Int(timesOfPrayersEN[prayNumber].split(separator: ":")[1])!) PM"
            }
            
            
        }
        else {
            
            if time < 10{
                return "0\(time):\(Int(timesOfPrayersEN[prayNumber].split(separator: ":")[1])!) AM"
            }else{
                return "\(time):\(Int(timesOfPrayersEN[prayNumber].split(separator: ":")[1])!) AM"
            }
            
        }
    }
    
    
    
    
    //git hour of prayer time
    func getHour(prayNumber : Int) -> Int{
        return Int(timesOfPrayersEN[prayNumber].split(separator: ":")[0])!
    }
    
    
    
    
    //convert numbers to arabic
    func convertToArabic(_ numberToConvert: String) -> String{
        
        let numbers = ["1":"١","2":"٢","3":"٣","4":"٤","5":"٥","6":"٦","7":"٧","8":"٨","9":"٩","0":"٠",":":":","P":"م","A":"ص","M":""," ":" "]
        var convertedNumber : String = ""
        let time = Array(numberToConvert.characters)
        
        for index in 0...time.count - 1 {
            convertedNumber.append(numbers["\(time[index])"]!)
        }
        return convertedNumber
    }
}

