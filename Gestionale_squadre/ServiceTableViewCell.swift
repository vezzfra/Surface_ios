//
//  ServiceTableViewCell.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 12/11/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tipologia: UILabel!
    @IBOutlet weak var cod_invio: UIView!
    @IBOutlet weak var cod_trasporto: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var iconImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
