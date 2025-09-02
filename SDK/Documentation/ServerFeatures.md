
# Server Capabilities

This document outlines how to use the `availableFeatures` property provided by the SDK to retrieve server features on the app side.

## Overview

The SDK property on `Server` object `availableFeatures` returns a list of server features as `NSNumber` values. These values correspond to predefined feature types.

## Server Types Enum

The SDK defines the following enum to represent feature types:

```objc
typedef NS_ENUM(NSUInteger, VPNServerFeature) {
    VPNServerFeaturePhysicalLocation,       // 0
    VPNServerFeatureVirtualLocation,        // 1
    VPNServerFeatureStandardProtocolSet,    // 2
    VPNServerFeatureRamOnly                 // 3
};
```

## Usage

On the app side, convert the returned array into Swift enum values of type `VPNServerFeature`.

### Example

```swift
let serverFeatures: Array<VPNServerFeature> = server.availableFeatures.compactMap {
    VPNServerFeature(rawValue: UInt(truncating: $0))
}

for featureEnum in serverFeatures {

    switch featureEnum {
        case .physicalLocation:
            print("→ Physical Location")
        case .virtualLocation:
            print("→ Virtual Location")
        case .standardProtocolSet:
            print("→ Standard Protocol Set")
        case .ramOnly:
            print("→ RAM Only")
        default:
            print("→ Unknown Feature: \(featureEnum)")
    }
}
```

### Filters a list of `Server` objects based on a given set of `VPNServerFeature` values.

```swift
func filterServer(withServerFeatures features: Set<VPNServerFeature>, forTheCity city: City) -> Array<Server> {
    
    // If we don't have a valid list of servers, return
    guard let sortedServers = city.sortedServers() as? [Server] else {
        return []
    }
    
    if features.isEmpty {
        return sortedServers
    }

    let requiredFeatureSet = Set(features.map { NSNumber(value: $0.rawValue) })

    return sortedServers.filter { server in
        !server.availableFeatures.isDisjoint(with: requiredFeatureSet)
    }
}

// Define the features you want to filter by
let requiredFeatures: Set<VPNServerFeature> = [.ramOnly, .virtualLocation]

// Call the filtering method
let matchingServers = filterServer(withServerFeatures: requiredFeatures, forTheCity: cityModel.city)
```

### Connects to the most optimal server in a given city that supports at least one of the required `VPNServerFeature`.

```swift
func connectToOptimalServer(in city: City, requiring features: Set<VPNServerFeature>) {
    self.vpnConfiguration?.country = city.country
    self.vpnConfiguration?.city = city
    self.vpnConfiguration?.server = nil
    self.vpnConfiguration?.serverFeatures = Set(features.map { NSNumber(value: $0.rawValue) })
    self.apiManager.connect()
}
// Define the features you want to filter by
let requiredFeatures: Set<VPNServerFeature> = [.ramOnly, .virtualLocation]

// Call the connection method
connectToOptimalServer(in: city, requiring: requiredFeatures)

```

### Notes

- Only enabled features are included in the result of `availableFeatures`.
- The `standardProtocolSet` (`ServerFeatureStandardProtocolSet`) is **enabled by default** for all servers.

