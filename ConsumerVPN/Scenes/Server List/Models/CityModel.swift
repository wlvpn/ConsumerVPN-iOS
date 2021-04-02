//
//  CityModel.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/15/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit
import VPNKit


/// Protocol used to define properties that will be needed for sorting and filtering with an Array extension
protocol CityModelSorting {
    var name: String {get}
    var countryName: String {get}
    var filteredServers: [Server] {get set}
    var city: City {get}
    var countryID: String {get}
    
    func filter(withName searchText: String)
}

/// Describes each City object in the context of our ServerListViewController
final class CityModel: CityModelSorting {
    /// Determines whether the cityModel object is expanded in the server list table view controller to display all children servers
    var isExpanded: Bool
    /// Localized name of the city. This `should` be done on the API side.
    let name: String
    /// Localized name of the country this city belongs to. This `should` be done on the API side.
    let countryName: String
    /// Localized combination of the city and country. This `should` be done on the API side.
    let cityDisplayName: String
    /// Localized CountryID. This `should` be done on the API side.
    let countryID: String
    /// Reference to the Core Data city object. This receives updates when pinging
    let city: City
    /// Image representing the country this city belongs to
    let flagImage: UIImage?
    /// List of servers that contain the search text the user provided
    var filteredServers: [Server]
    
    init?(city: City) {
        
        // check if we have a name and our country has a name.
        // If not, return nil as we need that information
        guard let name = city.name,
            let countryName = city.country?.name,
            let flagImage = city.country?.flagImage,
            let countryID = city.country?.countryID,
            let servers = city.sortedServers() as? [Server]
            else {
                return nil
        }
        
        
        self.name = name
        self.countryName = countryName
        self.countryID = countryID
        cityDisplayName = "\(name), \(countryID)"
        self.flagImage = flagImage
        self.city = city
        self.filteredServers = servers
        isExpanded = false
    }
}

// MARK: - Filtering CityModel
extension CityModel {
    
    /// Filter out any servers that aren't constrained within the pingRange provided
    ///
    /// - parameter pingRange: The range of ping values to constrain each server within.
    func filter(withName searchText: String = "") {
        
        // If we don't have a valid list of servers, return
        guard let sortedServers = city.sortedServers() as? [Server] else {
            return
        }
        
        filteredServers = sortedServers
        
        // Filter our servers based on the name only if the name is not contained within the city's name,
        // the country's name, or the countryID
        if searchText.hasText &&
            name.range(of: searchText, options: .caseInsensitive) == nil &&
            countryName.range(of: searchText, options: .caseInsensitive) == nil &&
            countryID.range(of: searchText, options: .caseInsensitive) == nil {
            
            // filter out all the servers that don't contain the searchText
            filteredServers = filteredServers.filter({ (server) -> Bool in
                server.formattedServerName()?.range(of: searchText, options: .caseInsensitive) != nil
            })
            
        }
    }
}


// MARK: - Equatable
extension CityModel: Equatable {
    static func ==(left: CityModel, right: CityModel) -> Bool {
        return left.city === right.city
    }
    
    static func !=(left: CityModel, right: CityModel) -> Bool {
        return left.city !== right.city
    }
}

// MARK: - CityModelSorting Array
extension Array where Element: CityModelSorting {
    
    
    /// Consolidates the filtering functionality for both the mutating and non-mutating `internal` versions into this private method.
    ///     Filters the element's servers and returns the result.
    ///     The result's `filteredServers` property contains any servers that passed the test.
    ///     If any resulting element has 0 `filteredServers` it is removed from the returned collection
    ///
    /// - returns: A new array of elements with 1 or more `filteredServers`
    private func filteredHelper(withName searchText: String) -> [Element] {
        
        var filteredElements = self
        
        // Filter each of the cities
        for cityModel in filteredElements {
            cityModel.filter(withName: searchText)
        }
        
        // If any of the resulting elements have 0 filteredServers, remove them from the list entirely
        filteredElements = filteredElements.filter { $0.filteredServers.count > 0 }
        
        return filteredElements
    }
    
    /// Filters the element's servers list and returns the result.
    ///     The result's `filteredServers` property contains any servers that passed the test. 
    ///     If any resulting element has 0 `filteredServers`, it is removed from the returned collection.
    ///
    /// - returns: A new array of elements with 1 or more `filteredServers`.
    func filtered(withName searchText: String = "") -> [Element] {
        
        // Return the filtered version of `self` without modifying `self`
        return self.filteredHelper(withName: searchText)
    }
    
    /// Filters the element's servers list.
    ///     The `filteredServers` property of each element contains any servers that passes the test.
    ///     If any resulting element has 0 `filteredServers`, it is removed from the receiver.
    ///
    mutating func filter(withName searchText: String = "") {
        
        // Overwrite `self` with the filtered version of `self`
        self = self.filteredHelper(withName: searchText)
    }
    
    
    /// Consolidates the sorting functionality for both the mutating and non-mutating `internal` versions into this private method.
    ///     Sorts the elements in the receiver by one or more `SortOption` and returns the result.
    ///
    /// - parameter sortOptions: The sort options desired to apply to the collection.
    ///
    /// - returns: A newly sorted array using the passed in sortOptions to determine sorting behavior.
    private func sortedHelper(by sortOption: SortOption) -> [Element] {
        
        var sortedElements = self
        
        switch sortOption {
        case .city:
            sortedElements.sort { (left, right) in
                left.name.localizedStandardCompare(right.name) == .orderedAscending
            }
        case .country:
            sortedElements.sort { (left, right) in
                if left.countryName.localizedStandardCompare(right.countryName) == .orderedSame {
                    return left.name.localizedStandardCompare(right.name) == .orderedAscending
                }
                return left.countryName.localizedStandardCompare(right.countryName) == .orderedAscending
            }
        case .serverCount:
            sortedElements.sort { $0.filteredServers.count > $1.filteredServers.count }
        }
        
        return sortedElements
    }
    
    
    /// Sorts the elements in the receiver by one or more `SortOption` and returns the result.
    ///
    /// - parameter sortOptions: A Set containing each of the sort options desired to apply to the collection.
    ///
    /// - returns: A newly sorted array containing the passed in sortOptions to determine sorting behavior.
    func sorted(by sortOption: SortOption) -> [Element] {
        return self.sortedHelper(by: sortOption)
    }
    
    /// Sorts the elements in the receiver by one or more `SortOption` and modifys the receiver.
    ///
    /// - parameter sortOptions: A Set containing each of the sort options desired to apply to the collection.
    mutating func sort(by sortOption: SortOption) {
        self = self.sortedHelper(by: sortOption)
    }
}
