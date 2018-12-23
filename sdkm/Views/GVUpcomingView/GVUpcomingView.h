//
//  GVUpcomingView.h
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVCircleImageView.h"

//NS_ASSUME_NONNULL_BEGIN

@interface GVUpcomingView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblGroopTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblParticipant;

@property (weak, nonatomic) IBOutlet GVCircleImageView *imgAdminAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblAdminName;
@property (weak, nonatomic) IBOutlet UILabel *lblAdminShortName;

@property (strong, nonatomic) IBOutletCollection(GVCircleImageView) NSArray *imgAvatars;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblParticipantShortNames;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblParticipantStatus;

@property (weak, nonatomic) IBOutlet UILabel *lblGroopviewStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblVideoTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgVideo;

@end

//NS_ASSUME_NONNULL_END
