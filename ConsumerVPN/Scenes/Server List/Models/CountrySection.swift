//
//  CountrySection.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/26/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation

struct CountrySection : Comparable {
    var country: String
    var cities: [CityModel]
    
    static func < (lhs: CountrySection, rhs: CountrySection) -> Bool {
        return lhs.country < rhs.country
    }
    
    static func == (lhs: CountrySection, rhs: CountrySection) -> Bool {
        return lhs.country == rhs.country
    }
}

