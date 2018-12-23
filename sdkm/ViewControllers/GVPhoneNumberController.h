//
//  GVPhoneNumberController.h
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GVPhoneNumberController : GVBaseController

@property (weak, nonatomic) IBOutlet UITextField *txtCountryCode;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtCountryName;
@property (weak, nonatomic) IBOutlet UIButton *btnContinuePhone;

@end

NS_ASSUME_NONNULL_END
