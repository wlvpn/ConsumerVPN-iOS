//
//  EmptyStateView.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/27/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {
    @IBOutlet weak var noResultsDescriptionLabel: UILabel!
    @IBOutlet weak var noResultsTitleLabel: UILabel!
    @IBOutlet weak var reloadServersButton: CustomButton!
    
    static let nibName = "\(EmptyStateView.self)"
    
    var searchText = "" {
        didSet {
            updateUI()
        }
    }
    
    var delegate: EmptyStateViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.serverListBackground.darker
        noResultsDescriptionLabel.textColor = .primaryFont
        noResultsTitleLabel.textColor = .primaryFont
        
        // configure the button. It should only be visible under extreme conditions (No Servers at all without filtering)
        reloadServersButton.isHidden = true
        reloadServersButton.setTitleColor(.primaryFont, for: .normal)
        reloadServersButton.borderColor = UIColor.white.cgColor
        
        // TODO: Update Search Image Color
    }
    
    @IBAction func reloadServers(_ sender: UIButton) {
        delegate?.reloadServersTapped(in: self)
    }
    
    
    /// This is called each time one of the properties changes. Use this time to update the label with whatever information we have and display the button if needed
    private func updateUI() {
        // re-enable the button on a change if it were disabled before
        reloadServersButton.isEnabled = true
        // if there is searchText 
            // and pingRange is a value other than .any, display no match with ping range text OR
            // and pingRange is exactly .any, display no match with just search text
        // if there is no searchText
            // and pingRange is a value other than .any, display no servers within ping range, check filter options text OR
            // and pingRange is exactly .any, display something went wrong with a retry button
        
        if searchText.hasText { // ResultsServerViewController
            // hide the button if it was visible
            reloadServersButton.isHidden = true
            // assign localized text to the labels
            noResultsTitleLabel.text = LocalizedString.noResultsFound
            
            noResultsDescriptionLabel.text = String.localizedStringWithFormat(LocalizedString.noMatchFormat, searchText)
            
        } else if searchText.isEmpty { // ServerListViewController
            
            // display the button only under this condition
            reloadServersButton.isHidden = false
            // assign localized text to the labels
            noResultsTitleLabel.text = LocalizedString.somethingWentWrongTitle
            noResultsDescriptionLabel.text = LocalizedString.noResultsReloadServers
            
        }
    }
}
