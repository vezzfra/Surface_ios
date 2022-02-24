//
//  StatisticaTableViewCell.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 28/11/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit

class StatisticaTableViewCell: UITableViewCell {
    @IBOutlet weak var tipoServizio: UILabel!
    @IBOutlet weak var numeroServizi: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
