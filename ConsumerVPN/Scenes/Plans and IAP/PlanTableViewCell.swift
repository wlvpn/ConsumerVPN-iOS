//
//  PlanTableViewCell.swift
//  ConsumerVPN
//
//  Created by WLVPN on 27/03/20.
//  Copyright © 2020 NetProtect. All rights reserved.
//

import UIKit

class PlanTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var planTitle: UILabel!
    @IBOutlet weak var planSubtitle: UILabel!
    @IBOutlet weak var price: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        
        self.selectionStyle = .none
        
        bgView.backgroundColor = .clear
        bgView.layer.cornerRadius = 10
		bgView.layer.borderColor = UIColor.iapTertiaryFontColor.cgColor
        bgView.layer.borderWidth = 2
        
        planTitle.textColor = .iapPrimaryFontColor
        planSubtitle.textColor = .iapTertiaryFontColor
        price.textColor = .iapPrimaryFontColor
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bgView.backgroundColor = selected ? .appWideTint : .clear
		bgView.layer.borderColor = selected ? UIColor.appWideTint.cgColor : UIColor.iapTertiaryFontColor.cgColor
    }

}
