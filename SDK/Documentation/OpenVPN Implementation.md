# OpenVPN Implementation SetUp

## `App Target:`

- Add the Framework `VPNHelperAdapter` from SDK folder and mark it as `Embed and Sign`
- Disable `App Sandbox` into app entitlement file.

# Bridging Header

- To import a set of Objective-C files in the same app target as your Swift code, you rely on an Objective-C bridging header to expose those files to Swift.
- Import the Framework
```
@import VPNHelperAdapter;
```

## Setting up the AppDelegate

1. Import the Framework
```
import VPNHelperAdapter;
```

2. Declare the property for VPNPrivilegedHelperManager and pass it to the Initializer.
```
let privilegedHelperManager = VPNPrivilegedHelperManager(helperName: Theme.openVPNToolBundleId, andBrandName: Theme.brandName)
```

```
apiManager = sdk.initializeAPIManager(
            withBrandName: Theme.brandName,
            configName: Theme.configurationName,
            apiKey: Theme.apiKey,
            suffix: Theme.usernameSuffix,
            priviligedHelper: privilegedHelperManager!
        )
```

##  Update a VPNAPIManager object

1. Import the Framework
```
@import VPNV3APIAdapter;
@import VPNHelperAdapter;
```
2. Add parameter `priviligedHelper` to the `VPNAPIManager`
3. Add the `Certificate Path` as shown as shown in the example below.
4. Create an adapter for `VPNOpenVPNConnectionAdapter`
5. Remember to add Order as is important
6. Initialize the VPNAPIManager with the adapter as shown in the example below:

```

- (nonnull VPNAPIManager*) initializeAPIManagerWithBrandName:(NSString *)brandName
                                                  configName:(NSString *)configName
													  apiKey:(NSString *)apiKey
                                                      suffix:(NSString *)suffix
                                            priviligedHelper:(VPNPrivilegedHelperManager *)privilegedHelperManager {
    
	NSString *bundleID = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	
	// The directory the application uses to store the Core Data store file.
	// This code uses a directory named <brandName> in the user's Application Support directory.
	NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
																   inDomains:NSUserDomainMask] lastObject];
	
	appSupportURL = [appSupportURL URLByAppendingPathComponent:bundleID];
	
	NSURL *coreDataURL = [appSupportURL URLByAppendingPathComponent:@"DataStore.sqlite"];
    
    NSDictionary *apiAdapterOptions = @{
        kV3BaseUrlKey:          [SDKInitializer baseURL],
        kV3AlternateUrlsKey:    [SDKInitializer backupURLs],
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
        kVPNSharedSecretKey:                @"wlvpn",
        kVPNHelperDisableIPSec:             [NSNumber numberWithBool:YES],
        kVPNApplicationSupportDirectoryKey: applicationSupportDirectory,
        kIKEv2KeychainServiceName:          apiAdapter.passwordServiceName,
        kIKEv2V3BaseUrlKey:                 [SDKInitializer baseURL],
        kIKEv2V3AlternateUrlsKey:           [SDKInitializer backupURLs],
    };
    
    // Create adapters
    VPNOpenVPNConnectionAdapter *openVpnConnectionAdapter = [[VPNOpenVPNConnectionAdapter alloc] initWithOptions:connectionOptions andPrivilegedHelperManager:privilegedHelperManager];
    
    VPNLegacyConnectionAdapter *legacyConnectionAdapter = [[VPNLegacyConnectionAdapter alloc] initWithOptions:connectionOptions andPrivilegedHelperManager:privilegedHelperManager];
    
    NEVPNManagerAdapter *neVPNAdapter = [[NEVPNManagerAdapter alloc] initWithOptions:connectionOptions];
    
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
        kV3BaseUrlKey:          [SDKInitializer baseURL],
        kV3AlternateUrlsKey:    [SDKInitializer backupURLs],
	};
    
    VPNAPIManager *apiManager = [[VPNAPIManager alloc]
                                 initWithAPIAdapter:apiAdapter
                                 connectionAdapters:adapters
                                 andOptions:apiManagerOptions];

	return apiManager;
}

```

- App Target: Build Phases 
- Confirm that the `Code Signing Identity` is set to `Developer ID Application`


## Add the shell scripts
- Add `SMJobBlessUtil.py` which Apple provides for setting/checking the pairing between a privileged helper tool and its main app
- Add the App Script that is able to remove the OpenVPN Helper Privileged Tool `Uninstall.sh`

# `Command Line Tool`
##  Create new target

1. Add the `Command Line Tool` name it as "VPNHelperTool" 
2. Update bundle id as 'com.consumervpn.osx.vpnhelper'
3. For Command Line Tool add the XCFramework `vpnhelper` under the `General` tab
4. Mark it as `Embed and Sign`

 Select the Command Line Tool Target and implement the settings for:
  #### `Command Line Tool` General Settings
  Set the following:
  - Frameworks and Libraries:
    - Add the XCFramework `vpnhelper` from SDK folder and mark it as `Embed and Sign`


 #### `Command Line Tool` Signing and Capabilities 
 - Set the Signing Certificate to `Developer ID Application`
 

  #### `Command Line Tool` Build Settings
  Set the following:
  - Product Bundle Identifier, Product Name as `com.consumervpn.osx.vpnhelper`
  - Product Module Name : Double click and add `$(PRODUCT_NAME:c99extidentifier)`
  - Other Linkler Flag: 
    1. `$(inherited)` 
    2. `-sectcreate __TEXT __launchd_plist VPNHelperTool/VPNHelperTool-Launchd.plist`
  - RunpathSearchPaths: `@loader_path/../Frameworks`
  - Perform single object prelink: `Yes`
  - Info.plist: `VPNHelperTool/VPNHelperTool-Info.plist`
  - Library Search paths: `$(PROJECT_DIR)/SDK`
  - User Header Search path: `$SRCROOT/SDK/VPNKit` as non-recursive.
  - Code Signing Identity: `Developer ID Application`
  - Other Code signing flags: `$(inherited)``-i``$(PRODUCT_BUNDLE_IDENTIFIER)`
  - CURRENT_PROJECT_VERSION = 1
  - FRAMEWORK_SEARCH_PATHS = (
					"$(inherited)",
					"$(PROJECT_DIR)/SDK"),
  - HEADER_SEARCH_PATHS = "$(SRCROOT)/SDK/VPNKit";
  - INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.utilities"
  - OTHER_LDFLAGS = (
					"$(inherited)",
					"-ObjC",
				);
  - VERSIONING_SYSTEM = "apple-generic";
 

  #### `Command Line Tool` Deployment 
  Set the following:
   - `Skip Install : Yes`
      - Disable `SKIP INSTALL` to avoid export/archeive OpenVPN CommandLine Tool as separate file.
    

  #### `Command Line Tool` Build Phases 
  - For Build Phases confirm that the `Code Signing Identity` is set to `Developer ID Application`
  - Add new run script : Sign Internal Executables: Add following
    shell `/bin/sh`
    ```
    # Type a script or drag a script file from your workspace to insert its path.
    LOCATION="${BUILT_PRODUCTS_DIR}"/"${FRAMEWORKS_FOLDER_PATH}"

    IDENTITY=${EXPANDED_CODE_SIGN_IDENTITY_NAME}

    codesign --verbose --force --timestamp -o runtime --sign "$IDENTITY" "$LOCATION/VPNHelperAdapter.framework/Versions/A/Resources/openvpn"
    codesign --verbose --force --timestamp -o runtime --sign "$IDENTITY" "$LOCATION/VPNHelperAdapter.framework/Versions/A/Resources/client-up"
    codesign --verbose --force --timestamp -o runtime --sign "$IDENTITY" "$LOCATION/VPNHelperAdapter.framework/Versions/A/Resources/client-down"
    codesign --verbose --force --timestamp -o runtime --sign "$IDENTITY" "$LOCATION/VPNHelperAdapter.framework/Versions/A"
    ```
  - Tick the option `Based on dependancy analysis` and `Show Environment variables in log`
  - Expand `Embed Frameworks (1 item)` and select check `Copy only when installing`.

# Under group named `VPNHelperTool`
1. Update `main.m` as below:
```
#import <Foundation/Foundation.h>
#import "VPNHelperService.h"

int main(int argc, const char * argv[]) {
#pragma unused(argc)
#pragma unused(argv)
    
    // We just create and start an instance of the main helper tool object and then
    // have it run the run loop forever.
    
    @autoreleasepool {
        
        VPNHelperService *m = [[VPNHelperService alloc] init];
        
        [m run];                // This never comes back...
    }
    
    return EXIT_FAILURE;        // ... so this should never be hit.
}
```

2. Add the plist `VPNHelperTool-Info.plist`
 - Set the Bundle identifier and Bundle name
 - Add `SMAuthorizedClients` key value 
 - Update `XXXXXXXXXX` with `Developer ID` certificate Team ID 
 - Please check below plist
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleIdentifier</key>
	<string>com.consumervpn.osx.vpnhelper</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>com.consumervpn.osx.vpnhelper</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>SMAuthorizedClients</key>
	<array>
		<string>anchor apple generic and identifier "com.wlvpn.macos.consumervpn" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = XXXXXXXXXX)</string>
	</array>
</dict>
</plist>

```
3. Add Launchd file named `VPNHelperTool-Launchd.plist`
  - Label name should match `VPNHelperTool` Bundle ID
  - Add `MachServices` key with value as below:
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.consumervpn.osx.vpnhelper</string>
	<key>MachServices</key>
	<dict>
		<key>com.consumervpn.osx.vpnhelper</key>
		<true/>
	</dict>
</dict>
</plist>
```
 
# OpenVPN  helper installation Notifications
 
User is notified about the Helper insatllation through notifications through `VPNHelperStatusReporting`

> Refer : [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)

## OpenVPN connection

1. OpenVPN should connect after a successful helper installation.

# `Theme` 

#### Update the `Theme.Swift`
- Update `openVPNToolBundleId` key value with `VPNHelperTool` Bundle ID.
 - In sample app case, `com.consumervpn.osx.vpnhelper`
```
 static let openVPNToolBundleId = "<OpenVPNHelper Command Tool Bundle-ID>"
``` 

#### Update the Theme plist (for App Target)
- Add `SMPrivilegedExecutables` key with value as given below.
- Update `XXXXXXXXXX` with `Developer ID` certificate Team ID 

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIconFile</key>
	<string></string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.0</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>0</string>
	<key>ITSAppUsesNonExemptEncryption</key>
	<false/>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.utilities</string>
	<key>LSMinimumSystemVersion</key>
	<string>$(MACOSX_DEPLOYMENT_TARGET)</string>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
		<key>NSExceptionDomains</key>
		<dict>
			<key>wlvpn.com</key>
			<dict>
				<key>NSIncludesSubdomains</key>
				<true/>
				<key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSTemporaryExceptionMinimumTLSVersion</key>
				<string>TLSv1.1</string>
			</dict>
		</dict>
	</dict>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2019 All rights reserved.</string>
	<key>NSMainNibFile</key>
	<string>MainMenu</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>SMPrivilegedExecutables</key>
	<dict>
		<key>com.consumervpn.osx.vpnhelper</key>
		<string>anchor apple generic and identifier "com.consumervpn.osx.vpnhelper" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = XXXXXXXXXX)</string>
	</dict>
	<key>SUEnableAutomaticChecks</key>
	<false/>
</dict>
</plist>
```
