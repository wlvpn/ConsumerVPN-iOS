# V3APIAdapter:

Add following keys to the `V3APIAdapter` initialization code
- `kV3BaseUrlKey`               : This is the baseurl for api's.
- `kV3AlternateUrlsKey`         : The alternate Url in case baseurl fails.
- `kV3ApiKey`                   : The API key of app.
- `kV3CoreDataURL`              : The URL for your CoreData Store.
- `V3InstallFavoritesPlugin`    : By default `YES`
- `kV3ServiceNameKey`           :  This is the name of the keychain item to use when storing the login and VPN credentials in the keychain. This should be the name of your app. If you set this to "My VPN App" then the API adapter will create services with names like "My VPN App Login" and  "My VPN App Access Token".

```swift
  NSDictionary *options = @{
                kV3BaseUrlKey:               // WLVPN base URL,
                kV3AlternateUrlsKey:         // WLVPN alternate URLs,
                kV3ApiKey:                   // API key provided by WLVPN representative,
                kV3CoreDataURL:              // CoreData filepath from application document directory,
                kV3ServiceNameKey:           // WLVPN brand name ,
        };
```

# Connection Adapter:

 Initialize the connection adapter
- `kIKEv2UseIPAddress`          : If set to 'YES' uses the IPAddress of server else uses server's hostname
- `kVPNManagerBrandNameKey`     : Brand name
- `kIKEv2RemoteIdentifier`      : This string will be used for authentication purposes in identifying the remote IPSec endpoint 
- `kVPNSharedSecretKey`         : Shared secret key, can be the name of app
- `kIKEv2KeychainServiceName`   : This is the keychain service name to use when connecting to the VPN. 
- `kIKEv2V3BaseUrlKey`          : This is the baseurl for WLVPN API's.
- `kIKEv2V3AlternateUrlsKey`    : The alternate Url in case baseurl fails.
 
```swift
 NSDictionary *connectionOptions = @{
                kIKEv2UseIPAddress:         @YES,
                kVPNManagerBrandNameKey:    clientName,
                kIKEv2RemoteIdentifier:     @"*.vpn.appname.com",
                kVPNSharedSecretKey:        @"appname",
                kIKEv2KeychainServiceName:  [apiAdapter passwordServiceName],
                kIKEv2V3BaseUrlKey:         [self baseURL],
                kIKEv2V3AlternateUrlsKey:   [self backupURLs],
            };
```


# APIManager:
- `kBundleNameKey` : This is the bundle identifier you get from `CFBundleIdentifier`
- `kVPNDefaultProtocolKey` : The default protocol you want to set.
- `kVPNAccessGroupNameKey`: The name of the group using VPN
- `kCityPOPHostname` : This will be set as the POP hostname for all city objects. Used when you get the   hostname for the City.
- `kV3BaseUrlKey` : This is the baseurl for WLVPN API's.
- `kV3AlternateUrlsKey`: This will be an array of alternate base URLs if baseurl fails.
```swift
  NSDictionary *apiManagerOptions = @{
                kBundleNameKey:         bundleName,
                kVPNDefaultProtocolKey: defaultProtocol,
                kVPNAccessGroupNameKey: kAccessGroupName,
                kCityPOPHostname:       @"appname.com",
                kV3BaseUrlKey:          [self baseURL],
                kV3AlternateUrlsKey:    [self backupURLs],
        };
```


Check the example code below to see how to initialize the **`iOS`** app with the SDK:


```objc
@import VPNKit;
@import VPNV3APIAdapter;
@import VPKWireGuardExtension;
@import VPKWireGuardAdapter;
#import "SDKInitializer.h"

@implementation SDKInitializer

/**
 * Builds a VPNAPIManager object for various api and connection adapter settings.
 *
 * @param brandName The brand name of this client
 * @param configName The VPN configuration name of this client
 * @param apiKey    The api key provided on WLVPN signup
 * @param suffix    The username suffix provided on WLVPN Signup
 *
 * @return An initialized VPNAPIManager ready to use
 */
+ (nonnull VPNAPIManager *)initializeAPIManagerWithBrandName:(NSString *)brandName
                                                  configName:(NSString *)configName
                                                      apiKey:(NSString *)apiKey
                                                   andSuffix:(NSString *)suffix {
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *bundleID = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:bundleID];
    NSURL *coreDataUrl = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"VPNKit.sqlite"]];
    
    NSDictionary *apiAdapterOptions = @{
        kV3ApiKey:              apiKey,
        kV3CoreDataURL:         coreDataUrl,
        kV3ServiceNameKey:      brandName
    };
    
    V3APIAdapter *apiAdapter = [[V3APIAdapter alloc] initWithOptions:apiAdapterOptions];
    
    NSDictionary *connectionOptions = @{
        kVPNManagerUsernameExtensionKey:    suffix,
        kVPNManagerBrandNameKey:            brandName,
        kVPNManagerConfigurationNameKey:    configName,
        kIKEv2Hostname:                     @"vpn.wlvpn.com",
        kIKEv2RemoteIdentifier:             @"vpn.wlvpn.com",
        kVPNSharedSecretKey:                @"vpn",
        kIKEv2KeychainServiceName:          apiAdapter.passwordServiceName,
    };
    
    NSMutableArray *adapters = [NSMutableArray arrayWithCapacity:2];
    
    NSNumber *defaultProtocol = [NSNumber numberWithInt:VPNProtocolIKEv2];
    
    // The simulator doesn't work with VPN connections so the VPNConnectionTestAdapter fakes a connection
    // in the simulator. Produces all the correct notifications
#if (TARGET_OS_SIMULATOR)
    id <VPNConnectionAdapterProtocol> connectionAdapter = [[VPNConnectionTestAdapter alloc] initWithOptions:connectionOptions];
    [adapters addObject:connectionAdapter];
#else
    id <VPNConnectionAdapterProtocol> connectionAdapter = [[NEVPNManagerAdapter alloc] initWithOptions:connectionOptions];
    [adapters addObject:connectionAdapter];
    WireGuardAdapter *wireGuardAdapter = [self createWireGuardAdapterWithBrandName:brandName
                                                                            apiKey:apiKey
                                                                              uuid:[apiAdapter getOption:kV3UUIDKey]];
    [adapters addObject:wireGuardAdapter];
    defaultProtocol = [NSNumber numberWithInt:VPNProtocolWireGuard];
#endif
    
    NSDictionary *apiManagerOptions = @{
        kBundleNameKey:         bundleID,
        kVPNDefaultProtocolKey: defaultProtocol,
        kCityPOPHostname:       @"wlvpn.com",
        kBundleNameKey:         brandName,
    };
    
    VPNAPIManager *apiManager = [[VPNAPIManager alloc] initWithAPIAdapter:apiAdapter
                                                       connectionAdapters:adapters
                                                               andOptions:apiManagerOptions];
    
    // ensure that connections are not killed off when the app dies during an active connection
    [apiManager.vpnConfiguration setOption:@YES forKey:kVPNStayConnectedOnQuit];
    
    return apiManager;
}

#if !TARGET_OS_SIMULATOR
+ (WireGuardAdapter *)createWireGuardAdapterWithBrandName:(NSString *)brandName
                                                   apiKey:(NSString *)apiKey
                                                     uuid:(NSString *)uuid {
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleID = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    WireGuardAdapterConfiguration *wgConfig = [[WireGuardAdapterConfiguration alloc] init];
    
    wgConfig.brandName = brandName;
    wgConfig.useAPIKey = NO;
    wgConfig.uuid = uuid; //[apiAdapter getOption:kV3UUIDKey];
    wgConfig.apiKey = apiKey;
    wgConfig.extensionName = [bundleID stringByAppendingString:@".network-extension"];
    
    return [[WireGuardAdapter alloc] initWithConfiguration:wgConfig];
}
#endif

@end
```


Check the example code below to see how to initialize the **`macOS`** app with the SDK:


```objc
@import VPNKit;
@import VPNV3APIAdapter;
@import VPKWireGuardAdapter;
@import VPNV3APIAdapter;
@import VPNHelperAdapter;

@implementation SDKInitializer

/**
 * Builds a VPNAPIManager object for various api and connection adapter settings.
 *
 * @param brandName The brand name of this client
 * @param configName The VPN configuration name of this client
 * @param apiKey    The api key provided on WLVPN signup
 * @param suffix    The username suffix provided on WLVPN Signup
 * @param priviligedHelper PrivilgedHelperTool for OpenVPN.
 *
 * @return An initialized VPNAPIManager ready to use
 */
- (nonnull VPNAPIManager*) initializeAPIManagerWithBrandName:(NSString *)brandName
                                                  configName:(NSString *)configName
                                                      apiKey:(NSString *)apiKey
                                                      suffix:(NSString *)suffix {
    VPNPrivilegedHelperManager *privilegedHelperManager = [VPNPrivilegedHelperManager alloc]
             initWithHelperName: //openVPNToolBundleId 
                   andBrandName: //Theme.brandName;]];
     
    NSString *bundleID = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    
    // The directory the application uses to store the Core Data store file.
    // This code uses a directory named <brandName> in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                                   inDomains:NSUserDomainMask] lastObject];
    
    appSupportURL = [appSupportURL URLByAppendingPathComponent:bundleID];
    
    NSURL *coreDataURL = [appSupportURL URLByAppendingPathComponent:@"DataStore.sqlite"];
    
    NSDictionary *apiAdapterOptions = @{
        kV3ApiKey:              apiKey,
        kV3CoreDataURL:         coreDataURL,
        kV3ServiceNameKey:      brandName
    };
    
    V3APIAdapter *apiAdapter = [[V3APIAdapter alloc] initWithOptions:apiAdapterOptions];
    
    NSBundle *openVPNBundle = [NSBundle bundleForClass:[VPNOpenVPNConnectionAdapter class]];
    NSString *certificatePath = [openVPNBundle pathForResource:@"wlvpn" ofType:@"crt"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths firstObject];
    
    NSDictionary *connectionOptions = @{
        kVPNOpenVPNCertificatePath:         certificatePath,
        kVPNManagerUsernameExtensionKey:    suffix,
        kVPNManagerBrandNameKey:            brandName,
        kVPNManagerConfigurationNameKey:    configName,
        kVPNSharedSecretKey:                @"vpn",
        kVPNHelperDisableIPSec:             [NSNumber numberWithBool:YES],
        kVPNApplicationSupportDirectoryKey: applicationSupportDirectory,
        kIKEv2KeychainServiceName:          apiAdapter.passwordServiceName,
    };
    
    // Create adapters
    VPNOpenVPNConnectionAdapter *openVpnConnectionAdapter = [[VPNOpenVPNConnectionAdapter alloc] initWithOptions:connectionOptions andPrivilegedHelperManager:privilegedHelperManager];
    
    VPNLegacyConnectionAdapter *legacyConnectionAdapter = [[VPNLegacyConnectionAdapter alloc] initWithOptions:connectionOptions andPrivilegedHelperManager:privilegedHelperManager];
    
    NEVPNManagerAdapter *neVPNAdapter = [self createNEVPNManagerAdapter:brandName
                                                           extensionKey:suffix
                                                                service:apiAdapter.passwordServiceName];
    
    NSMutableArray *adapters = [NSMutableArray arrayWithCapacity:4];
    
    NSNumber *defaultProtocol = [NSNumber numberWithInteger:VPNProtocolIKEv2];
    
    // Order is important
    if (@available(macOS 10.13, *)) {
        WireGuardAdapter *wireGuardAdapter = [self createWireGuardAdapterWithBrandName:brandName bundleIdentifier:bundleID uuid:[apiAdapter getOption:kV3UUIDKey] apiKey:apiKey];
        [adapters addObject: wireGuardAdapter];
        defaultProtocol = [NSNumber numberWithInteger:VPNProtocolWireGuard];
    }
    
    [adapters addObject: openVpnConnectionAdapter];
    
    [adapters addObject: neVPNAdapter];
    
    [adapters addObject: legacyConnectionAdapter];
    
    // Initialize the API Manager
    NSDictionary *apiManagerOptions = @{
        kBundleNameKey:         bundleID,
        kVPNDefaultProtocolKey: defaultProtocol,
        kCityPOPHostname:       @"wlvpn.com",
        kBundleNameKey:         brandName,
    };
    
    VPNAPIManager *apiManager = [[VPNAPIManager alloc]
                                 initWithAPIAdapter:apiAdapter
                                 connectionAdapters:adapters
                                 andOptions:apiManagerOptions];

    return apiManager;
}

//MARK: - NEVPNManager Adapter

-(NEVPNManagerAdapter *)createNEVPNManagerAdapter:(NSString *)brandName
                                     extensionKey:(NSString *)extensionKey
                                          service:(NSString *)keychainService {
    
    NSDictionary * connectionOptions = @{kVPNManagerUsernameExtensionKey: extensionKey,
                                     kVPNManagerBrandNameKey: brandName,
                                              kIKEv2Hostname: @"vpn.wlvpn.com",
                                      kIKEv2RemoteIdentifier: @"vpn.wlvpn.com",
                                         kVPNSharedSecretKey: @"vpn",
                                   kIKEv2KeychainServiceName: keychainService};
    
    return [[NEVPNManagerAdapter alloc] initWithOptions:connectionOptions];
}

- (WireGuardAdapter *)createWireGuardAdapterWithBrandName:(NSString *)brandName
                                         bundleIdentifier:(NSString *)bundleIdentifier
                                                     uuid:(NSString *)uuid
                                                   apiKey:(NSString *)apiKey {
    
    WireGuardAdapterConfiguration *wgConfig = [[WireGuardAdapterConfiguration alloc] init];

    wgConfig.brandName = brandName;
    wgConfig.useAPIKey = NO;
    wgConfig.uuid = uuid;
    wgConfig.extensionName = [NSString stringWithFormat:@"%@.network-extension", bundleIdentifier];
    wgConfig.apiKey = apiKey;

    return [[WireGuardAdapter alloc] initWithConfiguration:wgConfig];
}

@end

```


Initialize the app from the **Appdelegate** as follows:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialize the APIManager using helper Objc object.
        apiManager = SDKInitializer.initializeAPIManager(
            withBrandName: //brandName,
            configName: //configName,
            apiKey: //apiKey,
            andSuffix: //usernameSuffix
        )
}
```

