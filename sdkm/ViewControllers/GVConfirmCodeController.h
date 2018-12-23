//
//  GVConfirmCodeController.h
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseController.h"

//NS_ASSUME_NONNULL_BEGIN

@interface GVConfirmCodeController : GVBaseController

@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *txtCodes;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;

@end

//NS_ASSUME_NONNULL_END
