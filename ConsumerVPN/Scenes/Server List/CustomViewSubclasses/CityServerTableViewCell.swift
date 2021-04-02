//
//  CityServerTableViewCell.swift
//  ConsumerVPN
//
//  Created by WLVPN on 11/13/17.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

class CityServerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    static let reuseIdentifier = "\(CityServerTableViewCell.self)"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Setup Colors
        cityLabel.textColor = .primaryFont
        contentView.backgroundColor = .clear
        
        flagImageView.layer.masksToBounds = true
        
        setupAccesibilityAndLocalization()
    }
    
    func shapeFlagToSquare() {
        flagImageView.layer.cornerRadius = 0.0
    }
    
    func shapeFlagToCircle() {
        flagImageView.layer.cornerRadius = flagImageView.frame.size.width / 2.0
    }
    
    func setupAccesibilityAndLocalization() {
        cityLabel.accessibilityIdentifier = AccessibilityIdentifier.popHeaderLocationLabel.rawValue
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
