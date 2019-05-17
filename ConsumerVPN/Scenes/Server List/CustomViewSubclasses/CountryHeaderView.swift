//
//  CountryHeaderView.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/20/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

class CountryHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityButton: UIButton!
    
    static let reuseIdentifier = "\(CountryHeaderView.self)"
    var sectionIndex: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        countryLabel.textColor = .primaryFont
        containerView.backgroundColor = .serverListSectionBg
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 5
        
        flagImageView.layer.masksToBounds = true
    }
}
