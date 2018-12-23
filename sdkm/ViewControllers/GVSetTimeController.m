//
//  GVSetTimeController.m
//  sdkm
//
//  Created by Mobile on 18.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVSetTimeController.h"

@interface GVSetTimeController() {
    
}

@end

@implementation GVSetTimeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - My Methods

- (void)initLayout {
    [self.navigationItem setTitle:@"Set Time"];
    
    [self.switchRightNow setOn:YES];
    [self.datePicker setHidden:YES];
    [self.datePicker addTarget:self action:@selector(didChangeDate:) forControlEvents:UIControlEventValueChanged];
    
    [self.btnInvite.layer setCornerRadius:5];
}

- (void)didChangeDate:(id)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    NSString *dateTime = [formatter stringFromDate:self.datePicker.date];
    [self.lblDateTime setText:dateTime];
}

#pragma mark - Actions

- (IBAction)didToggleRightNow:(UISwitch *)sender {
    if (sender.isOn) {
        [self.imgCalendar setImage:[UIImage imageNamed:@"CalendarGray" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil]];
        [self.datePicker setHidden:YES];
        [self.lblDateTime setHidden:YES];
    }
    else {
        [self.imgCalendar setImage:[UIImage imageNamed:@"CalendarDark" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil]];
        [self.datePicker setHidden:NO];
        [self.lblDateTime setHidden:NO];
    }
}

- (IBAction)didClickInvite:(id)sender {
    
    Boolean isRightNow = self.switchRightNow.on;
    
    NSTimeInterval intervalNow = [NSDate date].timeIntervalSince1970;
    NSTimeInterval intervalSelected = self.datePicker.date.timeIntervalSince1970;
    if (!isRightNow && intervalNow >= intervalSelected) {
        AFViewShaker *shaker = [[AFViewShaker alloc] initWithView:self.lblDateTime];
        [shaker shake];
        return;
    }
    
    NSString *joinTime = @"";
    if (!isRightNow) {
        joinTime = [NSString stringWithFormat:@"%f", intervalSelected];
    }
    
//    if ([GVGlobal isNull:self.groopUsers]
//        && [GVGlobal isNull:self.groop]) {
//        [GVGlobal showAlertWithTitle:GROOPVIEW
//                             message:@"Invalid Groop Information"
//                            fromView:self
//                      withCompletion:nil];
//        return;
//    }
    
    NSString *groopId = @"0";
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_GROOP_ID]) {
        groopId = [[GVShared shared].createGroopviewInfo objectForKey:GV_GROOP_ID];
    }
    NSString *first = GV_NULL, *second = GV_NULL, *third = GV_NULL, *firstCode = GV_NULL, *secondCode = GV_NULL, *thirdCode = GV_NULL;
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_FIRST_PHONE]) {
        first = [[GVShared shared].createGroopviewInfo objectForKey:GV_FIRST_PHONE];
    }
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_FIRST_CODE]) {
        firstCode = [[GVShared shared].createGroopviewInfo objectForKey:GV_FIRST_CODE];
    }
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_SECOND_PHONE]) {
        second = [[GVShared shared].createGroopviewInfo objectForKey:GV_SECOND_PHONE];
    }
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_SECOND_CODE]) {
        secondCode = [[GVShared shared].createGroopviewInfo objectForKey:GV_SECOND_CODE];
    }
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_THIRD_PHONE]) {
        third = [[GVShared shared].createGroopviewInfo objectForKey:GV_THIRD_PHONE];
    }
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_THIRD_CODE]) {
        thirdCode = [[GVShared shared].createGroopviewInfo objectForKey:GV_THIRD_CODE];
    }
    
    NSString *friend1 = [GVGlobal getJsonForFriend:firstCode phoneNumber:first];
    NSString *friend2 = [GVGlobal getJsonForFriend:secondCode phoneNumber:second];
    NSString *friend3 = [GVGlobal getJsonForFriend:thirdCode phoneNumber:third];
    
    NSString *videoURL = @"", *videoTitle = @"", *videoThumbnail = @"";
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_VIDEO_URL]) {
        videoURL = [[GVShared shared].createGroopviewInfo objectForKey:GV_VIDEO_URL];
    }
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_VIDEO_TITLE]) {
        videoTitle = [[GVShared shared].createGroopviewInfo objectForKey:GV_VIDEO_TITLE];
    }
    if ([[GVShared shared].createGroopviewInfo objectForKey:GV_VIDEO_THUMBNAIL]) {
        videoThumbnail = [[GVShared shared].createGroopviewInfo objectForKey:GV_VIDEO_THUMBNAIL];
    }
    
    [GVGlobal showAlertWithTitle:GROOPVIEW message:@"Are you sure you want to create this groopview?" yesButtonTitle:@"Yes" noButtonTitle:@"Cancel" fromView:self yesCompletion:^(UIAlertAction *action) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[GVService shared] createGroopviewByGroopId:groopId
                                             friend1:friend1
                                             friend2:friend2
                                             friend3:friend3
                                            joinTime:joinTime
                                            rightNow:isRightNow
                                            videoURL:videoURL
                                          videoTitle:videoTitle
                                      videoThumbnail:videoThumbnail
                                      withCompletion:^(BOOL success, id res) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                if (res[@"groopview_id"]) {
                    
                    [GVGlobal showAlertWithTitle:GROOPVIEW
                                         message:@"Your groopview was successfully created!"
                                        fromView:self
                                  withCompletion:^(UIAlertAction *action) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }];
                }
            }
            else if ([res isKindOfClass:[NSError class]]) {
                NSError *error = res;
                [GVGlobal showAlertWithTitle:GROOPVIEW
                                     message:error.localizedDescription
                                    fromView:self
                              withCompletion:nil];
            }
            else {
                [GVGlobal showAlertWithTitle:GROOPVIEW
                                     message:GV_ERROR_MESSAGE
                                    fromView:self
                              withCompletion:nil];
            }
        }];
    }];
}

@end
