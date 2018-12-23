//
//  GVNotificationAlertController.m
//  sdkm
//
//  Created by Mobile on 19.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVNotificationAlertController.h"

@interface GVNotificationAlertController ()

@end

@implementation GVNotificationAlertController

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

#pragma mark - My Methods

- (void)initLayout {
    
    [self.btnYes.layer setCornerRadius:5];
    [self.btnGotIt.layer setCornerRadius:5];
    
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
    [[GVService shared] acceptInvitationForGroopview:self.notification.groopviewId phoneNumber:[GVGlobal shared].mUser.phoneNumber withCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            NSLog(@"Acception Status:%@", res);
            [GVGlobal showAlertWithTitle:GROOPVIEW
                                 message:@"Thank you for accepting!"
                                fromView:self
                          withCompletion:^(UIAlertAction *action) {
                //                [self checkGroopviewInfoOnFirebase:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)declineInvitation {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] declineInvitationForGroopview:self.notification.groopviewId phoneNumber:[GVGlobal shared].mUser.phoneNumber withCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - Actions

- (IBAction)didClickYes:(id)sender {
    if (self.notification.notificationType == NT_JOIN_ALERT) {
        [self dismissViewControllerAnimated:YES completion:^{
            // Present Groopview
//            [GVGlobal presentGroopview:self.notification.groopviewId];
        }];
    }
    else if (self.notification.notificationType == NT_INVITATION) {
        // Accept Invitation
        [self acceptInvitation];
    }
}

- (IBAction)didClickNo:(id)sender {
    if (self.notification.notificationType == NT_JOIN_ALERT) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (self.notification.notificationType == NT_INVITATION) {
        // Decline Invitation
        [self declineInvitation];
    }
}

- (IBAction)didClickGotIt:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
