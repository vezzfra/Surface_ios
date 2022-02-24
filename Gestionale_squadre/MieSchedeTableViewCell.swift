//
//  MieSchedeTableViewCell.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 28/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit

class MieSchedeTableViewCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backView.layer.cornerRadius = 5
        self.backView.layer.borderColor = UIColor(displayP3Red: 120/255, green: 56/255, blue: 153/255, alpha: 1.0).cgColor
        self.backView.layer.borderWidth = 3
        self.backView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
