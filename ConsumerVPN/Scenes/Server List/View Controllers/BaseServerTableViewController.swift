//
//  BaseServerTableViewController.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/26/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit
import VPNKit

class BaseServerTableViewController: UITableViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .serverListStatusBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: CityServerTableViewCell.reuseIdentifier, bundle: nil)
        let headerNib = UINib(nibName: CountryHeaderView.reuseIdentifier, bundle: nil)
        
        // register if our subclass is to use `dequeueReusableCellWithIdentifier(_:forIndexPath:)
        tableView.register(cellNib, forCellReuseIdentifier: CityServerTableViewCell.reuseIdentifier)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: CountryHeaderView.reuseIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .cellSeparatorTint
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Set up Colors
        tableView.backgroundColor = UIColor.serverListBackground.darker
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Configuration
    
    func configure(_ cell: CityServerTableViewCell, forCityModel cityModel: CityModel) {
        
        // configure cell...
        cell.cityLabel.text = "\(cityModel.name), \(cityModel.countryName)"
        cell.flagImageView.isHidden = false
        cell.flagImageView.image = cityModel.flagImage
        cell.cityLabel.textColor = UIColor.white
        print("\(cityModel.name), \(cityModel.countryName) - \(cityModel.flagImage.debugDescription)")
//        cell.shapeFlagToCircle()
    }
    
    func configureDedicatedServer(_ cell: CityServerTableViewCell, forCityModel cityModel: CityModel) {
        
        // configure cell...
        guard let server = cityModel.filteredServers.first else { return}
        let ipAddress = server.dedicatedIPAddress ?? "N/A"
        let isInMaintainance = (server.maintenance ?? 0) == 1
        
        cell.cityLabel.text = "\(cityModel.name), \(cityModel.countryID) - \(ipAddress)"
        cell.flagImageView.isHidden = false
        if isInMaintainance {
            cell.flagImageView.image = UIImage(named: "server_off")?.withRenderingMode(.alwaysTemplate)
            cell.flagImageView.tintColor = UIColor(named: "server_off_color")
            cell.cityLabel.textColor = UIColor(named: "server_off_color")
        } else {
            cell.flagImageView.image = cityModel.flagImage
            cell.flagImageView.tintColor = .appWideTint
            cell.cityLabel.textColor = UIColor.white
        }
        
        print("\(cityModel.name), \(cityModel.countryName) - \(cityModel.flagImage.debugDescription)")
//        cell.shapeFlagToCircle()
    }
    
    
    func configureCityOnly(_ cell: CityServerTableViewCell, forCityModel cityModel: CityModel) {
        cell.cityLabel.text = "\(cityModel.name)"
        cell.flagImageView.isHidden = true
        cell.cityLabel.textColor = UIColor.white
    }
    
    func configure(_ header: CountryHeaderView, forCountrySection countrySection: CountrySection) {
        header.countryLabel.text = "\(countrySection.country)"
        header.flagImageView.image = countrySection.cities.first?.flagImage
        let cityCountText = countrySection.cities.count > 1 ? "\(countrySection.cities.count) cities" : "1 city"
        header.cityButton.isHidden = false
        header.cityButton.setTitle(cityCountText, for: .normal)
        header.cityButton.tintColor = .appWideTint
        header.cityButton.backgroundColor = .appWideTint
    }
    
    func configureBestAvailable(_ cell: CityServerTableViewCell) {
        
        // configure cell...
        cell.cityLabel.text = "\(LocalizedString.fastestAvailable)"
        cell.flagImageView.isHidden = false
        cell.flagImageView.image = UIImage(named: "fastest-available")?.withRenderingMode(.alwaysTemplate)
        cell.flagImageView.tintColor = .appWideTint
        cell.cityLabel.textColor = UIColor.white
    }
    
    func configureBestAvailable(_ header: CountryHeaderView) {
        header.countryLabel.text = "\(LocalizedString.fastestAvailable)"
        header.flagImageView.image = UIImage(named: "fastest-available")?.withRenderingMode(.alwaysTemplate)
        header.flagImageView.tintColor = .appWideTint
        header.flagImageView.contentMode = .scaleAspectFit
        header.cityButton.isHidden = true
    }
    
}
