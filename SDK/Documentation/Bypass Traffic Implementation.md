# Bypass Traffic Implementation

## Overview

This document describes how to implement network settings customization using the WireGuard lifecycle override methods. These methods allow you to modify network settings (DNS, routes, IP configuration) before they are applied to the VPN tunnel.

The lifecycle methods can be overridden to customize:
- Network settings when VPN traffic starts (WireGuard Go packet reader starts)

## Use Cases

Common use cases for network settings customization include:

- **Custom DNS Configuration**: Add custom DNS servers (e.g., Cloudflare, Google DNS) to VPN traffic
- **Route Customization**: Modify included or excluded routes for traffic routing
- **Split Tunneling Enhancement**: Configure different DNS or routes for bypass mode
- **Partner DNS Integration**: Dynamically inject partner DNS servers during connection
- **Network Policy Enforcement**: Apply organization-specific network policies

## Override Methods

### `willStartWireGuard(networkSettings:)`

Override this method to modify network settings before the WireGuard Go packet reader starts and VPN traffic begins flowing through the tunnel.

```swift
public override func willStartWireGuard(networkSettings: NEPacketTunnelNetworkSettings) -> NEPacketTunnelNetworkSettings
```

**Parameters:**
- `networkSettings`: The original network settings that will be applied

**Returns:**
- Modified network settings to be applied to the VPN tunnel

**Invocation Context:**
- Called automatically when WireGuard starts or resumes from bypass mode
- Synchronous method executed on the WireGuard adapter work queue

## Implementation Flow

### 1. Override Lifecycle Method

Override the `willStartWireGuard(networkSettings:)` method in your `PacketTunnelProvider` subclass:

```swift
import VPKWireGuardExtension

public class PacketTunnelProvider: WGPacketTunnelProvider {

    /// Override to modify network settings when VPN traffic starts
    public override func willStartWireGuard(networkSettings: NEPacketTunnelNetworkSettings) -> NEPacketTunnelNetworkSettings {
        let modifiedSettings = modifyStartSettings(networkSettings)
        _ = super.willStartWireGuard(networkSettings: modifiedSettings)
        return modifiedSettings
    }
}
```

### 2. Implement Settings Modification

Create methods to customize network settings:

```swift
private func modifyStartSettings(_ original: NEPacketTunnelNetworkSettings) -> NEPacketTunnelNetworkSettings {
    let modified = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: original.tunnelRemoteAddress)

    // Copy IPv4 settings
    if let ipv4 = original.ipv4Settings {
        let ipv4Settings = NEIPv4Settings(
            addresses: ipv4.addresses,
            subnetMasks: ipv4.subnetMasks
        )
        ipv4Settings.includedRoutes = ipv4.includedRoutes
        ipv4Settings.excludedRoutes = ipv4.excludedRoutes
        modified.ipv4Settings = ipv4Settings
    }

    // Copy IPv6 settings
    if let ipv6 = original.ipv6Settings {
        let ipv6Settings = NEIPv6Settings(
            addresses: ipv6.addresses,
            networkPrefixLengths: ipv6.networkPrefixLengths
        )
        ipv6Settings.includedRoutes = ipv6.includedRoutes
        ipv6Settings.excludedRoutes = ipv6.excludedRoutes
        modified.ipv6Settings = ipv6Settings
    }

    // Customize DNS settings
    if let dns = original.dnsSettings {
        var dnsServers = dns.servers

        // Add custom DNS servers (e.g., Cloudflare DNS)
        if !dnsServers.contains("1.1.1.1") {
            dnsServers.append("1.1.1.1")
        }
        if !dnsServers.contains("1.0.0.1") {
            dnsServers.append("1.0.0.1")
        }

        let dnsSettings = NEDNSSettings(servers: dnsServers)
        dnsSettings.matchDomains = dns.matchDomains
        dnsSettings.searchDomains = dns.searchDomains
        modified.dnsSettings = dnsSettings
    }

    return modified
}

private func modifyStopSettings(_ original: NEPacketTunnelNetworkSettings) -> NEPacketTunnelNetworkSettings {
    let modified = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: original.tunnelRemoteAddress)

    // Copy bypass IPv4 configuration
    if let ipv4 = original.ipv4Settings {
        let ipv4Settings = NEIPv4Settings(
            addresses: ipv4.addresses,
            subnetMasks: ipv4.subnetMasks
        )
        ipv4Settings.excludedRoutes = ipv4.excludedRoutes
        modified.ipv4Settings = ipv4Settings
    }

    // Copy bypass IPv6 configuration
    if let ipv6 = original.ipv6Settings {
        let ipv6Settings = NEIPv6Settings(
            addresses: ipv6.addresses,
            networkPrefixLengths: ipv6.networkPrefixLengths
        )
        ipv6Settings.excludedRoutes = ipv6.excludedRoutes
        modified.ipv6Settings = ipv6Settings
    }

    // Keep DNS settings for bypass (use system DNS)
    if let dns = original.dnsSettings {
        let dnsSettings = NEDNSSettings(servers: dns.servers)
        dnsSettings.matchDomains = dns.matchDomains
        modified.dnsSettings = dnsSettings
    }

    return modified
}
```

### 3. Toggle Bypass Mode

Control bypass traffic using the `allowBypassAllTraffic` property:

```swift
// Enable bypass mode (triggers willStopWireGuard)
self.allowBypassAllTraffic = true

// Restore VPN traffic (triggers willStartWireGuard)
self.allowBypassAllTraffic = false
```

### 4. Example: Periodic Bypass Toggle

You can implement periodic bypass toggling for testing or traffic counting purposes:

```swift
public override func startTunnel(options: [String: NSObject]? = nil) async throws {
    self.allowBypassAllTraffic = true
    try await super.startTunnel(options: options)

    trafficCountingTask = Task { [weak self] in
        while !Task.isCancelled {
            if #available(iOS 16.0, *) {
                try? await Task.sleep(for: .seconds(60))
            } else {
                // Fallback on earlier versions
            }

            guard !Task.isCancelled, let self else {
                break
            }

            self.allowBypassAllTraffic.toggle()
        }
    }
}

public override func stopTunnel(with reason: NEProviderStopReason) async {
    trafficCountingTask?.cancel()
    trafficCountingTask = nil
    await super.stopTunnel(with: reason)
}
```
## Behavior Notes

### Execution Context

- **Thread Safety**: The override method is invoked on the WireGuard adapter work queue
- **Synchronous Operation**: The method executes synchronously and returns modified settings immediately
- **Super Call**: Always call `super.willStartWireGuard(networkSettings:)` to ensure proper initialization

## Notes

- The `willStartWireGuard(networkSettings:)` method is invoked automatically when WireGuard starts
- Settings modifications are applied synchronously, so ensure efficient processing
- Always call `super.willStartWireGuard(networkSettings:)` with the modified settings
- The method executes on the WireGuard adapter work queue
- For initial VPN connection settings, use standard `NEPacketTunnelProvider` configuration
