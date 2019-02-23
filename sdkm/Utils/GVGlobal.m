//
//  GVGlobal.m
//  sdkm
//
//  Created by Mobile on 15.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVGlobal.h"
#import "GVStartGroopviewController.h"
#import "GVMyGroopsController.h"
#import "GVGroopviewController.h"
@import Firebase;

@interface GVGlobal() {
    
}

@end

@implementation GVGlobal

+ (instancetype)shared {
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    //static id sharedObject = nil;  //if you're not using ARC
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
        //sharedObject = [[[self alloc] init] retain]; // if you're not using ARC
        [FIRApp configure];
    });
    return sharedObject;
}

- (NSString *)authorization {
    return [NSString stringWithFormat:@"%@ %@", self.tokenType, self.accessToken];
}

#pragma mark - Alerts

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)msg
                  fromView:(UIViewController *)vc
            withCompletion:(void (^)(UIAlertAction *action))handler {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler != nil) {
            handler(action);
        }
        else {
            [GVGlobal checkAlertInStack];
        }
    }]];
    [vc presentViewController:alertC animated:YES completion:nil];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)msg
            yesButtonTitle:(NSString *)yesStr
             noButtonTitle:(NSString *)noStr
                  fromView:(UIViewController *)vc
             yesCompletion:(void (^)(UIAlertAction *action))handler {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertC addAction:[UIAlertAction actionWithTitle:yesStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler != nil) {
            handler(action);
        }
        else {
            [GVGlobal checkAlertInStack];
        }
    }]];
    [alertC addAction:[UIAlertAction actionWithTitle:noStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [GVGlobal checkAlertInStack];
    }]];
    [vc presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - Utilities

+ (BOOL)isNull:(NSObject *)object {
    if (object == nil
        || [object isEqual:[NSNull null]]) {
        return YES;
    }
    return NO;
}

+ (NSMutableDictionary *)extractPhoneNumberFrom:(NSString *)from {
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSMutableDictionary *phoneDic = [[NSMutableDictionary alloc] init];
    if (from.length > 1 && [[from substringToIndex:1] isEqualToString:@"+"]) {
        NSString *nationalNumber;
        NSNumber *countryCode = [phoneUtil extractCountryCode:from nationalNumber:&nationalNumber];
        [phoneDic setObject:countryCode == nil? @"": [countryCode stringValue] forKey:@"country_code"];
        nationalNumber = [[nationalNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        [phoneDic setObject:nationalNumber == nil? @"": nationalNumber forKey:@"phone_number"];
    }
    else {
        NSNumber *countryCodeByCarrior = [phoneUtil getCountryCodeForRegion:[phoneUtil countryCodeByCarrier]];
        [phoneDic setObject:[countryCodeByCarrior stringValue] forKey:@"country_code"];
        [phoneDic setObject:[[from componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] forKey:@"phone_number"];
    }
    
    return phoneDic;
}

+ (NSString *)getJsonForFriend:(NSString *)countryCode
                   phoneNumber:(NSString *)phoneNumber {
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:countryCode forKey:@"country_code"];
    [dic setObject:phoneNumber forKey:@"phone_number"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

#pragma mark - Present ViewControllers

+ (void)presentGroopview:(NSString *)groopviewId {
    GVGroopviewController *vc = [[GVShared getStoryboard] instantiateViewControllerWithIdentifier:@"GVGroopviewController"];
    [vc setGroopviewId:groopviewId];
    [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.rootViewController.presentedViewController) {
        [window.rootViewController.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [window.rootViewController presentViewController:vc animated:YES completion:nil];
        }];
    }
    else
        [window.rootViewController presentViewController:vc animated:YES completion:nil];
}

+ (void)checkAlertInStack {
    if ([GVShared shared].arrAlerts == nil
        || [GVShared shared].arrAlerts.count == 0) {
        return;
    }
    UIViewController *vc = [[GVShared shared].arrAlerts lastObject];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.rootViewController.presentedViewController == nil
        && ![[NSUserDefaults standardUserDefaults] boolForKey:PREF_GROOPVIEW_STARTED]
        && ![[NSUserDefaults standardUserDefaults] boolForKey:PREF_GROOPVIEW_ALERT_PRESENTED]) {
        
        [window.rootViewController presentViewController:vc animated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREF_GROOPVIEW_ALERT_PRESENTED];
        }];
        
        [[GVShared shared].arrAlerts removeLastObject];
    }
}

@end
