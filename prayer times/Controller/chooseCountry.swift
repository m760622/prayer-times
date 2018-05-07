//
//  ViewController.swift
//  prayer times
//
//  Created by hammam abdulaziz on 15/08/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//

import UIKit
import ChameleonFramework
class chooseCountry: UIViewController{
    

    @IBOutlet weak var CityTextField: UITextField!
    
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gradient color of the background
       // view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString: "539AA7"),UIColor(hexString: "9FDEE6")])
    
    }
    
    
    @IBAction func SearchButton(_ sender: UIButton) {
        if CityTextField.text != nil{
         
            performSegue(withIdentifier: "ShowCityPrayer", sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
            let sendCityName = segue.destination as! ShowCityViewController
        if CityTextField.text != "" {
           
            sendCityName.CityName = CityTextField.text!
            
            
        }
        
        
    }
    
}

