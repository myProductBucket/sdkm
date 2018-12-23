//
//  GVNotificationCell.h
//  sdkm
//
//  Created by Mobile on 18.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface GVNotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;

@end

//NS_ASSUME_NONNULL_END
