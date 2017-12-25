//
//  ProductDetailsTableViewCell.swift
//  DemoJson
//
//  Created by ShivangiBhatt on 22/12/17.
//  Copyright © 2017 Mac-00016. All rights reserved.
//

import UIKit

class ProductDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var lblBrand: UILabel!
    @IBOutlet weak var lblTax: UILabel!
    @IBOutlet weak var lblCount: UILabel!
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
