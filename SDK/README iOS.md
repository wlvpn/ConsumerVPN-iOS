# VPNKit for iOS

VPNKit is the API and connection SDK for the WLVPN platform.

## Dependencies

The application has no external dependencies. It includes a copy of CocoaLumberjack for logging purposes. You can use
this copy of CocoaLumberjack in your own application.

## Minimum Requirements
 - iOS 14.0, macOS Mojave 10.14
 - API key access token
 Supports iPhone, iPad, Mac

See: [Get Started](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Get%20Started.md)

## Project Setup

The VPNKit framework needs to be linked into your project. You will also need to link at least one API adapter. The API adapter is linked as a static library while the framework is included and embedded in the project. 

The framework is a "fat" binary, which should work in both the simulator and on a device. 

See:[VPNKit iOS Guide](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/VPNKit%20iOS%20Guide.md)

## Notifications

The framework uses`NSNotification` and `NSNotificationCenter` to handle asynchronous actions. You call a framework 
function and it will perform asynchronous actions. At various points during the action, a notification will be sent 
out that allows your client to respond to the event. 

### Example events:

```
VPNConnectionWillBeginNotification
VPNConnectionSucceededNotification
VPNServerUpdateWillBeginNotification
VPNServerUpdateSucceededNotification
```

See: [Notifications Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Notifications.md)


## Primary Objects

### VPNConfiguration

The VPNConfiguration represents the current state of the VPN framework. It contains objects like user credentials, their account information, current selected city/country/server, and specific configuration
options. You can monitor for changes in this class using either KVO or NotificationCenter. Each property
will fire off a notification both before and after it changes internally. The VPNConfiguration is a singleton and can be accessed in the "vpnConfiguration" property of VPNAPIManager. You should not hold a separate reference to the VPNConfiguration. You should access it from the VPNAPIManager.

See: [VPNConfiguration Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/VPNConfiguration.md)


### VPNAPIManager

The VPNAPIManager is the primary object you will use to interact with VPNKit. It will perform all its actions using the attached VPNConfiguration. The VPNAPIAdapter manages its own Core Data store; it should not conflict with any store you have in your application. 

See: [VPNAPIManager Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/APIManager.md)


#### Adapters

There are two types of adapters in VPNKit: Connection adapters and API adapters. 

An API adapter is used to connect to an API. The only adapter you will need to worry about is the V3APIAdapter. This connects to the current version of the VPN backend and will handle retrieval of API resources.

A connection adapter is used to connect to specific VPN protocols. The main adapter usable on macOS and iOS is the NEVPNManagerAdapter. This adapter interfaces with the Apple provided NEVPNManager interface to provide system supported VPN connections. It supports IKEv2 and IPSec based connections. Due to limitations with iOS, this is the only adapter we support on iOS. The simulator for iOS does not support VPN connections. On the simulator, we simulate connections with the VPNConnectionTestAdapter. This can also be used to support UI tests in the iOS simulator. 

See: [Adapters Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Adapters.md)


#### VPNAPIInitializer

The framework is best initialized using Objective-C. 

See: [VPNAPIInitializer Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Initializers.md)


To get the necessary assets/SDK, please contact support@wlvpn.com

 
