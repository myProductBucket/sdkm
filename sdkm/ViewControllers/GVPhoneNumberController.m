//
//  GVPhoneNumberController.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVPhoneNumberController.h"
#import "GVConfirmCodeController.h"
#import "CountryPicker.h"

#define INVALID @"Invalid"

@interface GVPhoneNumberController () <CountryPickerDelegate, UITextFieldDelegate> {
}

@end

@implementation GVPhoneNumberController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initLayout];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:GV_NS_REGISTERED object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
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
    CountryPicker *countryPicker = [[CountryPicker alloc] init];
    [countryPicker setDelegate:self];
    
    [self.txtCountryCode setDelegate:self];
    [self.txtCountryCode setReturnKeyType:UIReturnKeyNext];
    [self.txtCountryCode setKeyboardType:UIKeyboardTypeNumberPad];
    [self.txtCountryCode setText:@"+1"];
    
    [self.txtPhoneNumber setDelegate:self];
    [self.txtPhoneNumber setReturnKeyType:UIReturnKeyContinue];
    [self.txtPhoneNumber setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self.txtCountryName setDelegate:self];
    [self.txtCountryName setInputView:countryPicker];
    [self.txtCountryName setText:@"US"];
    
    // Observers for Phone Number
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePhoneNumber:) name:UITextFieldTextDidChangeNotification object:self.txtPhoneNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeCountryCode:) name:UITextFieldTextDidChangeNotification object:self.txtCountryCode];
    
    // Buttons
    [self.btnContinuePhone.layer setCornerRadius:5];
}

- (Boolean)validatePhoneNumber {
    NSMutableArray *arrViews = [[NSMutableArray alloc] init];
    if (self.txtCountryName.text == nil
        || [self.txtCountryName.text isEqualToString:@""]
        || [self.txtCountryName.text isEqualToString:INVALID]) {
        [arrViews addObject:self.txtCountryCode];
        [arrViews addObject:self.txtCountryName];
    }
    if (self.txtPhoneNumber.text == nil
        || [self.txtPhoneNumber.text isEqualToString:@""]) {
        [arrViews addObject:self.txtPhoneNumber];
    }
    if (arrViews.count > 0) {
        AFViewShaker *viewShaker = [[AFViewShaker alloc] initWithViewsArray:arrViews];
        [viewShaker shake];
        return NO;
    }
    return YES;
}

#pragma mark - Notification Observers

- (void)didChangePhoneNumber:(NSNotification *)sender {
    NSString *str = self.txtPhoneNumber.text;
    NSString *trimmed = [[str componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    NBAsYouTypeFormatter *f = [[NBAsYouTypeFormatter alloc] initWithRegionCode:self.txtCountryName.text];
    
    NSString *formattedNumber = [f inputString:trimmed];
    [self.txtPhoneNumber setText:formattedNumber];
}

- (void)didChangeCountryCode:(NSNotification *)sender {
    NSString *ccNumber = self.txtCountryCode.text;
    if (![ccNumber containsString:@"+"]) {
        [self.txtCountryCode setText:[NSString stringWithFormat:@"+%@", ccNumber]];
        ccNumber = self.txtCountryCode.text;
    } else if ([ccNumber containsString:@"+"] && ccNumber.length == 1) {
        [self.txtCountryCode setText:@""];
        [self.txtCountryName setText:@""];
        return;
    }
    // Country Code
    NSString *countryCode = [ccNumber substringFromIndex:1];
    NBPhoneNumberUtil *pnUtil = [[NBPhoneNumberUtil alloc] init];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    // Region Code
    NSString *alpha2 = [pnUtil getRegionCodeForCountryCode:[f numberFromString:countryCode]];
    if ([alpha2 isEqualToString:@"ZZ"]) {
        alpha2 = INVALID;
        [self.txtCountryName setTextColor:[UIColor redColor]];
    } else {
        [self.txtCountryName setTextColor:[UIColor blackColor]];
    }
    [self.txtCountryName setText:alpha2];
}

- (void)presentConfirmCode {
    
    NSString *countryCode = [GVGlobal shared].mUser.countryCode;
    NSString *phoneNumber = [GVGlobal shared].mUser.phoneNumber;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[GVService shared] verifyPhoneNumber:phoneNumber countryCode:countryCode withCompletion:^(BOOL success, id res) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (success) {
            if (res[@"verification_token"]) {
                NSLog(@"Verification Token: %@", res[@"verification_token"]);
    
    [[GVGlobal shared].mUser save:PREF_SIGN_UP_INFO];
    
                GVConfirmCodeController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVConfirmCodeController"];
                [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
                [self presentViewController:vc animated:YES completion:nil];
            }
        } else if ([res isKindOfClass:[NSError class]]) {
            NSError *error = res;
            [GVGlobal showAlertWithTitle:GROOPVIEW message:error.localizedDescription fromView:self withCompletion:nil];
        } else {
            [GVGlobal showAlertWithTitle:GROOPVIEW message:GV_ERROR_MESSAGE fromView:self withCompletion:nil];
        }
    }];
}

#pragma mark - Actions

- (IBAction)didClickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didClickContinuePhone:(id)sender {
    if ([self validatePhoneNumber]) {
        // Process
        NSString *trimmedPhoneNum = [[self.txtPhoneNumber.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSString *countryCode = [[[[NBPhoneNumberUtil alloc] init] getCountryCodeForRegion:self.txtCountryName.text] stringValue];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[GVService shared] checkPhoneNumberExist:trimmedPhoneNum withCompletion:^(BOOL success, id res) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (success) {
                if ([res[@"status"] isEqualToString:@"success"]) {
                    [GVGlobal showAlertWithTitle:GROOPVIEW
                                         message:@"An account with this phone number already exists."
                                        fromView:self
                                  withCompletion:nil];
                } else { // New Phone Number
                    [GVGlobal shared].mUser = [[GVUser alloc] init];
                    [GVGlobal shared].mUser.countryCode = countryCode;
                    [GVGlobal shared].mUser.phoneNumber = trimmedPhoneNum;
                    // Show Confirm Code View
                    [self presentConfirmCode];
                }
            } else if ([res isKindOfClass:[NSError class]]) {
                NSError *error = res;
                [GVGlobal showAlertWithTitle:GROOPVIEW
                                     message:error.localizedDescription
                                    fromView:self
                              withCompletion:nil];
            } else {
                [GVGlobal showAlertWithTitle:GROOPVIEW
                                     message:@"Unknown error occurred. Please try again later!"
                                    fromView:self
                              withCompletion:nil];
            }
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

#pragma mark - CountryPickerDelegate

- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code {
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *error;
    NSString *ccNumber = [[phoneUtil getCountryCodeForRegion:code] stringValue];
    if (error == nil) {
        [self.txtCountryName setTextColor:[UIColor blackColor]];
        [self.txtCountryName setText:code];
        [self.txtCountryCode setText:[NSString stringWithFormat:@"+%@", ccNumber]];
    } else {
        //        [[AppDelegate appDelegate] showAlertWithTitle:APP_NAME message:error.localizedDescription fromView:self withCompletion:nil];
    }
}

@end
