//
//  ServizioCSTableViewCell.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 24/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit

class ServizioCSTableViewCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var codiceInvioLabel: UILabel!
    @IBOutlet weak var codiceTrasportoLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backView.layer.cornerRadius = 5
        self.backView.layer.borderColor = UIColor.lightGray.cgColor
        self.backView.layer.borderWidth = 3
        self.backView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
