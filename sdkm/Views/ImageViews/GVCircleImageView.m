//
//  GVCircleImageView.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVCircleImageView.h"

@implementation GVCircleImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Init Layout
    [self.layer setCornerRadius:self.frame.size.height / 2];
    [self.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.layer setBorderWidth:1];
    [self setClipsToBounds:YES];
    [self setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Init Layout
    [self.layer setCornerRadius:self.frame.size.height / 2];
    [self.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.layer setBorderWidth:1];
    [self setClipsToBounds:YES];
    [self setContentMode:UIViewContentModeScaleAspectFill];
}

@end
