//
//  GVNotificationAlertController.m
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVNotificationAlertController.h"

@interface GVNotificationAlertController () {
}

@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblQuestion;

@property (weak, nonatomic) IBOutlet UIButton *btnYes;
@property (weak, nonatomic) IBOutlet UIButton *btnNo;
@property (weak, nonatomic) IBOutlet UIButton *btnGotIt;

@end

@implementation GVNotificationAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREF_GROOPVIEW_ALERT_PRESENTED];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_GROOPVIEW_ALERT_PRESENTED];
    
    [GVGlobal checkAlertInStack];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - My Methods

- (void)initLayout {
    
//    [self.btnYes.layer setCornerRadius:5];
//    [self.btnYes setBackgroundColor:[GVShared shared].themeColor];
//    [self.btnGotIt.layer setCornerRadius:5];
//    [self.btnGotIt setBackgroundColor:[GVShared shared].themeColor];
    
    [self.btnNo.layer setCornerRadius:5];
    [self.btnNo.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.btnNo.layer setBorderWidth:1];
    
    [self.lblMessage setText:self.notification.notificationText];
    
    [self.lblQuestion setHidden:YES];
    [self.btnYes setHidden:YES];
    [self.btnNo setHidden:YES];
    [self.btnGotIt setHidden:YES];
    
    if (self.notification.notificationType == NT_ACCEPTED
        || self.notification.notificationType == NT_DECLINED) {
        [self.btnGotIt setHidden:NO];
        [self.btnGotIt setTitle:@"GOT IT" forState:UIControlStateNormal];
    }
    else if (self.notification.notificationType == NT_JOIN_ALERT) {
        [self.btnYes setTitle:@"JOIN NOW" forState:UIControlStateNormal];
        [self.btnNo setTitle:@"Later" forState:UIControlStateNormal];
        [self.btnYes setHidden:NO];
        [self.btnNo setHidden:NO];
        [self.lblQuestion setHidden:NO];
    }
    else if (self.notification.notificationType == NT_INVITATION) {
        [self.btnYes setTitle:@"Yes" forState:UIControlStateNormal];
        [self.btnNo setTitle:@"No" forState:UIControlStateNormal];
        [self.btnYes setHidden:NO];
        [self.btnNo setHidden:NO];
    }
    else {
        [self.btnGotIt setHidden:NO];
    }
}

- (void)acceptInvitation {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *groopviewId = self.notification.groopviewId;
    
    [self checkPhoneNumberWithCompletion:^(BOOL success, NSString *phoneNumber) {
        if (success) {
            [[GVService shared] acceptInvitationForGroopview:groopviewId phoneNumber:phoneNumber withCompletion:^(BOOL success, id res) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (success) {
                    NSLog(@"Acception Status:%@", res);
                    [GVGlobal showAlertWithTitle:GROOPVIEW
                                         message:@"Thank you for accepting!"
                                        fromView:self
                                  withCompletion:^(UIAlertAction *action) {
                                      //                [self checkGroopviewInfoOnFirebase:YES];
                                      [self dismissViewControllerAnimated:YES completion:^{
                                          [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_GROOPVIEW_ALERT_PRESENTED];
                                      }];
                                  }];
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
        else
            [GVGlobal showAlertWithTitle:GROOPVIEW message:GV_ERROR_MESSAGE fromView:self withCompletion:nil];
    }];
}

- (void)declineInvitation {
    NSString *groopviewId = self.notification.groopviewId;
    
    [self checkPhoneNumberWithCompletion:^(BOOL success, NSString *phoneNumber) {
        if (success) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[GVService shared] declineInvitationForGroopview:groopviewId phoneNumber:phoneNumber withCompletion:^(BOOL success, id res) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (success) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_GROOPVIEW_ALERT_PRESENTED];
                    }];
                }
                else if ([res isKindOfClass:[NSError class]]) {
                    NSError *error = res;
                    [GVGlobal showAlertWithTitle:GROOPVIEW
                                         message:error.localizedDescription
                                        fromView:self
                                  withCompletion:nil];
                }
            }];
        }
        else
            [GVGlobal showAlertWithTitle:GROOPVIEW message:GV_ERROR_MESSAGE fromView:self withCompletion:nil];
    }];
}

- (void)checkPhoneNumberWithCompletion:(void(^)(BOOL success, NSString *phoneNumber))block {
    NSString *phoneNumber = [GVGlobal shared].mUser.phoneNumber;
    if (phoneNumber) {
        if (block)
            block(YES, phoneNumber);
    }
    else {
        if ([GVGlobal shared].accessToken == nil
            || [GVGlobal shared].accessToken.length == 0) { //
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:PREF_CURRENT_USER]) {
                
                [[GVGlobal shared] setMUser:[GVUser loadUser:PREF_CURRENT_USER]];
                [self authenticate:[GVGlobal shared].mUser.phoneNumber completion:block];
            }
            else if ([GVShared shared].userInfo) {
                [self authenticate:[GVShared shared].userInfo.email completion:block];
            }
            else {
                [GVGlobal showAlertWithTitle:GROOPVIEW message:@"Please pass the user info to use the Groopview." fromView:self withCompletion:nil];
                if (block)
                    block(NO, nil);
            }
        }
        else {
            [self getUserInfoWithCompletion:block];
        }
    }
}

- (void)authenticate:(NSString *)userId completion:(void(^)(BOOL success, NSString *phoneNumber))block {
    if (userId == nil
        || userId.length == 0) {
        [GVGlobal showAlertWithTitle:GROOPVIEW message:@"Please pass your email address to use the Groopview." fromView:self withCompletion:nil];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] authenticate:userId completion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            NSLog(@"res");
            if ([res isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = res;
                if (dic[@"token_type"]) {
                    [[GVGlobal shared] setTokenType:dic[@"token_type"]];
                }
                if (dic[@"access_token"]) {
                    [[GVGlobal shared] setAccessToken:dic[@"access_token"]];
                }
                if (dic[@"refresh_token"]) {
                    [[GVGlobal shared] setRefreshToken:dic[@"refresh_token"]];
                }
                
                [self getUserInfoWithCompletion:block];
            }
        }
    }];
}

- (void)getUserInfoWithCompletion:(void(^)(BOOL success, NSString *phoneNumber))block {
    // Get User Info
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] getUserInfoWithCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            if (res[@"data"]
                && [res[@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = res[@"data"];
                GVUser *user = [[GVUser alloc] init];
                user.firstName = [GVGlobal isNull:[dic objectForKey:@"first_name"]]? nil: [dic objectForKey:@"first_name"];
                user.lastName = [GVGlobal isNull:[dic objectForKey:@"last_name"]]? nil: [dic objectForKey:@"last_name"];
                user.email = [GVGlobal isNull:[dic objectForKey:@"email"]]? nil: [dic objectForKey:@"email"];
                user.countryCode = [GVGlobal isNull:[dic objectForKey:@"country_code"]]? nil: [dic objectForKey:@"country_code"];
                user.phoneNumber = [GVGlobal isNull:[dic objectForKey:@"phone_number"]]? nil: [dic objectForKey:@"phone_number"];
                user.avatar = [GVGlobal isNull:[dic objectForKey:@"avatar_url"]]? nil: [dic objectForKey:@"avatar_url"];
                [user createUserName];
                [user createShortName];
                [user save:PREF_CURRENT_USER];
                [[GVGlobal shared] setMUser:user];
                if (block) {
                    block(YES, user.phoneNumber);
                    return;
                }
            }
        }
        if (block) {
            block(NO, nil);
        }
    }];
}

#pragma mark - Actions

- (IBAction)didClickYes:(id)sender {
    if (self.notification.notificationType == NT_JOIN_ALERT) {
        [self dismissViewControllerAnimated:YES completion:^{
            // Present Groopview
//            [GVGlobal presentGroopview:self.notification.groopviewId];
//            [[NSNotificationCenter defaultCenter] postNotificationName:GV_ALERT_DISMISSED object:nil userInfo:@{@"groopview_id":self.notification.groopviewId}];
            [GVGlobal presentGroopview:self.notification.groopviewId];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_GROOPVIEW_ALERT_PRESENTED];
        }];
    }
    else if (self.notification.notificationType == NT_INVITATION) {
        // Accept Invitation
        [self acceptInvitation];
    }
}

- (IBAction)didClickNo:(id)sender {
    if (self.notification.notificationType == NT_JOIN_ALERT) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_GROOPVIEW_ALERT_PRESENTED];
        }];
    }
    else if (self.notification.notificationType == NT_INVITATION) {
        // Decline Invitation
        [self declineInvitation];
    }
}

- (IBAction)didClickGotIt:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_GROOPVIEW_ALERT_PRESENTED];
    }];
}

@end
