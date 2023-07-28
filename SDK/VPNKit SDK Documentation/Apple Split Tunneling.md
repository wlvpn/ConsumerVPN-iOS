# Split Tunneling
 VPN split tunneling is an advanced feature of virtual private network software, designed to help you better manage and control your VPN traffic. 
 
## How Does VPN Split Tunneling Work?
Split tunneling is a setting within certain VPN software applications.
When you request a domain or URL on the internet, the software decides whether that traffic needs to be routed through the VPN’s encrypted tunnel based on the rules you’ve specified.
Traffic that you’ve excluded is routed directly to the internet, just as it would if you were browsing without a VPN.
Excluded traffic isn’t slowed down like typical VPN traffic, but your IP address isn’t hidden. Websites that require your real IP address or location will therefore work as normal.

## `Split Tunneling by domains`
URL-based split tunneling requires the valid URL address.

# Property
- The `enableSplitTunneling` property is set to YES when split tunneling is enabled; otherwise, it is set to NO.
```
@property (nonatomic, getter=isSplitTunnelingEnabled) BOOL enableSplitTunneling NS_SWIFT_NAME(isSplitTunnelingEnabled);
```
- You can access this property using the following code:
```
let isSplitTunnelingEnabled = apiManager.vpnConfiguration.onDemandConfiguration.isSplitTunnelingEnabled
```

# Methods

**Adding domains**:
1. `-(void)addTrustedDomain:(NSString * _Nonnull)domain
          withCompletion:(APIAddDomainCompletionHandler _Nullable)completion;`
  Description:
  This method adds a trusted domain. Trims whitespace and strips the protocol. Creates an NSURL to test.
  **Parameter**: `domain` : The domain name to add to the trusted domains list.
  **Parameter**: `completion`: The completion block for API call result.
  Provide these parameters to the 
  [VPNConfiguration][VPNOnDemandConfiguration][addTrustedDomain]

**Deleting domains**:
2. `-(void)removeTrustedDomain:(NSString * _Nonnull)domain;`
  Description:
  Remove a trusted domain
  **Parameter**: `domain` : The domain name to remove from the trusted domains list.
  Provide this parameters to the 
  [VPNConfiguration][VPNOnDemandConfiguration][removeTrustedDomain]

**Updating domains**:
3. `-(void)updateTrustedDomainsWith:(NSArray<NSString *> *_Nonnull)domains
                  withCompletion:(APIAddDomainCompletionHandler _Nullable)completion`
  Description:
  This method adds a trusted domain. Trims whitespace and strips the protocol. Creates an NSURL to test.
  **Parameter**: `domains` : The domain names to add to the trusted domains list.
  **Parameter**: `completion`: The completion block for API call result.
  Provide these parameters to the 
  [VPNConfiguration][VPNOnDemandConfiguration][updateTrustedDomainsWith]

**Retrieving domains**:
  One can access the added domains from `NSMutableArray <NSString *> *trustedDomains` 
  
```
let onDemandConfiguration = vpnConfiguration.onDemandConfiguration 
let domains = onDemandConfiguration.trustedDomains
``` 
   
### `Limitations`

- Before swapping protocols, ensure that Connect-on-Demand is disabled.
- Split Tunneling and Connect-on-Demand are mutually incompatible. If Connect-on-Demand is enabled, Split Tunneling should be disabled, and vice versa.
