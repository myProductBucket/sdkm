//
//  UIImage+Category.m
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

- (UIImage *)convertToColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw a white background (for white mask)
    CGFloat redValue;
    CGFloat greenValue;
    CGFloat blueValue;
    CGFloat alphaValue;
    [color getRed:&redValue green:&greenValue blue:&blueValue alpha:&alphaValue];
    //    NSLog(@"%f, %f, %f", redValue, greenValue, blueValue);
    CGContextSetRGBFillColor(ctx, redValue, greenValue, blueValue, alphaValue);
    CGContextFillRect(ctx, imageRect);
    
    // Apply the source image's alpha
    [self drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage* outImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return outImage;
}

@end
