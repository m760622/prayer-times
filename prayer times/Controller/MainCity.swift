//
//  ViewController.swift
//  prayer times
//
//  Created by hammam abdulaziz on 15/08/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//
//TODO:fix am
//TODO:fix notification
//TODO:fix bright of next prayer
//TODO:bring comment from old code
//TODO:fix synce of time

import UIKit
import ChameleonFramework
import Alamofire
import SwiftyJSON
import CoreLocation
import GooglePlaces
import AVFoundation
import UserNotifications
import SVProgressHUD


class MainCity: UIViewController, CLLocationManagerDelegate {
    var audioPlayer : AVAudioPlayer!
 
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
    
    @IBOutlet weak var cityNameLabel: UILabel!

    //array of all the countries
    var countriesEN: [String] = []
    var countriesAR: [String] = []
    
    //google api to fetch the name of the city
    var placesClient: GMSPlacesClient!
    
    // create loction object
    let loctionManger = CLLocationManager()
    
    // create variables of latitude and longitude
    var lat : Double = 0
    var long : Double = 0
  
    
    var countDownSeconds = 59
    var countDownMinute = 0
    var countDownHour = 0
    var currentMinute : Int?
    var currentHour : Int?
    var timer = Timer()
    var isTimerRunning = false
    var timesOfPrayers = [String]()
    var indexOfNextPrayer = 0
    var hourOfPrayerTime: Int?
    var minuteOfPrayTime: Int?
    var isAM : Bool = false
    
    
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (didallow, error) in
        }
        // loction configuration

        loctionManger.delegate = self
        loctionManger.desiredAccuracy = kCLLocationAccuracyBest
        loctionManger.requestWhenInUseAuthorization()
        
       
        
        //make the labels black to let the user destinguesh between prayers
//        dohorPrayer.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
//        dohorPrayerTime.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
//
        
        //fetch the countries of the worled
        //fetchCountries()
        
        placesClient = GMSPlacesClient.shared()
        getCityName()
        getLocation()
        sendNotification()
    }
    
    
    
    //fill the arrays with the countries
    func fetchCountries(){
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let englishName = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            let arabicName = NSLocale(localeIdentifier: "ar").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countriesEN.append(englishName)
            countriesAR.append(arabicName)
        }
    }
    
    
    
    //TODO: consider if want to change the value of city in local 
    //bring the city name from gps and display it in screen
     func getCityName() {
        if let cityName = UserDefaults.standard.string(forKey: "cityName"){
            self.cityNameLabel.text = cityName
        }else{
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
              
                    self.cityNameLabel.text = place.addressComponents![3].name
                    UserDefaults.standard.set(place.addressComponents![3].name , forKey: "cityName")
                }
            }
        })
        }
        
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
                    
                    self.timesOfPrayers.removeAll()
                    self.timesOfPrayers.append(APITime["times"][0].stringValue )
                    self.timesOfPrayers.append(APITime["times"][2].stringValue )
                    self.timesOfPrayers.append(APITime["times"][3].stringValue )
                    self.timesOfPrayers.append(APITime["times"][5].stringValue )
                    self.timesOfPrayers.append(APITime["times"][6].stringValue )
                    
                    SVProgressHUD.dismiss()
                    self.determineTheNextPrayer()

                } else {
                    print("Error: \(String(describing: response.result.error))")
                    
                }
        }
    }
    
    
    
    
    // get latitude longitude data method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if  UserDefaults.standard.double(forKey: "lat") != nil &&  UserDefaults.standard.double(forKey: "long") != nil {
            lat = UserDefaults.standard.double(forKey: "lat")
            long = UserDefaults.standard.double(forKey: "long")
            timezone()

        }else{
        let location = locations[locations.count - 1]
        // if data not = 0
        if location.horizontalAccuracy > 0 {
            loctionManger.stopUpdatingLocation()
            // save latitude longitude data
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            UserDefaults.standard.set(lat, forKey: "lat")
            UserDefaults.standard.set(long, forKey: "long")
            
            // call TimeZone Method
            timezone()
        }
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
    
    
    
    
    func playSound(){
        
        if let url = Bundle.main.url(forResource: "019--1", withExtension: "mp3"){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        }catch{
            print(error)
        }
            audioPlayer.play()
            
        }
    }
    
    
    
    //track the shacking of the phone
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
    }
    
    
    
    
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
    }
    
    
    
    
    func fetchCurrentTime(){
        let date = Date()
        let calendar = Calendar.current
        currentHour = calendar.component(.hour, from: date)
        currentMinute = calendar.component(.minute, from: date)
        countDownSeconds = 59 - calendar.component(.second, from: date)
    }
    
    
    
    
    
    func getPrayerTime(at index: Int){
        hourOfPrayerTime = Int(timesOfPrayers[index].split(separator: ":")[0])!
        minuteOfPrayTime = Int(timesOfPrayers[index].split(separator: ":")[1])!
    }
    
    
    
    
    
    
    func setCountDownTime(at index: Int){
        countDownHour = hourOfPrayerTime! - currentHour!
        countDownMinute = minuteOfPrayTime! - currentMinute!
        if countDownMinute < 0 {
            countDownMinute = 59 - countDownMinute
            countDownHour = countDownHour - 1
        }
        indexOfNextPrayer = index
        
        //to show the result on screen and update it every second
        //if timer.timeInterval > 1 {timer.timeInterval.distance(to: 1)}
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(MainCity.updateTimer)), userInfo: nil, repeats: true)
        

    }
    
    
    
    
    @objc func updateTimer() {
        
        isTimerRunning = !isTimerRunning ? isTimerRunning : isTimerRunning
        
        if countDownSeconds == 0 {
            
            if countDownMinute == 0{
                //  countDownMinute = 59
                if countDownHour == 0 {
                    // here is the time for azan
                    determineTheNextPrayer()
                    playSound()
                    
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
        nextPrayerTime.text = "\(countDownHour):\(countDownMinute):\(countDownSeconds)"
        
        //set the notification
        if countDownHour == 0 && countDownMinute == 5 && countDownSeconds == 0 {
            
            sendNotification()
        }
    }
    
    
    
    
    func getLocation(){
      
        if  UserDefaults.standard.double(forKey: "lat") != nil &&  UserDefaults.standard.double(forKey: "long") != nil {
            lat = UserDefaults.standard.double(forKey: "lat")
            long = UserDefaults.standard.double(forKey: "long")
            timezone()
            
        }else{
            loctionManger.startUpdatingLocation()
            locationManager(CLLocationManager.init(), didUpdateLocations: [CLLocation].init())
          
        }
    }
    
    
    
    
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        SVProgressHUD.show()
        getCityName()

        loctionManger.startUpdatingLocation()
        locationManager(CLLocationManager.init(), didUpdateLocations: [CLLocation].init())
    }
    
    
    
    
    func sendNotification(){
        let prayers = ["fajer","dohor","asr","maghreb","isha"]
        
        let content = UNMutableNotificationContent()
        content.title = "\(prayers[indexOfNextPrayer]) azan will be after 5 minutes"
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "azanSoon", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    
    @IBAction func convertionBetweenAMAndPM(_ sender: UIButton) {
      
        
        
        if isAM {
            fajerPrayerTime.text = timesOfPrayers[0]
            dohorPrayerTime.text = timesOfPrayers[1]
            aserPrayerTime.text = timesOfPrayers[2]
            maghrebPrayerTime.text = timesOfPrayers[3]
            ishaPrayerTime.text = timesOfPrayers[4]
            isAM = !isAM
            
        }else{
            fajerPrayerTime.text = convertToAM(time: getHour(prayNumber: 0), prayNumber: 0)
            dohorPrayerTime.text = convertToAM(time: getHour(prayNumber: 1), prayNumber: 1)
            aserPrayerTime.text = convertToAM(time: getHour(prayNumber: 2), prayNumber: 2)
            maghrebPrayerTime.text = convertToAM(time: getHour(prayNumber: 3), prayNumber: 3)
            ishaPrayerTime.text = convertToAM(time: getHour(prayNumber: 4), prayNumber: 4)
            isAM = !isAM
        }
        
        
    }
    
    
    
    
    func convertToAM(time : Int , prayNumber: Int) -> String{
        
        if time > 12 {
            
            return "\(time - 12) : \(Int(timesOfPrayers[prayNumber].split(separator: ":")[1])!) PM"
           
        }
        else {
            
            return "\(time) : \(Int(timesOfPrayers[prayNumber].split(separator: ":")[1])!) AM" }
    }
    
    
    
    
    func getHour(prayNumber : Int) -> Int{
        
        return Int(timesOfPrayers[prayNumber].split(separator: ":")[0])!
    }
    
}






