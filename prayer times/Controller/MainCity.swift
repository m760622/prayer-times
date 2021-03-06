// ViewController.swift
// prayer times
//
// Created by hammam abdulaziz on 15/08/1439 AH.
// Copyright © 1439 hammam abdulaziz. All rights reserved.
//TODO:add the time of every city
//TODO:add silence mode at prayer time
//TODO:add city to the user screen
//TODO:consider summer time
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
    @IBOutlet var titleLabel: UINavigationItem!
    //MARK:- varibels
    //MARK: array of all the countries
    var countriesEN: [String] = []
    var countriesAR: [String] = []
    //MARK: locations varibels
    //google api to fetch the name of the city
    var placesClient: GMSPlacesClient!
    //create loction object
    let loctionManger = CLLocationManager()
    // create variables of latitude and longitude
    var lat : Double = 0
    var long : Double = 0
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
    var updateLocation : Bool = false
    var isNotArabic : Bool = true
    //MARK: varible of the sound
    var audioPlayer : AVAudioPlayer!
    
    
    
    //FIXME:performance of device
    override func viewWillAppear(_ animated: Bool) {
        
        getStatusOfTheApp()
     // getAMAndLanguage()
        getLocation()
    }
    
    
    
    
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show()
        getStatusOfTheApp()
        //fetch the countries of the worled
        //fetchCountries()
        placesClient = GMSPlacesClient.shared()
        getCityName()

        // loction configuration
        getLocation()
        
        checkIfJumaaOrNot()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (didallow, error) in
        }
    }
    
    
    
    
    //to translat any word to any language
    func translateAPI(){
      //let text = "%D8%A7%D9%84%D9%85%D8%AF%D9%8A%D9%86%D9%87"
        var city = "مدينة "
        city.append("المدينة")
        print(city)
        let text = city.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let url = "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20180520T073623Z.18792333f589e521.05284719b663cf75747246af5c87011a9a6d6f02&text=\(text)&lang=ar-en&[format=plain]&[options=1]&[callback=json]"
    
    
        let urll = "https://translate.yandex.net/api/v1.5/tr.json/getLangs?key=l.1.1.20180520T073623Z.18792333f589e521.05284719b663cf75747246af5c87011a9a6d6f02&[ui=en]&[callback=json]"
    
        Alamofire.request(url, method: .get).responseJSON { (response) in
    
            if response.result.isSuccess{
                let translatedText = JSON(response.result.value!)
                print("successssssssssss\(translatedText)")
            }else{
                print(response.result.error)
            }
        }
    }
    
    
    
    
    
    //MARK:- fetch Data
    //MAR: get the language of user and the form of time
    func getStatusOfTheApp(){
        let am = UserDefaults.standard.object(forKey: "am")
        if am != nil {
            isAM = am as! Bool
        }
        let ar = UserDefaults.standard.object(forKey: "ar")
        if ar != nil {
            isNotArabic = ar as! Bool
        }
    }
    
    
    
    
    
    //MARK: fetch the countries of the worled
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
    
    
    
    
    //MARK: fetch the city name from GOOGLE MAP API
    // updateLocation consider if want to change the value of city in local
    //bring the city name from gps and display it in screen
     func getCityName() {
        //to chick if there is a saved name dont go to the api
        if UserDefaults.standard.string(forKey: "cityName") != nil && !updateLocation{
            self.cityNameLabel.text = UserDefaults.standard.string(forKey: "cityName")
        }else{
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                self.cityNameLabel.text? = "City name error"
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
    
    
    
    
    //MARK: fetch the location
    //get locaion from local but if not found got to gps
    func getLocation(){
        let localLat = UserDefaults.standard.double(forKey: "lat")
        let locallong = UserDefaults.standard.double(forKey: "long")
        if   localLat != nil &&  locallong != nil && !updateLocation {
            lat = UserDefaults.standard.double(forKey: "lat")
            long = UserDefaults.standard.double(forKey: "long")
            timezone()
        }else{
            loctionManger.delegate = self
            loctionManger.desiredAccuracy = kCLLocationAccuracyBest
            loctionManger.requestWhenInUseAuthorization()
            loctionManger.startUpdatingLocation()
        }
    }
    
    
    
    
    // get location from gps
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        // if data not = 0
        if location.horizontalAccuracy > 0 {
            loctionManger.stopUpdatingLocation()
            // get latitude and longitude data
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            // save latitude and longitude data to local
            UserDefaults.standard.set(lat, forKey: "lat")
            UserDefaults.standard.set(long, forKey: "long")
            // call TimeZone Method
            timezone()
        }
    }
    
    
    
    
    //MARK: fetch timezone
    // timezone method
    func timezone(){
        // get timezone data
        let timeZone : String?
        if  (UserDefaults.standard.string(forKey: "timeZone") != nil) && !updateLocation{
            timeZone = UserDefaults.standard.string(forKey: "timeZone")
        } else {
            var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
        // git only number of timezone using substring
         timeZone = String(localTimeZoneAbbreviation.suffix(2))
            UserDefaults.standard.set(timeZone , forKey: "timeZone")
            updateLocation = false
        }
        // call API method
        API( lat: lat, long: long, timeZone: timeZone!)
    }
    
    
    
    
    //FIXME: get times without internet
    //MARK: fetch prayers times from ISLAMHOUS API
    // Api pray Time method
    func API ( lat : Double , long : Double , timeZone : String){
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
                        let arabic = self.convertStringToArabic(item)
                        self.timesOfPrayers.append(arabic)
                    }
                    
                    self.getAMAndLanguage()
              
                    
                    self.determineTheNextPrayer()
                } else {
                    print("Error: \(String(describing: response.result.error))")
                }
        }
    }
    
    
    
    
    func getAMAndLanguage(){
        
        //check the language and fetch it
        if isNotArabic{
            convertLanguageToEnglish()
        }else{
            convertLanguageToArabic()
        }
        
        if isAM{
            getAMTime()
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
        soundNotification(hour: Int(timesOfPrayersEN[indexOfNextPrayer].split(separator: ":")[0])!, min: Int(timesOfPrayersEN[indexOfNextPrayer].split(separator: ":")[1])!)

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
    
    
    
    
    //play azan sound when the prayer time is come
    func playSound(){
        //make it work in the background
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        
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
    
    
    
    

    //updates the time on next prayer every second
    @objc func updateTimer() {
        if countDownHour == 0 && countDownMinute == 57 && countDownSeconds == 0 {
          // determine what to do in any time you want
            //print(timesOfPrayersEN[indexOfNextPrayer])
           
        }
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
        
        
        if isNotArabic{
            nextPrayerTime.text = "\(countDownHour):\(countDownMinute):\(countDownSeconds)"
        }else{
            nextPrayer.text = "\(convertStringToArabic("\(countDownHour)")):\(convertStringToArabic("\(countDownMinute)")):\(convertStringToArabic("\(countDownSeconds)"))"
        }
    }
    
    
    
    

    //when azan is soon send notification to the user
    func soundNotification(hour : Int , min : Int){
        
        let prayers = ["fajer","dohor","asr","maghreb","isha"]
        
        let content = UNMutableNotificationContent()
        content.title = "\(prayers[indexOfNextPrayer + 1]) azan will be after 5 minutes"
        content.badge = 1
        content.sound = UNNotificationSound(named: "salah.mp3")
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = min
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents , repeats: false)
        //UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "azanSoon", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
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
    //send data to next segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "CitySearch"{
//            let distnation = segue.destination as! ChooseAnotherCity
//            distnation.arabicLanguge = isNotArabic
//        }
//    }
    
    
    
    
    //translate all the ui
//    @IBAction func translate(_ sender: UIButton) {
//        if isNotArabic{
//            convertLanguageToArabic()
//            isNotArabic = !isNotArabic
//        }else {
//            convertLanguageToEnglish()
//            isNotArabic = !isNotArabic
//        }
//        UserDefaults.standard.set(isNotArabic, forKey: "ar")
//    }
    
    
    
    
    //convert the language of device to arabic
    func convertLanguageToArabic(){
        var languegeDictionary = ["Fajer":"الفجر","Dohor":"الظهر","Aser":"العصر","Maghreb":"المغرب","Isha":"العشاء","":""]

        //convert the time to the left
        setPrayerNameLabels(fajer: timesOfPrayers[0], dohor: timesOfPrayers[1], aser: timesOfPrayers[2], maghreb: timesOfPrayers[3], isha: timesOfPrayers[4])
        
        //assighn the translation and convert it to right
        setPrayerTimeLabels(fajer: languegeDictionary["Fajer"]!, dohor: languegeDictionary["Dohor"]!, aser: languegeDictionary["Aser"]!, maghreb: languegeDictionary["Maghreb"]!, isha: languegeDictionary["Isha"]!)
        nextPrayerTime.text = "الأذان"
        nextPrayer.text = "\(convertStringToArabic("\(countDownHour)")):\(convertStringToArabic("\(countDownMinute)")):\(convertStringToArabic("\(countDownSeconds)"))"
        
//        leftWatch.isHidden = false
//        rightWatch.isHidden = true
//        translatingButton.setTitle("English", for: .normal)
//        titleLabel.title = "أوقات الصلوات"
//        titleLabel.backBarButtonItem?.title = "الرئيسية"
//        nextPagePressed.title = "مدينة أخرى"
    }
    
    
    
    
    //convert the language of device to English
    func convertLanguageToEnglish(){
        //convert the time to the rihgt      hint: the time now is in prayers name label
        setPrayerTimeLabels(fajer: timesOfPrayersEN[0], dohor: timesOfPrayersEN[1], aser: timesOfPrayersEN[2], maghreb: timesOfPrayersEN[3], isha: timesOfPrayersEN[4])
        
        setPrayerNameLabels(fajer: "Fajer", dohor: "Dohor", aser: "Aser", maghreb: "Maghreb", isha: "Isha")
        
        nextPrayer.text = "Next Prayer"
        nextPrayerTime.text = "\(countDownHour):\(countDownMinute):\(countDownSeconds)"
        
//        leftWatch.isHidden = true
//        rightWatch.isHidden = false
//        translatingButton.setTitle("عربي", for: .normal)
//        titleLabel.title = "Prayer Times"
//        titleLabel.backBarButtonItem?.title = "Home"
//        nextPagePressed.title = "City"
    }
    
    
    
    
    //to refresh tho location if the user is in another city
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        SVProgressHUD.show()
        updateLocation = true
        getCityName()
    
        getLocation()
        
    }
    
    
    
    
    //chick the time to convert it to am
//    @IBAction func convertionBetweenAMAndPM(_ sender: UIButton) {
//        if isAM {
//            if !isNotArabic{
//                setPrayerNameLabels(fajer: timesOfPrayers[0], dohor: timesOfPrayers[1], aser: timesOfPrayers[2], maghreb: timesOfPrayers[3], isha: timesOfPrayers[4])
//            }else{
//                setPrayerTimeLabels(fajer: timesOfPrayersEN[0], dohor: timesOfPrayersEN[1], aser: timesOfPrayersEN[2], maghreb: timesOfPrayersEN[3], isha: timesOfPrayersEN[4])
//            }
//            isAM = !isAM
//        }else{
//            getAMTime()
//            isAM = !isAM
//        }
//        UserDefaults.standard.set(isAM, forKey: "am")
//    }
    
    
    
    
    //convert time to am
    func getAMTime(){
        var fajer = convertToAM(time: getHour(prayNumber: 0), prayNumber: 0)
        var dohor = convertToAM(time: getHour(prayNumber: 1), prayNumber: 1)
        var aser = convertToAM(time: getHour(prayNumber: 2), prayNumber: 2)
        var maghreb = convertToAM(time: getHour(prayNumber: 3), prayNumber: 3)
        var isha = convertToAM(time: getHour(prayNumber: 4), prayNumber: 4)
        if !isNotArabic{
            fajer = convertStringToArabic(fajer)
            dohor = convertStringToArabic(dohor)
            aser = convertStringToArabic(aser)
            maghreb = convertStringToArabic(maghreb)
            isha = convertStringToArabic(isha)
            setPrayerNameLabels(fajer: fajer, dohor: dohor, aser: aser, maghreb: maghreb, isha: isha)
        }else{
            setPrayerTimeLabels(fajer: fajer, dohor: dohor, aser: aser, maghreb: maghreb, isha: isha)
        }
    }
    
    
    
    
    //git the prayer time and convert it in am,pm mode
    func convertToAM(time : Int , prayNumber: Int) -> String{
        if time > 12 {
            
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
    func convertStringToArabic(_ numberToConvert: String) -> String{
        
        let numbers = ["1":"١","2":"٢","3":"٣","4":"٤","5":"٥","6":"٦","7":"٧","8":"٨","9":"٩","0":"٠",":":":","P":"م","A":"ص","M":""," ":" "]
        var convertedNumber : String = ""
        let time = Array(numberToConvert.characters)
        
        for index in 0...time.count - 1 {
            convertedNumber.append(numbers["\(time[index])"]!)
        }
        return convertedNumber
    }
}
