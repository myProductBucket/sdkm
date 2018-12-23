//
//  GVService.h
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVBaseService.h"

//NS_ASSUME_NONNULL_BEGIN

@interface GVService : GVBaseService

+ (instancetype)shared;

#pragma mark - User management

- (void)authenticate:(NSString *)username
          completion:(void(^)(BOOL success,id res))block;

- (void)getUserInfoWithCompletion:(void(^)(BOOL success,id res))block;

- (void)checkPhoneNumberExist:(NSString *)phoneNumber
               withCompletion:(void (^)(BOOL success, id res))block;

- (void)verifyPhoneNumber:(NSString *)phoneNumber
              countryCode:(NSString *)countryCode
           withCompletion:(void (^)(BOOL success, id res))block;

- (void)confirmPhoneNumber:(NSString *)phoneNumber
               countryCode:(NSString *)countryCode
          verificationCode:(NSString *)verificationCode
            withCompletion:(void (^)(BOOL success, id res))block;

- (void)registerUserWithCompletion:(void(^)(BOOL success,id res))block;

- (void)checkPhonenumbersExist:(NSMutableArray *)phonenumbers
                withCompletion:(void (^)(BOOL success, id res))block;

#pragma mark - Groop Management

- (void)createGroopWithName:(NSString *)name
                      first:(NSString *)first
                     second:(NSString *)second
                      third:(NSString *)third
             withCompletion:(void(^)(BOOL success, id res))block;

- (void)getGroopsWithCompletion:(void(^)(BOOL success, id res))block;

- (void)getGroopviewsWithCompletion:(void(^)(BOOL success, id res))block;

- (void)removeGroopWithId:(NSString *)groopId
           withCompletion:(void(^)(BOOL success, id res))block;

- (void)removeGroopviewWithId:(NSString *)groopviewId
               withCompletion:(void(^)(BOOL success, id res))block;

- (void)updateGroopWithId:(NSString *)groopId
                     name:(NSString *)name
                  friend1:(NSString *)friend1
                  friend2:(NSString *)friend2
                  friend3:(NSString *)friend3
           withCompletion:(void(^)(BOOL success, id res))block;

- (void)updateGroopviewWithId:(NSString *)groopviewId
                      groopId:(NSString *)groopId
                     videoURL:(NSString *)videoURL
                   videoThumb:(NSString *)videoThumb
                    isJoinNow:(BOOL)isJoinNow
                     joinTime:(NSString *)joinTime
                      friend1:(NSString *)friend1
                      friend2:(NSString *)friend2
                      friend3:(NSString *)friend3
               withCompletion:(void(^)(BOOL success, id res))block;

- (void)createGroopviewByGroopId:(NSString *)groopId
                         friend1:(NSString *)friend1
                         friend2:(NSString *)friend2
                         friend3:(NSString *)friend3
                        joinTime:(NSString *)joinTime // Timestamp
                        rightNow:(BOOL)rightNow // "1", "0"
                        videoURL:(NSString *)videoURL
                      videoTitle:(NSString *)videoTitle
                  videoThumbnail:(NSString *)videoThumbnail
                  withCompletion:(void(^)(BOOL success, id res))block;

#pragma mark - Notifications

- (void)getUserNotificationsWithCompletion:(void(^)(BOOL success, id res))block;

- (void)removeUserNotificationById:(NSString *)notificationId
                    withCompletion:(void(^)(BOOL success, id res))block;

- (void)readUserNotificationById:(NSString *)notificationId
                  withCompletion:(void(^)(BOOL success, id res))block;

- (void)acceptInvitationForGroopview:(NSString *)groopviewId
                         phoneNumber:(NSString *)phoneNumber
                      withCompletion:(void(^)(BOOL success, id res))block;

- (void)declineInvitationForGroopview:(NSString *)groopviewId
                          phoneNumber:(NSString *)phoneNumber
                       withCompletion:(void(^)(BOOL success, id res))block;

- (void)getGroopviewById:(NSString *)groopId
          withCompletion:(void(^)(BOOL success, id res))block;

- (void)getTwilioAccessTokenByGroopviewId:(NSString *)groopviewId
                           withCompletion:(void(^)(BOOL success, id res))block;

#pragma mark - Location Tracking

- (void)updateLocationWithLatitude:(NSString *)latitude
                         longitude:(NSString *)longitude
                    withCompletion:(void(^)(BOOL success, id res))block;

@end

//NS_ASSUME_NONNULL_END
