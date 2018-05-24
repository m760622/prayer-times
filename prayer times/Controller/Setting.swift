//
//  File.swift
//  prayer times
//
//  Created by hammam abdulaziz on 06/09/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol settingDelegate{
    func settingOfLanguage(language: Bool)
    func settingOfam(am: Bool)
    
}
//FIXME: segmant to save its value
class Setting: UIViewController {
    //MARK: VARIBELS
    var delegate :settingDelegate?
    @IBOutlet var amSegment: UISegmentedControl!
    @IBOutlet var languageSegment: UISegmentedControl!
    
    @IBOutlet var languageLabel: UILabel!
    @IBOutlet var AMLabel: UILabel!
    

    @IBAction func choosenSegment(_ sender: UISegmentedControl) {
        if sender.tag == 0 {
            if languageSegment.selectedSegmentIndex == 0{
                delegate?.settingOfLanguage(language: false)
                UserDefaults.standard.set(false, forKey: "ar")

                
            }else{
                delegate?.settingOfLanguage(language: true)
                UserDefaults.standard.set(true, forKey: "ar")


            }
        }else{
            if amSegment.selectedSegmentIndex == 0{
                delegate?.settingOfam(am: true)

                UserDefaults.standard.set(true, forKey: "am")

            }else{
                delegate?.settingOfam(am: false)

                UserDefaults.standard.set(false, forKey: "am")

            }
        }
        
    }
    
    
    
    
    override func viewDidLoad() {
        languageSegment.setTitle("English", forSegmentAt: 1)
        languageSegment.setTitle("عربي", forSegmentAt: 0)
        amSegment.setTitle("am", forSegmentAt: 0)
        amSegment.setTitle("24h", forSegmentAt: 1)


        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString:  "9FDEE6"),UIColor(hexString: "539AA7")])
    }
    
    
    
    
}
