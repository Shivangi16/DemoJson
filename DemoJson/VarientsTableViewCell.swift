//
//  VarientsTableViewCell.swift
//  DemoJson
//
//  Created by ShivangiBhatt on 25/12/17.
//  Copyright © 2017 Mac-00016. All rights reserved.
//

import UIKit

class VarientsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblColorName: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
