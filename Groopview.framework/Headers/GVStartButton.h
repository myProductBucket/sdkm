//
//  GVStartButton.h
//  sdkm
//
//  Created by Mobile on 21.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GVStartButtonDelegate <NSObject>
@optional
- (void)didClickGroopviewStart:(id)sender;
// ... other methods here
@end

//NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface GVStartButton : UIView

@property (nonatomic, weak) id<GVStartButtonDelegate> delegate;

@end

//NS_ASSUME_NONNULL_END
