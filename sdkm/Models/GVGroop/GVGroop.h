//
//  GVGroop.h
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GVParticipant.h"

//NS_ASSUME_NONNULL_BEGIN

@interface GVGroop : NSObject

@property (strong, nonatomic) NSString *groopId;
@property (strong, nonatomic) NSString *groopName;
@property (strong, nonatomic) NSString *adminName;
@property (strong, nonatomic) NSString *adminAvatarURL;
@property (strong, nonatomic) NSString *adminPhone;
@property (strong, nonatomic) NSString *joinTime;
@property (strong, nonatomic) NSString *adminId;
@property (strong, nonatomic) NSMutableArray *members;
@property (strong, nonatomic) NSString *videoURL;
@property (strong, nonatomic) NSString *videoTitle;
@property (strong, nonatomic) NSString *videoThumbnail;

@property NSInteger numberOfParticipants;

///// Pending, Watching or Expired
//@property GroopviewStatus status;
/// Indicate whether the join time is right now or later
@property BOOL isRightNow;
@property BOOL isAdmin;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

//NS_ASSUME_NONNULL_END
