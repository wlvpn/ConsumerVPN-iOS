# DNS Usage

# `Threat Protection`
### Features
- Works only with `WireGuard` and 'OpenVPN'(macOS only)
- Block ads, trackers and malicious websites when the VPN is connected
- If Threat Protection functionality is enabled, the SDK replaces the DNS provided value.

### Implementation
- To enable ThreatProtection feature set 'isThreatProtectionEnabled' flag.
```
  apiManager.vpnConfiguration.isThreatProtectionEnabled = true
```


# `Partner Filtering`
### Features
- Works only with `WireGuard` and 'OpenVPN'(macOS only)
- With this feature WLVPN partners can enable their own Threat Protection DNS filtering. 

### Implementation
- Enable the flag `isPartnerFilteringEnabled`
```
  apiManager.vpnConfiguration.isPartnerFilteringEnabled = true
```

# `Note:`
- Above Both settings `Threat Protection` and `Partner Filtering` are mutually exclusive, only one could be enabled at once.
