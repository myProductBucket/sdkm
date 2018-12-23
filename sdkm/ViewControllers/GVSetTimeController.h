//
//  GVSetTimeController.h
//  sdkm
//
//  Created by Mobile on 18.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVBaseNavController.h"
#import "GVGroop.h"

//NS_ASSUME_NONNULL_BEGIN

@interface GVSetTimeController : GVBaseNavController

@property (weak, nonatomic) IBOutlet UISwitch *switchRightNow;
@property (weak, nonatomic) IBOutlet UIImageView *imgCalendar;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;

@property (strong, nonatomic) NSMutableArray *groopUsers;
@property (strong, nonatomic) GVGroop *groop;

@end

//NS_ASSUME_NONNULL_END
