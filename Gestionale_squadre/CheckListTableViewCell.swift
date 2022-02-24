//
//  CheckListTableViewCell.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 22/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit

class CheckListTableViewCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.label.textColor = UIColor.white
        self.backView.backgroundColor = UIColor.clear
    }
}
