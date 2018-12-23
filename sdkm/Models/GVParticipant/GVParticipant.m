//
//  GVParticipant.m
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVParticipant.h"

@implementation GVParticipant

- (instancetype)initWithDictionary:(NSDictionary *)dict
                            prefix:(NSString *)prefix {
    self = [super init];
    if (self) {
        if ([prefix isEqualToString:@"friend_1"]) {
            self.avatarURL = [GVGlobal isNull:dict[@"friend_1_avatar_url"]]? nil: dict[@"friend_1_avatar_url"];
            self.name = [GVGlobal isNull:dict[@"friend_1_first_name"]]? nil: dict[@"friend_1_first_name"];
            self.phoneNumber = [GVGlobal isNull:dict[@"friend_1_phone_number"]]? nil: dict[@"friend_1_phone_number"];
            self.countryCode = [GVGlobal isNull:dict[@"friend_1_country_code"]]? nil: dict[@"friend_1_country_code"];
            self.isAccepted = [GVGlobal isNull:dict[@"is_accepted_friend_1"]]? NO: [dict[@"is_accepted_friend_1"] boolValue];
            self.isReplied = [GVGlobal isNull:dict[@"is_responded_friend_1"]]? NO: [dict[@"is_responded_friend_1"] boolValue];
        }
        else if ([prefix isEqualToString:@"friend_2"]) {
            self.avatarURL = [GVGlobal isNull:dict[@"friend_2_avatar_url"]]? nil: dict[@"friend_2_avatar_url"];
            self.name = [GVGlobal isNull:dict[@"friend_2_first_name"]]? nil: dict[@"friend_2_first_name"];
            self.phoneNumber = [GVGlobal isNull:dict[@"friend_2_phone_number"]]? nil: dict[@"friend_2_phone_number"];
            self.countryCode = [GVGlobal isNull:dict[@"friend_2_country_code"]]? nil: dict[@"friend_2_country_code"];
            self.isAccepted = [GVGlobal isNull:dict[@"is_accepted_friend_2"]]? NO: [dict[@"is_accepted_friend_2"] boolValue];
            self.isReplied = [GVGlobal isNull:dict[@"is_respond_friend_2"]]? NO: [dict[@"is_respond_friend_2"] boolValue];
        }
        else if ([prefix isEqualToString:@"friend_3"]) {
            self.avatarURL = [GVGlobal isNull:dict[@"friend_3_avatar_url"]]? nil: dict[@"friend_3_avatar_url"];
            self.name = [GVGlobal isNull:dict[@"friend_3_first_name"]]? nil: dict[@"friend_3_first_name"];
            self.phoneNumber = [GVGlobal isNull:dict[@"friend_3_phone_number"]]? nil: dict[@"friend_3_phone_number"];
            self.countryCode = [GVGlobal isNull:dict[@"friend_number_3_code"]]? nil: dict[@"friend_number_3_code"];
            self.isAccepted = [GVGlobal isNull:dict[@"is_accepted_friend_3"]]? NO: [dict[@"is_accepted_friend_3"] boolValue];
            self.isReplied = [GVGlobal isNull:dict[@"is_responded_friend_3"]]? NO: [dict[@"is_responded_friend_3"] boolValue];
        }
    }
    return self;
}

@end
