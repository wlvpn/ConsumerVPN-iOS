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

+ (NSString *)baseURL {
    return @"https://api.wlvpn.com/v3/";
}

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
        kV3BaseUrlKey:          [self baseURL],
        kV3AlternateUrlsKey:    @[],
        kV3ApiKey:              apiKey,
        kV3CoreDataURL:         coreDataUrl,
        kV3ServiceNameKey:      brandName
    };
    
    V3APIAdapter *apiAdapter = [[V3APIAdapter alloc] initWithOptions:apiAdapterOptions];
    
    NSDictionary *connectionOptions = @{
        kVPNManagerUsernameExtensionKey: suffix,
        kVPNManagerBrandNameKey: brandName,
        kVPNManagerConfigurationNameKey: configName,
        kIKEv2KeychainServiceName: apiAdapter.passwordServiceName,
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
        kBundleNameKey: bundleID,
        kVPNDefaultProtocolKey: defaultProtocol,
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
    
    WireGuardAdapterConfiguration *wgConfig = [[WireGuardAdapterConfiguration alloc] init];
    
    wgConfig.brandName = brandName;
    wgConfig.useAPIKey = NO;
    wgConfig.uuid = uuid; //[apiAdapter getOption:kV3UUIDKey];
    wgConfig.apiURL = [NSString stringWithFormat:@"%@wireguard", [self baseURL]];
    wgConfig.apiKey = apiKey;
    wgConfig.backupURL = @[];
    
    return [[WireGuardAdapter alloc] initWithConfiguration:wgConfig];
}
#endif

@end
