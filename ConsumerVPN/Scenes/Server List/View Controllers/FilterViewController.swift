//
//  FilterViewController.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/14/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//


import UIKit

final class FilterViewController: UIViewController {
    
    /* Outlets */
    @IBOutlet weak var filterTableView: UITableView!
    
    /* Constants */
    let fCellReuseID = "filterCellReuseIdentifier"
    
    /* Properties */
    // Collection holding all options
    // Passed forward from ServerListViewController
    var fSortByOptions: [SortOption]!

    var selectedSortOption: SortOption!
    
    // Delegate - ServerListViewController
    var delegate: FilterViewControllerDelegate!


    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Colors
        filterTableView.backgroundColor = .filterBackground
        filterTableView.separatorStyle = .singleLine
        filterTableView.separatorColor = .cellSeparatorTint
    }
    
    //MARK: - Actions
    @IBAction func resetFilters(_ sender: UIBarButtonItem) {
        
        selectedSortOption = .city
        
        // inform the delegate of the deault selections
        delegate.filterViewController(self, selected: .city)
        
        /// Reload tableview to update visuals
        filterTableView.reloadData()
    }
}

//MARK: - Tableview Delegate Methods
extension FilterViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Remove any previous checkmarks
        let oldCellIndex = IndexPath(row: selectedSortOption.rawValue, section: indexPath.section)
        let oldCell = tableView.cellForRow(at: oldCellIndex)
        oldCell?.accessoryType = .none
        
        // Save selection and inform our delegate of the changes
        if indexPath.section == 0 {
            selectedSortOption = fSortByOptions[indexPath.row]
            delegate.filterViewController(self, selected: selectedSortOption)
        }
        
        // Set checkmark to current selected cell
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
}

//MARK: - Tableview Datasource Methods
extension FilterViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fSortByOptions.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return LocalizedString.sortByHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: fCellReuseID, for: indexPath)
        
        cell.textLabel?.text = String(describing: fSortByOptions[indexPath.row])
        cell.textLabel?.textColor = .primaryFont
        
        // reset cell's accessory type
        cell.accessoryType = .none
        
        // set accessory type if this cell is the selected sort option
        if selectedSortOption == SortOption(rawValue: indexPath.row) {
            cell.accessoryType = .checkmark
        }
        
        // Setup Colors
        cell.backgroundColor = .filterCell
        cell.tintColor = .checkmark
        
        return cell
    }
}
