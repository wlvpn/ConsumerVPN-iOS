//
//  SDKInitializer.m
//  ConsumerVPN
//
//  Created by WLVPN on 9/9/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

@import VPNKit;
@import VPNV3APIAdapter;

#import "SDKInitializer.h"

@implementation SDKInitializer

/**
 * Builds a VPNAPIManager object for various api and connection adapter settings.
 *
 * @param brandName The brand name of this client
 * @param apiKey    The api key provided on WLVPN signup
 * @param suffix    The username suffix provided on WLVPN Signup
 *
 * @return An initialized VPNAPIManager ready to use
 */
+ (nonnull VPNAPIManager*) initializeAPIManagerWithBrandName:(NSString *)brandName
													  apiKey:(NSString *)apiKey
												   andSuffix:(NSString *)suffix {
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *bundleName = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:bundleName];
    NSURL *coreDataUrl = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"VPNKit.sqlite"]];
    
	NSDictionary *apiAdapterOptions = @{
		kV3ApiKey: apiKey,
        kV3CoreDataURL: coreDataUrl,
	};
    
    V3APIAdapter *apiAdapter = [[V3APIAdapter alloc] initWithOptions:apiAdapterOptions];
	
    NSDictionary *connectionOptions = @{
		kVPNManagerUsernameExtensionKey: suffix,
		kVPNManagerBrandNameKey: brandName,
	};
	
	// The simulator doesn't work with VPN connections so the VPNConnectionTestAdapter fakes a connection
	// in the simulator. Produces all the correct notifications
#if (TARGET_OS_SIMULATOR)
	id <VPNConnectionAdapterProtocol> connectionAdapter = [[VPNConnectionTestAdapter alloc] initWithOptions:connectionOptions];
#else
	id <VPNConnectionAdapterProtocol> connectionAdapter = [[NEVPNManagerAdapter alloc] initWithOptions:connectionOptions];
#endif

	NSDictionary *apiManagerOptions = @{
		kBundleNameKey:         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"],
		kVPNServiceNameKey:     brandName,
		kBrandNameKey:          brandName,
		kVPNDefaultProtocolKey: [NSNumber numberWithInt:VPNProtocolIKEv2],
		kCityPOPHostname:       @"wlvpn.com"
	};
    
    VPNAPIManager* apiManager = [[VPNAPIManager alloc] initWithAPIAdapter:apiAdapter
                                                        connectionAdapter:connectionAdapter
                                                               andOptions:apiManagerOptions];
    
    // ensure that connections are not killed off when the app dies during an active connection
    [apiManager.vpnConfiguration setOption:@YES forKey:kStayConnectedOnQuit];

    return apiManager;
}

@end
