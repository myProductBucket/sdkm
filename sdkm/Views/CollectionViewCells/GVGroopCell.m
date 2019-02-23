//
//  GVGroopCell.m
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVGroopCell.h"

@implementation GVGroopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.viewContent.layer setBorderColor:[GVShared shared].themeColor.CGColor];
    [self.viewContent.layer setBorderWidth:1];
    [self.viewContent.layer setCornerRadius:self.viewContent.frame.size.height / 2];
    
    [self.lblAdmin.layer setMasksToBounds:YES];
    [self.lblAdmin.layer setCornerRadius:self.lblAdmin.frame.size.height / 2];
    [self.lblFirst.layer setMasksToBounds:YES];
    [self.lblFirst.layer setCornerRadius:self.lblAdmin.frame.size.height / 2];
    [self.lblSecond.layer setMasksToBounds:YES];
    [self.lblSecond.layer setCornerRadius:self.lblAdmin.frame.size.height / 2];
    [self.lblThird.layer setMasksToBounds:YES];
    [self.lblThird.layer setCornerRadius:self.lblAdmin.frame.size.height / 2];
}

@end
