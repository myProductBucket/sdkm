//
//  GVLocationService.h
//  sdkm
//
//  Created by Mobile on 22.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GVLocationService : NSObject

+ (instancetype)shared;

- (void)startTracking;

@end

NS_ASSUME_NONNULL_END
