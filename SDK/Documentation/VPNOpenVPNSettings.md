# VPNOpenVPNSettings

This class manages the state of the OpenVPN Protocol configuration and API state for the app.  
You can set/get properties such as `protocol`, `port`, `scramble`, `ipv6LeakProtection`, `dnsLeakProtection`.

---

## Properties
- **`protocol`** (`OpenVPNProtocolType`):  
  OpenVPN protocol type - TCP or UDP
  
- **`port`** (`NSUInteger`):  
  OpenVPN port number, or scramble port number.

- **`ipv6LeakProtection`** (`BOOL`):  
  If `true`, IPv6 leak protection is enabled; otherwise, IPv6 routing is allowed.

- **`dnsLeakProtection`** (`BOOL`):  
  If `true`, DNS leaks are prevented; otherwise, a DNS leak may occur.

- **`scramble`** (`BOOL`):  
  If `true`, data packets are scrambled before being sent; otherwise, no scrambling is applied.

---

## Methods

### 1. `availablePorts`

#### Swift
```swift
func availablePorts() -> [NSNumber]
```
Description:
Returns a list of available OpenVPN ports. If scramble is enabled, returns the corresponding scramble port(s).

#### Objective-C
```objc
- (NSArray<NSNumber *> *)availablePorts;
```
Description:
Returns a list of available OpenVPN ports. If scramble is enabled, returns the corresponding scramble port(s).


# Implementation notes:

Implementation regarding VPN Configuration can be found:
> Refer: [VPNConfiguration](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNConfiguration.md)

Implementation regarding On Demand can be found:
> Refer: [VPNOnDemandConfiguration](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/On%20Demand.md)
   
Errors based on error codes can be found:
> Refer: [Errors](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Errors.md)
