//
//  EstablishmentTableViewCell.swift
//  HappyHour
//
//  Created by Eric Lee on 2016-07-05.
//  Copyright © 2016 Erics App House. All rights reserved.
//

import UIKit

class EstablishmentTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var openCircleImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
