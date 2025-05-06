# Kill Switch


### How does the VPN kill switch work?


The Kill Switch is a feature provided by our WLVPN SDK designed to prevent data from leaking outside the VPN tunnel. It provides the following features:


**Traffic Routing**: Ensures that all network traffic routes through the VPN tunnel, except for designated system services necessary for maintaining device functionality.

**Outage Response**: If the VPN server experiences an outage, the application blocks the internet connection to prevent data leaks.

**Prevents TunnelVision Vulnerability**: If the local network directs the device to use a non-VPN network interface, the Kill Switch will block the internet traffic to prevent exposure.

## **Implementation**


### Property

- If the below property is set to `YES`, the system routes network traffic through the tunnel except traffic for designated system services necessary for maintaining expected device functionality, default it is set to `NO`.

```swift
@property (nonatomic, getter=isKillSwitchEnabled) BOOL killSwitch NS_SWIFT_NAME(isKillSwitchEnabled);
```

- You can access this property using the following code:

```swift
let isKillSwitchEnabled = apiManager.vpnConfiguration.isKillSwitchEnabled
```

- You can configure the `isKillSwitchEnabled` property using the following code example:

```swift
/// Toggles the Kill Switch functionality.
/// 
/// - Parameter enabled: A Boolean value that determines whether the Kill Switch is enabled or disabled.
/// Set to `true` to enable the Kill Switch, ensuring all traffic is routed through the VPN tunnel.
/// Set to `false` to disable the Kill Switch, allowing traffic to bypass the VPN tunnel when necessary.
func toggleKillSwitch(enabled: Bool) {
    guard apiManager.vpnConfiguration.isKillSwitchEnabled != enabled else { return }
    apiManager.vpnConfiguration.isKillSwitchEnabled = enabled
    apiManager.synchronizeConfiguration()
}
```

## **Important Notes**
  
  - All protocols are having **passive Kill Switch**, when application stops receiving a signal from the VPN server, it automatically prevents that device from sending your traffic.  
  
## **Limitations**

Activating the Kill Switch ensures that most network traffic is routed through the VPN tunnel, except for essential traffic, such as:

- Network control plane traffic (e.g., DHCP).
- Captive portal negotiation traffic (Wi-Fi hotspot authorization).
- Certain cellular services traffic (e.g., VoLTE).
- Traffic communicating with companion devices (e.g., Apple Watch).

The **Kill Switch** and **Split Tunneling** are mutually incompatible. Split Tunneling allows some traffic to bypass the VPN, which contradicts the Kill Switch functionality that blocks all non-VPN traffic.

