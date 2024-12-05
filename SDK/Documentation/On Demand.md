# On Demand VPN Configuration

On Demand VPN allows a VPN connection to be automatically established under specific conditions without user intervention. This feature ensures that certain apps or network requests always go through a secure VPN connection.

## How It Works

1. **Configuration Profiles**: On Demand rules are defined in a VPN configuration profile using keys like `OnDemandRules` and specifying criteria for when the VPN should be connected.

2. **Criteria for Activation**: On Demand rules can be set based on:
   - **Domain names**: Specific domains that trigger the VPN.
   - **DNS queries**: Specific DNS queries that trigger the VPN.
   - **Network detection**: Specific networks (like SSIDs) that trigger the VPN.
   - **Interface type**: Only trigger on certain types of network interfaces (WiFi, cellular, etc.).

3. **Rule Actions**: The possible actions for the On Demand rules include:
   - **Connect**: Establish the VPN connection.
   - **Disconnect**: Disconnect the VPN connection.
   - **Ignore**: Take no action.

## Example Configuration

You can get the `VPNOnDemandConfiguration` via `apiManager.vpnConfiguration?.onDemandConfiguration` and set its `enabled` property to true.

Note: You must synchronize the configuration for reflecting these changes. For example:

```swift
apiManager.vpnConfiguration.onDemandConfiguration.enabled = true
// Synchronize will do auto-connect or disconnect based on rules.
apiManager.synchronizeConfiguration()
```

## Properties

```markdown
- `enabled`                 : BOOL - Represents the onDemandEnabled flag. If an array of onDemandRules is present on the NEVPNManager, a "Connect on Demand" checkbox will appear in the iOS, iPadOS, macOS, and tvOS System Preferences.
- `enableSplitTunneling`    : NSString - Represents the split tunneling flag.
- `activeRules`: NSArray <NEOnDemandRule> - Converts the **VPNOnDemandConfiguration** object into a list of "Connect on Demand" rules.
- `trustCellular`           : BOOL - The VPN connection will be automatically connected on cellular networks if it is enabled. Ignored on macOS and tvOS.
- `trustEthernet`           : BOOL - The VPN connection will be automatically connected on ethernet networks if it is enabled.
- `trustWiFi`               : BOOL - When a Wi-Fi network is trusted, the VPN will automatically disconnect when the device connects to a network with this SSID.
- `trustedWiFiNetworks`     : NSArray <NSString *> - List of trusted Wi-Fi network
- `untrustedWiFiNetworks`   : NSArray <NSString *> -  List of untrusted Wi-Fi network
- `untrustedDomains`        : The VPN will automatically connect when macOS, tvOS or iOS attempts to resolve any of the domains on this list.
- `trustedDomains`          : `NSArray<NSString *> *` - The VPN will automatically disconnect when macOS, tvOS, or iOS attempts to resolve any of the domains on this list.
```

## Methods

###### `- (NSArray<NEOnDemandRule *> *)activeRules`
- Converts the `VPNOnDemandConfiguration` into a list of rules that can be used by the `NEVPNManager` subsystem.

###### `- (void)addTrustedWiFiNetwork:(NSString *)ssid`
- Adds a trusted Wi-Fi network.

###### `- (void)removeTrustedWiFiNetwork:(NSString *)ssid`
- Removes a trusted Wi-Fi network.

###### `- (void)updateTrustedWifiNetworksWith:(NSArray<NSString *> *)ssids`
- Updates the list of trusted Wi-Fi networks.

###### `- (void)addUntrustedWiFiNetwork:(NSString *)ssid`
- Adds an untrusted Wi-Fi network.

###### `- (void)removeUntrustedWiFiNetwork:(NSString *)ssid`
- Removes an untrusted Wi-Fi network.

###### `- (void)updateUntrustedWifiNetworksWith:(NSArray<NSString *> *)ssids`
- Updates the list of untrusted Wi-Fi networks.

###### `- (void)addUntrustedDomain:(NSString *)domain`
- Adds an untrusted domain. Trims whitespace and strips the protocol. Creates an NSURL to test.

###### `- (void)removeUntrustedDomain:(NSString *)domain`
- Removes an untrusted domain.

###### `- (void)updateUntrustedDomainsWith:(NSArray<NSString *> *)domains`
- Updates the list of untrusted domains.

###### `- (void)addTrustedDomain:(NSString *)domain withCompletion:(APIAddDomainCompletionHandler)completion`
- Adds a trusted domain. Trims whitespace and strips the protocol. Creates an NSURL to test.

###### `- (void)removeTrustedDomain:(NSString *)domain`
- Removes a trusted domain.

###### `- (void)updateTrustedDomainsWith:(NSArray<NSString *> *)domains withCompletion:(APIAddDomainCompletionHandler)completion`
- Updates the list of trusted domains.

###### -` (BOOL)isEqualToObject:(VPNOnDemandConfiguration *)object`
- Checks if the current object is equal to another `VPNOnDemandConfiguration` object.

#### Enums

##### `VPNAddDomainResult`
- **Description**: Enum used to represent the result of adding a domain.
  - `VPNAddDomainUnknownError`: Unknown domain error.
  - `VPNAddDomainInvalidError`: Invalid domain name error.
  - `VPNAddDomainEmptyError`: Empty domain name error.
  - `VPNAddDomainSuccess`: Success in adding a domain.


# Limitations of On Demand VPN

- Split tunneling is not compatible with On Demand configuration.
- This configuration only supports trusted Wi-Fi connections and untrusted domains.
