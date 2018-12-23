//
//  GVGroopDetailController.h
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVBaseNavController.h"
#import "GVCircleImageView.h"
#import "GVGroop.h"

typedef enum : NSUInteger {
    GROOP_DETAIL_FROM_MY_GROOPS = 200,
    GROOP_DETAIL_FROM_UPCOMING_GROOPVIEWS,
} GVGroopDetailViewType;

//NS_ASSUME_NONNULL_BEGIN

@interface GVGroopDetailController : GVBaseNavController

@property (strong, nonatomic) GVGroop *groop;
@property GVGroopDetailViewType viewType;

@end

//NS_ASSUME_NONNULL_END
