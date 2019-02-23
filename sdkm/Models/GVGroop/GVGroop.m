//
//  GVGroop.m
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVGroop.h"

@implementation GVGroop

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.groopId = [GVGlobal isNull:dict[@"id"]]? nil: [NSString stringWithFormat:@"%@", dict[@"id"]];
        self.groopName = [GVGlobal isNull:dict[@"groop_name"]]? nil: dict[@"groop_name"];
        self.joinTime = [GVGlobal isNull:dict[@"join_time"]]? nil: dict[@"join_time"];
        self.adminId = [GVGlobal isNull:dict[@"admin_id"]]? ([GVGlobal isNull:dict[@"user_id"]]? nil: [NSString stringWithFormat:@"%@", dict[@"user_id"]]): [NSString stringWithFormat:@"%@", dict[@"admin_id"]];
        
        if (![GVGlobal isNull:dict[@"admin_name"]]) {
            self.adminName = dict[@"admin_name"];
        }
        else if (![GVGlobal isNull:dict[@"admin_first_name"]]) {
            self.adminName = dict[@"admin_first_name"];
        }
        else {
            self.adminName = nil;
        }
        
        if (![GVGlobal isNull:dict[@"admin_number"]]) {
            self.adminPhone = dict[@"admin_number"];
        }
        else {
            self.adminPhone = nil;
        }
        
        self.adminAvatarURL = [GVGlobal isNull:dict[@"admin_avatar_url"]]? nil: dict[@"admin_avatar_url"];
        self.adminAvatarURL = [self.adminAvatarURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        
        self.videoTitle = [GVGlobal isNull:dict[@"video_title"]]? nil: [NSString stringWithFormat:@"%@", dict[@"video_title"]];
        self.videoURL = [GVGlobal isNull:dict[@"video_url"]]? nil: [NSString stringWithFormat:@"%@", dict[@"video_url"]];
        self.videoThumbnail = [GVGlobal isNull:dict[@"video_thumbnail"]]? nil: [NSString stringWithFormat:@"%@", dict[@"video_thumbnail"]];
        
        self.isRightNow = [GVGlobal isNull:dict[@"is_join_now"]]? NO: [dict[@"is_join_now"] boolValue];
        self.isAdmin = [GVGlobal isNull:dict[@"is_admin"]]? NO: [dict[@"is_admin"] boolValue];
        
        self.numberOfParticipants = 0;
        self.members = [[NSMutableArray alloc] init];
        [self addParticipant:[[GVParticipant alloc] initWithDictionary:dict[@"members"][@"friend_1"] prefix:@"friend_1"]];
        [self addParticipant:[[GVParticipant alloc] initWithDictionary:dict[@"members"][@"friend_2"] prefix:@"friend_2"]];
        [self addParticipant:[[GVParticipant alloc] initWithDictionary:dict[@"members"][@"friend_3"] prefix:@"friend_3"]];
        self.numberOfParticipants++;
    }
    return self;
}

- (void)addParticipant:(GVParticipant *)participant {
    if (participant.countryCode.length > 0
        && participant.phoneNumber.length > 0) {
        self.numberOfParticipants++;
    }
    [self.members addObject:participant];
}

@end
