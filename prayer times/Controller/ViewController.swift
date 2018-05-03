//
//  ViewController.swift
//  prayer times
//
//  Created by hammam abdulaziz on 15/08/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//

import UIKit
import ChameleonFramework
class ViewController: UIViewController{
 
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    
        
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString: "539AA7"),UIColor(hexString: "9FDEE6")])
    //    prayersLabel.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
        
    //    dohorLabel.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
        nextPrayer.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
        
        nextPrayerTime.backgroundColor = UIColor(hexString: "061F2A").withAlphaComponent(0.2)
        
    }

    


}

