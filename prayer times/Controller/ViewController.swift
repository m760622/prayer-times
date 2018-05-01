//
//  ViewController.swift
//  prayer times
//
//  Created by hammam abdulaziz on 15/08/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//

import UIKit
import ChameleonFramework
class ViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = prayersTableView.dequeueReusableCell(withIdentifier: "prayer", for: indexPath)
      
        cell.backgroundColor = UIColor(white: 1, alpha: 0)
        
      //  cell.backgroundColor = UIColor(gradientStyle: .leftToRight , withFrame: .init(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height), andColors: [UIColor(hexString: "9FDEE6"),UIColor(hexString: "539AA7")])
        return cell
    }
    
    @IBOutlet weak var prayersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        prayersTableView.delegate = self
        prayersTableView.dataSource = self
        prayersTableView.rowHeight = 100
        prayersTableView.backgroundColor = UIColor(white: 1, alpha: 0)
        
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString: "9FDEE6"),UIColor(hexString: "539AA7")])
    }

    


}

