//
//  GVNotification.m
//  sdkm
//
//  Created by Mobile on 18.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVNotification.h"

@implementation GVNotification

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        self.notificationId = dict[@"id"]? dict[@"id"]: @"";
        self.notificationType = dict[@"notification_type"]? [GVNotification getNotificationTypeFrom:dict[@"notification_type"]]: NT_OTHER;
        self.notificationText = dict[@"notification"]? dict[@"notification"]: @"";
        self.deviceToken = dict[@"device_token"]? dict[@"device_token"]: @"";
        self.isAdmin = (dict[@"is_admin"] && [dict[@"is_admin"] integerValue] == 1)? YES: NO;
        self.isRightNow = (dict[@"right_now"] && [dict[@"right_now"] integerValue] == 1)? YES: NO;
        self.isRead = (dict[@"is_read"] && [dict[@"is_read"] integerValue] == 1)? YES: NO;
        self.groopviewId = dict[@"groopview_id"]? dict[@"groopview_id"]: nil;
        
        if (dict[@"notification_time"]) {
            NSTimeInterval timeInterval = [dict[@"notification_time"] doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"hh:mm aa"];
            self.notificationTime = [formatter stringFromDate:date];
        }
    }
    return self;
}

+ (GVNotificationType)getNotificationTypeFrom:(NSString *)str {
    if ([[GVNotification getStringFromNotificationType:NT_INVITATION] isEqualToString:str]) {
        return NT_INVITATION;
    }
    else if ([[GVNotification getStringFromNotificationType:NT_ACCEPTED] isEqualToString:str]) {
        return NT_ACCEPTED;
    }
    else if ([[GVNotification getStringFromNotificationType:NT_DECLINED] isEqualToString:str]) {
        return NT_DECLINED;
    }
    else if ([[GVNotification getStringFromNotificationType:NT_JOIN_ALERT] isEqualToString:str]) {
        return NT_JOIN_ALERT;
    } else {
        return NT_OTHER;
    }
}

+ (NSString *)getStringFromNotificationType:(GVNotificationType)notificationType {
    NSString *str;
    switch (notificationType) {
        case NT_INVITATION:
            str = @"invitation";
            break;
        case NT_ACCEPTED:
            str = @"invitation_accepted";
            break;
        case NT_DECLINED:
            str = @"invitation_declined";
            break;
        case NT_JOIN_ALERT:
            str = @"alert";
            break;
        default:
            break;
    }
    return str;
}

@end
