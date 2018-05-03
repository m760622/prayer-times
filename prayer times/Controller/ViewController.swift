//
//  ViewController.swift
//  prayer times
//
//  Created by hammam abdulaziz on 15/08/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//

import UIKit

import ChameleonFramework
import Alamofire
import SwiftyJSON
class ViewController: UIViewController{
 
    
    @IBOutlet weak var prayersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
       API()
    
        
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString: "9FDEE6"),UIColor(hexString: "539AA7")])
    }

    func API (){
        
        let urls = "http://api.islamhouse.com/v1/XXXXXXXXX/services/praytime/get-times/2014/08/13/Makkah/30.0599153/31.2620199/+3/json"
        Alamofire.request(urls, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                   
                    let cat : JSON = JSON(response.result.value!)
                   
                    
                    print(cat)
                    
                } else {
                    print("Error: \(String(describing: response.result.error))")
                    
                }
        }
        
        
    }


}

