//
//  FilterTableHeaderView.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/14/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

class FilterTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var backgroundViewOutlet: UIView!
    
    static let reuseIdentifier = "\(FilterTableHeaderView.self)"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup Colors
        headerLabel.textColor = .optionsFont
        backgroundViewOutlet.backgroundColor = .clear
    }
}
