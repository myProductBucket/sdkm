//
//  GVGroopDetailController.m
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVGroopDetailController.h"
#import "GVCreateGroopController.h"
#import "GVGroopviewController.h"
#import "GVSetTimeController.h"

@interface GVGroopDetailController () <GVCreateGroopControllerDelegate> {
    NSInteger selectedIndex;
}

@property (weak, nonatomic) IBOutlet GVCircleImageView *imgAdminAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblAdminAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblAdminName;

@property (strong, nonatomic) IBOutletCollection(GVCircleImageView) NSArray *imgParticipantAvatars;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblParticipantAvatars;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btnParticipantButtons;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblParticipantNames;

@property (weak, nonatomic) IBOutlet UIButton *btnEditGroop;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;


/// Center View Width Constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCenterViewWidth;

@end

@implementation GVGroopDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initLayout];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods

- (void)initLayout {
    // Groop Title
    NSString *groopTitle = @"Groop Title";
    if (self.groop && self.groop.groopName) {
        groopTitle = self.groop.groopName;
    }
    [self.navigationItem setTitle:groopTitle];
    
//    [self.btnContinue.layer setCornerRadius:5];
//    [self.btnContinue setBackgroundColor:[GVShared shared].themeColor];
    
    //    if (IPHONE) {
    [self.constraintCenterViewWidth setConstant:GV_SCREEN_WIDTH * 280 / 375];
    //    } else {
    //        [self.cnstrntCenterViewWidth setConstant:SCREEN_HEIGHT * 280 / 667];
    //    }
    
    // Groop Admin Info
    [self.lblAdminAvatar.layer setMasksToBounds:YES];
    [self.lblAdminAvatar.layer setCornerRadius:GV_SCREEN_WIDTH * 25 / 375];
    NSString *shortName;
    if (self.groop) {
        if (self.groop.adminName.length < 2) {
            shortName = [self.groop.adminName uppercaseString];
        }
        else {
            shortName = [[self.groop.adminName substringToIndex:2] uppercaseString];
        }
    }
    [self.lblAdminAvatar setText:shortName];
    [self.lblAdminName setText:self.groop.adminName];
    
    [self refreshGroopLayout];
    
    [self.btnEditGroop setSelected:NO];
}

- (void)refreshGroopLayout {
    for (NSInteger i = 0; i < 3; i++) {
        GVCircleImageView *imgAvatar = self.imgParticipantAvatars[i];
        [imgAvatar setImage:[UIImage imageNamed:@"AddContactRed" inBundle:[GVShared getBundle] compatibleWithTraitCollection:nil]];
        
        UILabel *lblAvatar = self.lblParticipantAvatars[i];
        [lblAvatar.layer setMasksToBounds:YES];
        [lblAvatar.layer setCornerRadius:lblAvatar.frame.size.height / 2];
        
        UIButton *button = self.btnParticipantButtons[i];
        [button setTag:i];
        
        UILabel *lblName = self.lblParticipantNames[i];
        
        if (self.groop
            && self.groop.members
            && self.groop.members.count > i) {
            GVParticipant *participant = [self.groop.members objectAtIndex:i];
            if (participant.name && participant.phoneNumber) {
                [lblAvatar setHidden:NO];
                
                NSString *shortName;
                if (participant.name.length < 2) {
                    shortName = [participant.name uppercaseString];
                }
                else {
                    shortName = [[participant.name substringToIndex:2] uppercaseString];
                }
                [lblAvatar setText:shortName];
                [lblName setText:participant.name];
            } else {
                [lblAvatar setHidden:YES];
            }
        }
    }
}

- (void)presentSetTime:(Boolean)isGoLive {
//    SetTimeController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SetTimeController"];
//    [vc setGroop:self.groop];
//    [vc setIsGoLive:isGoLive];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteGroop {
    
    if (self.viewType == GROOP_DETAIL_FROM_MY_GROOPS) { // Delete Groop
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[GVService shared] removeGroopWithId:self.groop.groopId withCompletion:^(BOOL success, id res) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                if (res[@"status"]) {
                    [self.navigationController popViewControllerAnimated:YES];
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
    }
    else { // Delete Groopview
        
        NSString *myPhone = [GVGlobal shared].mUser.phoneNumber;
        if (![myPhone isEqualToString:self.groop.adminPhone]) {
            [GVGlobal showAlertWithTitle:GROOPVIEW message:@"You have no permission to delete this groopview." fromView:self withCompletion:nil];
            return;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[GVService shared] removeGroopviewWithId:self.groop.groopId withCompletion:^(BOOL success, id res) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                if (res[@"status"]) {
                    [self.navigationController popViewControllerAnimated:YES];
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
    }
}

#pragma mark - Actions

- (IBAction)didClickDeleteGroop:(id)sender {
    NSString *keyword;
    if (self.viewType == GROOP_DETAIL_FROM_MY_GROOPS)
        keyword = @"groop";
    else
        keyword = @"groopview";
    [GVGlobal showAlertWithTitle:GROOPVIEW message:[NSString stringWithFormat:@"Are you sure you want to delete this %@?", keyword] yesButtonTitle:@"Yes" noButtonTitle:@"No" fromView:self yesCompletion:^(UIAlertAction *action) {
        [self deleteGroop];
    }];
}

- (IBAction)didClickEditGroop:(id)sender {
    [self.btnEditGroop setSelected:!self.btnEditGroop.isSelected];
    if (!self.btnEditGroop.isSelected) {
        // Update Groop
        NSString *first = GV_NULL;
        NSString *second = GV_NULL;
        NSString *third = GV_NULL;
        NSString *firstCode = GV_NULL;
        NSString *secondCode = GV_NULL;
        NSString *thirdCode = GV_NULL;
        GVParticipant *participant;
        if (self.groop.members.count > 0) {
            participant = [self.groop.members objectAtIndex:0];
            if (![GVGlobal isNull:participant.phoneNumber]
                && ![GVGlobal isNull:participant.countryCode]) {
                first = participant.phoneNumber;
                firstCode = participant.countryCode;
            }
        }
        NSString *friend1 = [GVGlobal getJsonForFriend:firstCode phoneNumber:first];
        
        if (self.groop.members.count > 1) {
            participant = self.groop.members[1];
            if (![GVGlobal isNull:participant.phoneNumber]
                && ![GVGlobal isNull:participant.countryCode]) {
                second = participant.phoneNumber;
                secondCode = participant.countryCode;
            }
        }
        NSString *friend2 = [GVGlobal getJsonForFriend:secondCode phoneNumber:second];
        
        if (self.groop.members.count > 2) {
            participant = self.groop.members[2];
            if (![GVGlobal isNull:participant.phoneNumber]
                && ![GVGlobal isNull:participant.countryCode]) {
                third = participant.phoneNumber;
                thirdCode = participant.countryCode;
            }
        }
        NSString *friend3 = [GVGlobal getJsonForFriend:thirdCode phoneNumber:third];
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:GROOPVIEW message:@"You can edit the Groop name." preferredStyle:UIAlertControllerStyleAlert];
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [textField setPlaceholder:@"Groop Name"];
            [textField setText:self.groop.groopName];
        }];
        [alertC addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *groopName = [[alertC.textFields firstObject].text removeSpacesOnLeadAndTrail];
            if (groopName == nil || [groopName isEqualToString:@""]) {
                groopName = self.groop.groopName;
            }
            
            if (self.viewType == GROOP_DETAIL_FROM_MY_GROOPS) { // Update Groop
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[GVService shared] updateGroopWithId:self.groop.groopId name:groopName friend1:friend1 friend2:friend2 friend3:friend3 withCompletion:^(BOOL success, id res) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if (success) {
                        NSLog(@"%@", res);
                        if (res[@"status"]) {
//                            [GVGlobal showAlertWithTitle:GROOPVIEW
//                                                 message:@"Your Groop was just updated successfully."
//                                                fromView:self
//                                          withCompletion:nil];
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
            }
            else { // Update Groopview
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[GVService shared] updateGroopviewWithId:self.groop.groopId groopId:@"" videoURL:self.groop.videoURL videoThumb:self.groop.videoThumbnail isJoinNow:self.groop.isRightNow joinTime:self.groop.joinTime friend1:friend1 friend2:friend2 friend3:friend3 withCompletion:^(BOOL success, id res) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    if (success) {
                        NSLog(@"%@", res);
                        if (res[@"status"]) {
//                            [GVGlobal showAlertWithTitle:GROOPVIEW
//                                                 message:@"Your Groop was just updated successfully."
//                                                fromView:self
//                                          withCompletion:nil];
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
            }
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

- (IBAction)didClickParticipant:(UIButton *)sender {
    if (!self.btnEditGroop.isSelected) {
        [GVGlobal showAlertWithTitle:GROOPVIEW message:@"Please click the Edit Groop button to edit this groop." fromView:self withCompletion:nil];
        return;
    }
    
    selectedIndex = sender.tag;
    
    // Present Create Groop to Select Participant
    GVCreateGroopController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GVCreateGroopController"];
    [vc setViewType:CREATE_GROOP_FROM_GROOP_DETAIL];
    [vc setDelegate:self];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didClickContinue:(id)sender {
    if (self.viewType == GROOP_DETAIL_FROM_UPCOMING_GROOPVIEWS) { // from UpcomingGroopviews
//        [GVGlobal presentGroopview:self.groop.groopId];
        GVGroopviewController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVGroopviewController"];
        [vc setGroopviewId:self.groop.groopId];
        [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        if ([GVShared shared].createGroopviewInfo == nil) {
            [GVShared shared].createGroopviewInfo = [NSMutableDictionary dictionary];
        }
        if ([GVShared shared].chooseVideoController == nil) {
            [GVGlobal showAlertWithTitle:GROOPVIEW message:@"There is no view to choose the video." fromView:self withCompletion:nil];
            return;
        }
        
        if (self.groop.members.count == 0) {
            [GVGlobal showAlertWithTitle:GROOPVIEW message:@"There is no participant for this Groop. Please add at least one participant to start your Groopview." fromView:self withCompletion:nil];
            return;
        }
        
        [[GVShared shared].createGroopviewInfo setObject:self.groop.groopId forKey:GV_GROOP_ID];
        // CountryCodes and PhoneNumbers for all participants
        if (self.groop.members.count > 0) {
            GVParticipant *participant = [self.groop.members objectAtIndex:0];
            NSString *countryCode = GV_NULL, *phoneNumber = GV_NULL;
            if (participant.countryCode.length > 0
                && participant.phoneNumber.length > 0) {
                countryCode = participant.countryCode;
                phoneNumber = participant.phoneNumber;
            }
            [[GVShared shared].createGroopviewInfo setObject:countryCode forKey:GV_FIRST_CODE];
            [[GVShared shared].createGroopviewInfo setObject:phoneNumber forKey:GV_FIRST_PHONE];
        }
        if (self.groop.members.count > 1) {
            GVParticipant *participant = [self.groop.members objectAtIndex:1];
            NSString *countryCode = GV_NULL, *phoneNumber = GV_NULL;
            if (participant.countryCode.length > 0
                && participant.phoneNumber.length > 0) {
                countryCode = participant.countryCode;
                phoneNumber = participant.phoneNumber;
            }
            [[GVShared shared].createGroopviewInfo setObject:countryCode forKey:GV_SECOND_CODE];
            [[GVShared shared].createGroopviewInfo setObject:phoneNumber forKey:GV_SECOND_PHONE];
        }
        if (self.groop.members.count > 2) {
            GVParticipant *participant = [self.groop.members objectAtIndex:2];
            NSString *countryCode = GV_NULL, *phoneNumber = GV_NULL;
            if (participant.countryCode.length > 0
                && participant.phoneNumber.length > 0) {
                countryCode = participant.countryCode;
                phoneNumber = participant.phoneNumber;
            }
            [[GVShared shared].createGroopviewInfo setObject:countryCode forKey:GV_THIRD_CODE];
            [[GVShared shared].createGroopviewInfo setObject:phoneNumber forKey:GV_THIRD_PHONE];
        }
        
        id nextVC;
        if ([[GVShared shared].createGroopviewInfo objectForKey:GV_VIDEO_URL]) { // The video already selected
            nextVC = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVSetTimeController"];
        }
        else {
            nextVC = [GVShared shared].chooseVideoController;
        }
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

#pragma mark - GVCreateGroopControllerDelegate

- (void)didSelectParticipant:(GVUser *)user {
    GVParticipant *participant = [[GVParticipant alloc] init];
    participant.name = user.userName;
    participant.phoneNumber = user.phoneNumber;
    participant.countryCode = user.countryCode;
    
    Boolean isExisted = NO;
    for (GVParticipant *item in self.groop.members) {
        if (![GVGlobal isNull:participant.phoneNumber]
            && [participant.phoneNumber isEqualToString:item.phoneNumber]) {
            isExisted = YES;
            break;
        }
    }
    if (!isExisted) {
        [self.groop.members removeObjectAtIndex:selectedIndex];
        [self.groop.members addObject:participant];
        [self refreshGroopLayout];
    }
}

@end
