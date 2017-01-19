//
//  UIColor+HexStringColor.m
//  DaDaView
//
//  Created by chaoyang805 on 2016/11/8.
//  Copyright © 2016年 chaoyang805. All rights reserved.
//

#import "UIColor+HexStringColor.h"

@implementation UIColor (HexStringColor)

static NSString * const kHexColorStringPrefix = @"0x";

/**
 

 @param colorString 8byte hexrgba hex string
 @return return value description
 */
+ (instancetype)colorWithHexString:(nonnull NSString *)colorString {
    if ([colorString isEqualToString:@""]) {
        return nil;
    }
    // 0xaabbccff
    //   r g b a
    // 0 2 4 6 8
    NSUInteger red;
    NSUInteger green;
    NSUInteger blue;
    NSUInteger alpha;
    NSString *hexString = colorString;
    
    if ([colorString hasPrefix:kHexColorStringPrefix]) {
         hexString = [colorString substringFromIndex:2];
    }
    NSString *redStr = [hexString substringWithRange:NSMakeRange(0, 2)];
    red = [UIColor hexStringToIngeter:redStr];
    
    NSString *greenStr = [hexString substringWithRange:NSMakeRange(2, 2)];
    green = [UIColor hexStringToIngeter:greenStr];
    
    NSString *blueStr = [hexString substringWithRange:NSMakeRange(4, 2)];
    blue = [UIColor hexStringToIngeter:blueStr];
    NSString *alphaStr = @"FF";
    if (hexString.length >= 8) {
        alphaStr = [hexString substringWithRange:NSMakeRange(6, 2)];
    }
    alpha = [UIColor hexStringToIngeter:alphaStr];
    return [[UIColor alloc] initWithRed:red / 255.f green:green / 255.f blue:blue / 255.f alpha:alpha / 255.f];
}

+ (unsigned int)hexStringToIngeter:(NSString *)hexString {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned int result;
    [scanner scanHexInt:&result];
    return result;
}


@end
