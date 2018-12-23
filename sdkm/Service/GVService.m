//
//  GVService.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVService.h"

@implementation GVService

+ (instancetype)shared {
    static GVService *singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[GVService alloc] init];
    });
    
    return singleton;
    
}

#pragma mark - User Management

- (void)authenticate:(NSString *)username
          completion:(void(^)(BOOL success,id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:[[GVShared shared] clientKeys] forKey:GV_CLIENT_KEYS];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:username forKey:@"username"];
    [params setObject:@"iOS" forKey:@"device_type"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:PREF_UA_TOKEN]) {
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PREF_UA_TOKEN] forKey:@"device_token"];
    }
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/authenticate" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}

- (void)getUserInfoWithCompletion:(void(^)(BOOL success,id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/get/user/info" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}

- (void)checkPhoneNumberExist:(NSString *)phoneNumber
               withCompletion:(void (^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:[[GVShared shared] clientKeys] forKey:GV_CLIENT_KEYS];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:phoneNumber forKey:@"phone_number"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/check/phone/exist" headers:headers params:params withResponse:^(BOOL success, id res) {
        if(success){
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else{            
            block(success,res);
        }
    }];
}

- (void)verifyPhoneNumber:(NSString *)phoneNumber
              countryCode:(NSString *)countryCode
           withCompletion:(void (^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:[[GVShared shared] clientKeys] forKey:GV_CLIENT_KEYS];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:phoneNumber forKey:@"phone_number"];
    [params setObject:countryCode forKey:@"country_code"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/verify/phone/number" headers:headers params:params withResponse:^(BOOL success, id res) {
        if(success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

- (void)confirmPhoneNumber:(NSString *)phoneNumber
               countryCode:(NSString *)countryCode
          verificationCode:(NSString *)verificationCode
            withCompletion:(void (^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:[[GVShared shared] clientKeys] forKey:GV_CLIENT_KEYS];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:phoneNumber forKey:@"phone_number"];
    [params setObject:countryCode forKey:@"country_code"];
    [params setObject:verificationCode forKey:@"verification_token"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/confirm/phone/number" headers:headers params:params withResponse:^(BOOL success, id res) {
        if(success){
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

- (void)registerUserWithCompletion:(void(^)(BOOL success,id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:[[GVShared shared] clientKeys] forKey:GV_CLIENT_KEYS];
    
    GVUser *userInfo = [GVGlobal shared].mUser;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userInfo.firstName   forKey:@"first_name"];
    [params setObject:userInfo.lastName    forKey:@"last_name"];
    [params setObject:userInfo.email       forKey:@"email"];
    [params setObject:userInfo.countryCode forKey:@"country_code"];
    [params setObject:userInfo.phoneNumber forKey:@"phone_number"];
    [params setObject:userInfo.avatar      forKey:@"avatar_url"];
    [params setObject:@"iOS"               forKey:@"device_type"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:PREF_UA_TOKEN]) {
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PREF_UA_TOKEN] forKey:@"device_token"];
    }
    else
        [params setObject:@"" forKey:@"device_token"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/registration" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            //            NSString *string = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

- (void)checkPhonenumbersExist:(NSMutableArray *)phonenumbers
                withCompletion:(void (^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:[[GVShared shared] clientKeys] forKey:GV_CLIENT_KEYS];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:phonenumbers options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:jsonString forKey:@"phone_numbers"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/phone/mass/check/exist" headers:headers params:params withResponse:^(BOOL success, id res) {
        
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

#pragma mark - Groop Management

- (void)createGroopWithName:(NSString *)name
                      first:(NSString *)first
                     second:(NSString *)second
                      third:(NSString *)third
             withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:name forKey:@"groop_name"];
    [params setObject:first forKey:@"friend_1"];
    [params setObject:second forKey:@"friend_2"];
    [params setObject:third forKey:@"friend_3"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/create/groop" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        } else {
            block(success,res);
        }
    }];
}

- (void)getGroopsWithCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/get/groops/by/user" headers:headers params:params withResponse:^(BOOL success, id res) {
        
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

- (void)getGroopviewsWithCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/get/groopviews/by/user" headers:headers params:params withResponse:^(BOOL success, id res) {
        
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

- (void)removeGroopWithId:(NSString *)groopId
           withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groopId forKey:@"groop_id"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/remove/groop" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

- (void)removeGroopviewWithId:(NSString *)groopviewId
               withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groopviewId forKey:@"groopview_id"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/remove/groopview" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

- (void)updateGroopWithId:(NSString *)groopId
                     name:(NSString *)name
                  friend1:(NSString *)friend1
                  friend2:(NSString *)friend2
                  friend3:(NSString *)friend3
           withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groopId forKey:@"groop_id"];
    [params setObject:name forKey:@"groop_name"];
    [params setObject:friend1 forKey:@"friend_1"];
    [params setObject:friend2 forKey:@"friend_2"];
    [params setObject:friend3 forKey:@"friend_3"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/update/groop" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

- (void)updateGroopviewWithId:(NSString *)groopviewId
                     groopId:(NSString *)groopId
                     videoURL:(NSString *)videoURL
                   videoThumb:(NSString *)videoThumb
                    isJoinNow:(BOOL)isJoinNow
                     joinTime:(NSString *)joinTime
                      friend1:(NSString *)friend1
                      friend2:(NSString *)friend2
                      friend3:(NSString *)friend3
               withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groopviewId forKey:@"groopview_id"];
    [params setObject:groopId     forKey:@"groop_id"];
    [params setObject:videoURL    forKey:@"video_url"];
    [params setObject:videoThumb  forKey:@"video_thumb"];
    [params setObject:(isJoinNow? @"1": @"0") forKey:@"is_join_now"];
    [params setObject:joinTime    forKey:@"join_time"];
    [params setObject:friend1     forKey:@"friend_1"];
    [params setObject:friend2     forKey:@"friend_2"];
    [params setObject:friend3     forKey:@"friend_3"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/update/groopview" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

- (void)createGroopviewByGroopId:(NSString *)groopId
                         friend1:(NSString *)friend1
                         friend2:(NSString *)friend2
                         friend3:(NSString *)friend3
                        joinTime:(NSString *)joinTime // Timestamp
                        rightNow:(BOOL)rightNow // "1", "0"
                        videoURL:(NSString *)videoURL
                      videoTitle:(NSString *)videoTitle
                  videoThumbnail:(NSString *)videoThumbnail
                  withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groopId                forKey:@"groop_id"];
    [params setObject:friend1                forKey:@"friend_1"];
    [params setObject:friend2                forKey:@"friend_2"];
    [params setObject:friend3                forKey:@"friend_3"];
    [params setObject:joinTime               forKey:@"join_time"];
    [params setObject:(rightNow? @"1": @"0") forKey:@"is_join_now"];
    [params setObject:videoURL               forKey:@"video_url"];
    [params setObject:videoTitle             forKey:@"video_title"];
    [params setObject:videoThumbnail         forKey:@"video_thumbnail"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/create/groopview" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success,dict);
        }
        else {
            block(success,res);
        }
    }];
}

#pragma mark - Notifications

- (void)getUserNotificationsWithCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/get/user/notifications" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}

- (void)removeUserNotificationById:(NSString *)notificationId
                    withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:notificationId forKey:@"notification_id"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/remove/user/notification" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}

- (void)readUserNotificationById:(NSString *)notificationId
                  withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:notificationId forKey:@"notification_id"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/read/user/notification" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}

- (void)acceptInvitationForGroopview:(NSString *)groopviewId
                         phoneNumber:(NSString *)phoneNumber
                      withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groopviewId forKey:@"groopview_id"];
    [params setObject:phoneNumber forKey:@"phone_number"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/accept/groopview/invitation" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}

- (void)declineInvitationForGroopview:(NSString *)groopviewId
                          phoneNumber:(NSString *)phoneNumber
                       withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groopviewId forKey:@"groopview_id"];
    [params setObject:phoneNumber forKey:@"phone_number"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/decline/groopview/invitation" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}

- (void)getGroopviewById:(NSString *)groopId
          withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groopId forKey:@"groopview_id"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/get/groopview/single" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}

- (void)getTwilioAccessTokenByGroopviewId:(NSString *)groopviewId
                           withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:groopviewId forKey:@"groopview_id"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/join/groopview" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}

#pragma mark - Location Tracking

- (void)updateLocationWithLatitude:(NSString *)latitude
                         longitude:(NSString *)longitude
                    withCompletion:(void(^)(BOOL success, id res))block {
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:GV_CONTENT_TYPE forKey:GV_ACCEPT_TYPE];
    [headers setObject:[[GVGlobal shared] authorization] forKey:GV_AUTHORIZATION];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:latitude  forKey:@"latitude"];
    [params setObject:longitude forKey:@"longitude"];
    
    [self requestPostURL:GV_BASE_URL atPath:@"/api/v1/update/latitude/longitude" headers:headers params:params withResponse:^(BOOL success, id res) {
        if (success) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:res options:0 error:nil];
            block(success, dict);
        }
        else {
            block(success, res);
        }
    }];
}


@end
