//
//  Cell.swift
//  prayer times
//
//  Created by hammam abdulaziz on 07/09/1439 AH.
//  Copyright © 1439 hammam abdulaziz. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {

    
    @IBOutlet var segmentLabel: UISegmentedControl!
    @IBOutlet var labelOfCell: UILabel!
    @IBAction func choosenSegment(_ sender: UISegmentedControl) {
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
