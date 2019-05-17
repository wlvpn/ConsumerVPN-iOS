//
//  SDKInitializer.h
//  ConsumerVPN
//
//  Created by WLVPN on 9/9/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VPNAPIManager;

/**
 * Builds a VPNAPIManager object for various api and connection adapter settings.
 *
 * @param brandName The brand name of this client
 * @param apiKey    The api key provided on WLVPN signup
 * @param suffix    The username suffix provided on WLVPN Signup
 *
 * @return An initialized VPNAPIManager ready to use
 */
@interface SDKInitializer : NSObject

+ (nonnull VPNAPIManager*)initializeAPIManagerWithBrandName:(nonnull NSString *)brandName
													 apiKey:(nonnull NSString *)apiKey
												  andSuffix:(nonnull NSString *)suffix;
@end
