//
//  GVStartButton.m
//  sdkm
//
//  Created by Mobile on 21.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVStartButton.h"

@interface GVStartButton() {
}

@property (strong, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;

@end

@implementation GVStartButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initLayout];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayout];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.btnStart setImage:[[UIImage imageNamed:@"IconGroopview" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] convertToColor:[GVShared shared].themeColor] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - My Methods

- (void)initLayout {
    [self addSubview:[[[GVShared getBundle] loadNibNamed:@"GVStartButton" owner:self options:nil] objectAtIndex:0]];
    [self.viewContent setFrame:self.bounds];
    
    [self.btnStart setImage:[[UIImage imageNamed:@"IconGroopview" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil] convertToColor:[GVShared shared].themeColor] forState:UIControlStateNormal];
}

- (IBAction)didClickStart:(id)sender {
    if (self.delegate) {
        [self.delegate didClickGroopviewStart:sender];
    }
}

@end
