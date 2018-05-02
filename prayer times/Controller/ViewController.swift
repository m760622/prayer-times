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
 
    
    @IBOutlet weak var prayersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    
        
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString: "9FDEE6"),UIColor(hexString: "539AA7")])
    }

    


}

