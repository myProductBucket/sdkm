//
//  GVGlobal.h
//  sdkm
//
//  Created by Mobile on 15.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface GVGlobal : NSObject

@property (strong, nonatomic) GVUser *mUser;
@property (strong, nonatomic) NSString *tokenType;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;

+ (instancetype)shared;

- (NSString *)authorization;

#pragma mark - Alerts

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)msg
                  fromView:(UIViewController *)vc
            withCompletion:(void (^)(UIAlertAction *action))handler;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)msg
            yesButtonTitle:(NSString *)yesStr
             noButtonTitle:(NSString *)noStr
                  fromView:(UIViewController *)vc
             yesCompletion:(void (^)(UIAlertAction *action))handler;

#pragma mark - Utilities

+ (BOOL)isNull:(NSObject *)object;

+ (NSMutableDictionary *)extractPhoneNumberFrom:(NSString *)from;

+ (NSString *)getJsonForFriend:(NSString *)countryCode
                   phoneNumber:(NSString *)phoneNumber;

#pragma mark - Present ViewControllers

+ (void)presentGroopview:(NSString *)groopviewId;

+ (void)checkAlertInStack;

@end

//NS_ASSUME_NONNULL_END
