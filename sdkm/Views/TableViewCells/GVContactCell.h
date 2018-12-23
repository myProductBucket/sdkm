//
//  GVContactCell.h
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCircleImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GVContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet GVCircleImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

@end

NS_ASSUME_NONNULL_END
