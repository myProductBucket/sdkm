//
//  GVConfirmCodeController.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVConfirmCodeController.h"
#import "AFViewShaker.h"

#define S_SPACE @" "

@interface GVConfirmCodeController () <UITextFieldDelegate> {
}

@end

@implementation GVConfirmCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.lblPhoneNumber setText:[GVGlobal shared].mUser.phoneNumber];
    
    [self initLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
    [self.btnContinue.layer setCornerRadius:5];
    
    // Code TextFields
    for (UITextField *textField in self.txtCodes) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(codeChanged:) name:UITextFieldTextDidChangeNotification object:textField];
        [textField setDelegate:self];
        [textField.layer setCornerRadius:5];
    }
}

- (BOOL)validateConfirmCode {
    NSMutableArray *arrViews = [[NSMutableArray alloc] init];
    for (UITextField *textField in self.txtCodes) {
        //        NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if (textField.text == nil
            || [textField.text isEqualToString:@""]) {
            //|| [textField.text rangeOfCharacterFromSet:notDigits].location != NSNotFound
            //            [textField setText:@""];
            [arrViews addObject:textField];
        }
    }
    if (arrViews.count > 0) {
        AFViewShaker *viewShaker = [[AFViewShaker alloc] initWithViewsArray:arrViews];
        [viewShaker shake];
        return NO;
    }
    return YES;
}

- (void)resendVerificationCode {
    
    NSString *countryCode = [GVGlobal shared].mUser.countryCode;
    NSString *phoneNumber = [GVGlobal shared].mUser.phoneNumber;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] verifyPhoneNumber:phoneNumber countryCode:countryCode withCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            if (res[@"verification_token"]) {
                NSLog(@"Verification Token: %@", res[@"verification_token"]);
            }
        } else if ([res isKindOfClass:[NSError class]]) {
            NSError *error = res;
            [GVGlobal showAlertWithTitle:GROOPVIEW message:error.localizedDescription fromView:self withCompletion:nil];
        } else {
            [GVGlobal showAlertWithTitle:GROOPVIEW message:GV_ERROR_MESSAGE fromView:self withCompletion:nil];
        }
    }];
}

- (void)registerUser {
//    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:PREF_UA_TOKEN];
    
    // Register the user to Groopview Database
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] registerUserWithCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            if (res[@"error"]) {
                [GVGlobal showAlertWithTitle:GROOPVIEW message:res[@"error"] fromView:self withCompletion:nil];
                return;
            }
            
            if (res[@"token_type"]) {
                [[GVGlobal shared] setTokenType:[NSString stringWithFormat:@"%@", res[@"token_type"]]];
            }
            if (res[@"access_token"]) {
                [[GVGlobal shared] setAccessToken:[NSString stringWithFormat:@"%@", res[@"access_token"]]];
            }
            if (res[@"refresh_token"]) {
                [[GVGlobal shared] setRefreshToken:[NSString stringWithFormat:@"%@", res[@"refresh_token"]]];
            }
//            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GV_NS_REGISTERED object:nil];
            return;
        }
        else if ([res isKindOfClass:[NSError class]]) {
            NSError *error = res;
            [GVGlobal showAlertWithTitle:GROOPVIEW
                                 message:error.localizedDescription
                                fromView:self
                          withCompletion:nil];
        }
        [GVGlobal showAlertWithTitle:GROOPVIEW
                             message:GV_ERROR_MESSAGE
                            fromView:self
                      withCompletion:nil];
    }];
}

#pragma mark - Actions

- (IBAction)didClickBack:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_SIGN_UP_INFO];
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didClickContinue:(id)sender {
    if ([self validateConfirmCode]) {
        NSString *verificationCode = @"";
        for (UITextField *codeTF in self.txtCodes) {
            verificationCode = [NSString stringWithFormat:@"%@%@", verificationCode, codeTF.text];
        }
        
        NSString *phoneNumber = [GVGlobal shared].mUser.phoneNumber;
        NSString *countryCode = [GVGlobal shared].mUser.countryCode;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[GVService shared] confirmPhoneNumber:phoneNumber countryCode:countryCode verificationCode:verificationCode withCompletion:^(BOOL success, id res) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                if (res[@"status"]) {

                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_SIGN_UP_INFO];
                    
                    [GVGlobal shared].mUser.avatar = [GVShared shared].userInfo.avatar;
                    [GVGlobal shared].mUser.userName = [GVShared shared].userInfo.userName;
                    [GVGlobal shared].mUser.firstName = [GVShared shared].userInfo.firstName;
                    [GVGlobal shared].mUser.lastName = [GVShared shared].userInfo.lastName;
                    [GVGlobal shared].mUser.email = [GVShared shared].userInfo.email;
                    
                    [[GVGlobal shared].mUser save:PREF_CURRENT_USER];
                    
                    [self registerUser];
        
                }
                else {
                    [GVGlobal showAlertWithTitle:GROOPVIEW message:@"Invalid Verification Code" fromView:self withCompletion:nil];
                }
            }
            else if ([res isKindOfClass:[NSError class]]) {
                NSError *error = res;
                [GVGlobal showAlertWithTitle:GROOPVIEW message:error.localizedDescription fromView:self withCompletion:nil];
            }
            else {
                [GVGlobal showAlertWithTitle:GROOPVIEW message:GV_ERROR_MESSAGE fromView:self withCompletion:nil];
            }
        }];
    }
}

- (IBAction)didClickResendCode:(id)sender {
    [self resendVerificationCode];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (([textField.text isEqualToString:S_SPACE])
        && (string == nil || [string isEqualToString:@""])) {
        
        UITextField *beforeTF;
        for (UITextField *item in self.txtCodes) {
            if (item == textField) {
                if (beforeTF != nil) {
                    [textField resignFirstResponder];
                    [beforeTF becomeFirstResponder];
                }
                return NO;
            } else {
                beforeTF = item;
            }
        }
    }
    
    if (string == nil || [string isEqualToString:@""]) {
        [textField setText:S_SPACE];
        return NO;
    }
    [textField setText:string];
    BOOL isNext = NO;
    for (UITextField *item in self.txtCodes) {
        if (isNext) {
            [textField resignFirstResponder];
            [item becomeFirstResponder];
            isNext = NO;
            break;
        }
        if (item == textField) {
            isNext = YES;
        }
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.text == nil
        || [textField.text isEqualToString:@""]) {
        [textField setText:S_SPACE];
    }
    return YES;
}

#pragma mark - Text Changed Notification Observer

- (void)codeChanged:(NSNotification *)sender {
}

@end
