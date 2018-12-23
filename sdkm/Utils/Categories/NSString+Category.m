//
//  NSString+Category.m
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

- (NSString *)removeSpacesOnLeadAndTrail {
    if (self == nil) {
        return nil;
    }
    NSString *newString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return newString;
}

@end
