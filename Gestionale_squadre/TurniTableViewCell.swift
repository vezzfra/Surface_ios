//
//  TurniTableViewCell.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 02/12/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit

class TurniTableViewCell: UITableViewCell {
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var tipoLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tickImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
