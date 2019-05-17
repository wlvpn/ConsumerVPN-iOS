//
//  ResultsServerViewController.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/26/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

class ResultsServerViewController: BaseServerTableViewController {

    // MARK: Properties
    var sortedCityModels: [CityModel] = [] {
        didSet {
            // display the Empty state only when the data model has changed with 0 models
            if sortedCityModels.count == 0 { // display empty state
                // display empty state
                emptyStateView.isHidden = false
            } else if sortedCityModels.count != 0 { // remove empty state
                emptyStateView.isHidden = true
            }
        }
    }
    
    var searchText = "" {
        didSet {
            // update the emptyStateView's information
            emptyStateView?.searchText = searchText
        }
    }
    
    private var emptyStateView: EmptyStateView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let emptyStateView = Bundle.main.loadNibNamed(EmptyStateView.nibName, owner: self, options: nil)?.first as? EmptyStateView {
            emptyStateView.frame = tableView.frame
            tableView.backgroundView = emptyStateView
            emptyStateView.isHidden = true
            self.emptyStateView = emptyStateView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // provide the empty state view with the current search text
        emptyStateView.searchText = searchText
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCityModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityServerTableViewCell.reuseIdentifier, for: indexPath) as? CityServerTableViewCell else {
            print("Cell does not match expected type")
            abort()
        }
        
        let cityModel = sortedCityModels[indexPath.row]
        configure(cell, forCityModel: cityModel)
        
        return cell
    }

}
