//
//  GVNotification.h
//  sdkm
//
//  Created by Mobile on 18.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NT_INVITATION = 401,
    NT_ACCEPTED,
    NT_DECLINED,
    NT_JOIN_ALERT,
    NT_OTHER
} GVNotificationType;

//NS_ASSUME_NONNULL_BEGIN

@interface GVNotification : NSObject

@property (strong, nonatomic) NSString *notificationId;
@property GVNotificationType notificationType;
@property (strong, nonatomic) NSString *notificationText;
@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) NSString *groopviewId;
@property (strong, nonatomic) NSString *adminName;
@property (strong, nonatomic) NSString *notificationTime;
@property BOOL isAdmin;
@property BOOL isRightNow;
@property BOOL isRead;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (GVNotificationType)getNotificationTypeFrom:(NSString *)str;

+ (NSString *)getStringFromNotificationType:(GVNotificationType)notificationType;

@end

//NS_ASSUME_NONNULL_END
