//
//  GVStartGroopviewController.h
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GVStartGroopviewController : GVBaseController

@property (weak, nonatomic) IBOutlet UIView *viewBackground;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIView *viewCreateGroop;
@property (weak, nonatomic) IBOutlet UIView *viewUseExisting;

@end

NS_ASSUME_NONNULL_END
