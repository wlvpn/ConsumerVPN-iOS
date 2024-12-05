## Split Tunneling

VPN split tunneling is an advanced feature of virtual private network software designed to enhance control over VPN traffic.

### How does the VPN Split Tunneling work?

Split tunneling, offered by WLVPN, allows the software to decide whether to route specific internet traffic through the VPN's encrypted tunnel based on user-defined rules. Traffic excluded from the VPN is sent directly to the internet, akin to browsing without VPN protection. This excluded traffic maintains its speed but reveals your IP address. Consequently, websites requiring your actual IP address or location will function normally.

### Split Tunneling by Domains

Domain-based split tunneling requires a valid URL address.

### Properties

- The `enableSplitTunneling` property is set to YES when split tunneling is enabled; otherwise, it is set to NO.
  
  You can access this property using the following code:

```swift
let isSplitTunnelingEnabled = apiManager.vpnConfiguration.onDemandConfiguration.isSplitTunnelingEnabled
```

### Methods

#### Adding Domains

```objc
-(void)addTrustedDomain:(NSString * _Nonnull)domain
        withCompletion:(APIAddDomainCompletionHandler _Nullable)completion;
```

- **Description**: Adds a trusted domain into trusted domain list.
- **Parameters**:
  - `domain`: The domain name to add to the trusted domains list.
  - `completion`: The completion block for API call result.

#### Deleting Domains

```objc
-(void)removeTrustedDomain:(NSString * _Nonnull)domain;
```

- **Description**: Removes a trusted domain from the domain list.
- **Parameter**:
  - `domain`: The domain name to remove from the trusted domains list.

#### Updating Domains

```objc
-(void)updateTrustedDomainsWith:(NSArray<NSString *> *_Nonnull)domains
                 withCompletion:(APIAddDomainCompletionHandler _Nullable)completion;
```

- **Description**: Updates the domain in the list of trusted domains.
- **Parameters**:
  - `domains`: The domain names to add to the trusted domains list.
  - `completion`: The completion block for API call result.

#### Retrieving Domains

Domains added can be accessed from onDemandConfiguration, `trustedDomains`.

```swift
let domains = apiManager.vpnConfiguration.onDemandConfiguration.trustedDomains
```

### Limitations

- Split Tunneling and Connect-on-Demand are mutually exclusive. If Connect-on-Demand is enabled, Split Tunneling must be disabled, and vice versa.

