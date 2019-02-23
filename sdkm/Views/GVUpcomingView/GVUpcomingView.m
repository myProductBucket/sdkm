//
//  GVUpcomingView.m
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVUpcomingView.h"

@implementation GVUpcomingView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self initLayout];
}

#pragma mark - My Methods

- (void)initLayout {
    [self.viewContent.layer setBorderColor:[GVShared shared].themeColor.CGColor];
    [self.viewContent.layer setBorderWidth:1.0f];
    
    [self.lblAdminShortName.layer setCornerRadius:self.lblAdminShortName.frame.size.height / 2];
    [self.imgAdminAvatar.layer setCornerRadius:self.imgAdminAvatar.frame.size.height / 2];
    
    NSInteger ind = 0;
    for (UILabel *lblShortName in self.lblParticipantShortNames) {
        [lblShortName.layer setCornerRadius:lblShortName.frame.size.height / 2];
        
        UIImageView *imgAvatar = [self.imgAvatars objectAtIndex:ind];
        [imgAvatar.layer setCornerRadius:imgAvatar.frame.size.height / 2];
        
        ind++;
    }
}

@end
