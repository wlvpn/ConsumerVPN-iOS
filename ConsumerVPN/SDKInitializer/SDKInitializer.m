//
//  SDKInitializer.m
//  ConsumerVPN
//
//  Created by WLVPN on 9/9/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

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
    
    // Ensures that connections are not killed off when the app dies during an active connection
    [apiManager.vpnConfiguration setStayConnectedOnQuit:YES];
    
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
