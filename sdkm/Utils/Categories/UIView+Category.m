//
//  UIView+Category.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)

- (void)setShadow:(CGFloat)value {
    [self.layer setCornerRadius:value];
    self.layer.shadowOffset = CGSizeMake(1, 1);
    self.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.layer.shadowRadius = value;
    self.layer.shadowOpacity = 0.80f;
}

@end
