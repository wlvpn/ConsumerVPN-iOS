# VPNKit for iOS

VPNKit is the API and connection SDK for the WLVPN platform.

# Table of contents
1. [Dependencies](#dependencies)
2. [Minimum Requirements](#minimum-requirements)
3. [Project Setup](#project-setup)
    1. [Add the required permissions for the app](#add-the-required-permissions-for-the-app)
4. [Initialize the app](#initialize-the-app)
    1. [VPNConfiguration](#vpnConfiguration)
    2. [VPNAPIManager](#vpnapimanager)
    3. [Adapters](#adapters)
5. [Notifications](#notifications)


# Dependencies
The application has no external dependencies. It includes a copy of CocoaLumberjack for logging purposes. You can use this copy of CocoaLumberjack in your own application.


# Minimum Requirements
##### Operating Systems
- iOS    13.0 +
- iPadOS 13.0 +
- macOS  10.15 +
- tvOS   17.0 +

##### Access
- API key and suffix, provided by your WLVPN representative.

##### Supported OS
- iOS
- iPadOS
- macOS
- tvOS


# Project Setup
1. Copy the VPNKit SDKs (`VPNKit.xcframework`, `VPNV3APIAdapter.xcframework`) from the SDK package to the `SDK` folder of the project.
    
2. Copy the VPNKitNetworkExtensionAdapters SDKs (`VPKWireGuardAdapter.xcframework`, `VPKWireGuardExtension.xcframework`, `VPKOpenVPNAdapter.xcframework`, `VPKOpenVPNNetworkExtension.xcframework`) from the SDK package to the `SDK` folder of the project.

- You can find the VPNKit changelog in its subfolder.
        
> Refer to: [Changelog](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Changelog.md)


##### Add the required permissions for the app
Add the required permissions for the app in the ***project file*** and initialize the app using the
[Primary Objects](#primary-objects).
> Refer: [VPNKit iOS Guide](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNKit%20iOS%20Guide.md) 

# Initialize the app
Initialize the app with the provided `APIKey`, `suffix` and `brandName`, `configName`
> Refer: [Initializers](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Initializers.md) 


## Primary Objects

##### VPNConfiguration
The `VPNConfiguration` represents the current state of the VPN framework. It contains objects like user credentials, their account information, current selected city/country/server, and specific configuration options. You can monitor for changes in this class using either KVO or NotificationCenter. Each property will fire off a notification both before and after it changes internally. The `VPNConfiguration` is a singleton and can be accessed in the "vpnConfiguration" property of VPNAPIManager. You should not hold a separate reference to the VPNConfiguration. You should access it from the VPNAPIManager.

> Refer: [VPNConfiguration](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNConfiguration.md)

##### VPNAPIManager
The `VPNAPIManager` is the primary object you will use to interact with `VPNKit`. It will perform all its actions using the attached VPNConfiguration. The `VPNAPIAdapter` manages its own Core Data store; it should not conflict with any store you have in your application. 
> Refer: [APIManager](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/APIManager.md)

##### Adapters
There are two types of adapters in VPNKit: `Connection Adapters` and `API Adapters`.
An API Adapter is used to connect to an API. The only adapter you will need to worry about is the V3APIAdapter. This connects to the current version of the VPN backend and will handle retrieval of API resources. 
A Connection Adapter is used to connect to specific VPN protocols. The SDK includes adapters for Apple VPN protocols through `NEVPNManagerAdapter`, WireGuard through `VPKWireGuardAdapter`, and OpenVPN through `VPKOpenVPNAdapter`.
The Network Extension modules `VPKWireGuardExtension` and `VPKOpenVPNNetworkExtension` support packet tunnel implementations for their respective protocols. The simulator for iOS does not support real VPN connections. On the simulator, connections are simulated with the `VPNConnectionTestAdapter`, which can also be used to support UI tests.
  
> Refer: [Adapters](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Adapters.md)

# Notifications

You call a framework function and it will perform asynchronous actions. At various points during the action, a notification will be sent out that allows you to respond to the event. 
> Refer: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)

> To get the necessary assets/SDK, please contact support@wlvpn.com

