//
// Created by WLVPN on 1/22/16.
// Copyright (c) 2016 WLVPN All rights reserved.
//

#import "UIColor+HexColor.h"


@implementation UIColor (HexColor)

+ (UIColor *)colorWithHexColorString:(NSString *)inColorString
{
	// Strip the hex
	if ([inColorString hasPrefix:@"#"]) {
		inColorString = [inColorString substringWithRange:NSMakeRange(1, [inColorString length] - 1)];
	}

	UIColor* result = nil;
	unsigned colorCode = 0;
	unsigned char redByte, greenByte, blueByte;

	if (nil != inColorString) {
		NSScanner* scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode]; // ignore error
	}

	redByte = (unsigned char)(colorCode >> 16);
	greenByte = (unsigned char)(colorCode >> 8);
	blueByte = (unsigned char)(colorCode); // masks off high bits

	result = [UIColor colorWithRed:(CGFloat)redByte / 0xff
							 green:(CGFloat)greenByte / 0xff
							  blue:(CGFloat)blueByte / 0xff
							 alpha:1.0
	];

	return result;
}

@end