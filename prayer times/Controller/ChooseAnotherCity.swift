//
//  ViewController.swift
//  prayer times
//
//  Created by hammam abdulaziz on 15/08/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//

import UIKit
import ChameleonFramework
class ChooseAnotherCity: UIViewController{
    
    var arabicLanguge : Bool = false
    @IBOutlet var titleLabel: UINavigationItem!
    @IBOutlet var searchPressed: UIButton!
    @IBOutlet weak var CityTextField: UITextField! // text field
    
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gradient color of the background

        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString:  "9FDEE6"),UIColor(hexString: "539AA7")])
    
        getSettingOfTheApp()
        
        if !arabicLanguge {
            CityTextField.placeholder = "أدخل إسم المدينة"
            titleLabel.title = "ابحث في مدن اخرى"
            titleLabel.backBarButtonItem?.title = "البحث"
            searchPressed.setTitle("ابحث", for: .normal)
        }else{
            CityTextField.placeholder = "Enter the name of city"
            titleLabel.title = "Check Any City"
            titleLabel.backBarButtonItem?.title = "check Any City"
            searchPressed.setTitle("Search", for: .normal)
        }
        
    }
    
    //MARK:- fetch Data
    //MAR: get the language of user and the form of time
    func getSettingOfTheApp(){
        let ar = UserDefaults.standard.object(forKey: "ar")
        if ar != nil {
            arabicLanguge = ar as! Bool
        }
    }
    
    // Search button
    @IBAction func SearchButton(_ sender: UIButton) {
        // make sure the text field not empty
        if CityTextField.text != "" {
            performSegue(withIdentifier: "ShowCityPrayer", sender: self)
        }
    }
    // send keyWord city to another view controller 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            let sendCityName = segue.destination as! DisplayAnotherCity
        if CityTextField.text != "" {
           
            sendCityName.CityName = CityTextField.text!
            sendCityName.arabicLanguage = arabicLanguge
            
            
        }
        
        
    }
    
}

