//
//  GVContactCell.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVContactCell.h"

@implementation GVContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.btnInvite.layer setCornerRadius:5];
    [self.btnInvite.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.btnInvite.layer setBorderWidth:1];
    
    [self.lblAvatar.layer setMasksToBounds:YES];
    [self.lblAvatar.layer setCornerRadius:self.lblAvatar.frame.size.height / 2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
