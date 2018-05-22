//
//  File.swift
//  prayer times
//
//  Created by hammam abdulaziz on 06/09/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//

import UIKit
import ChameleonFramework

class Setting: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    let array = ["Language","Form Of Time"]
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
  

        cell.labelOfCell.text = array[indexPath.row]
        if indexPath.row == 0 {
        cell.segmentLabel.setTitle("عربي", forSegmentAt: 0)
        cell.segmentLabel.setTitle("English", forSegmentAt: 1)
        }else{
            cell.segmentLabel.setTitle("AM", forSegmentAt: 0)
            cell.segmentLabel.setTitle("24h", forSegmentAt: 1)
        }
        return cell
    }
    
    
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), andColors: [UIColor(hexString:  "9FDEE6"),UIColor(hexString: "539AA7")])
    }
    
    
}
