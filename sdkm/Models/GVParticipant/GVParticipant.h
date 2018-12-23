//
//  GVParticipant.h
//  sdkm
//
//  Created by Mobile on 17.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface GVParticipant : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *countryCode;
@property BOOL isAccepted;
@property BOOL isReplied;

- (instancetype)initWithDictionary:(NSDictionary *)dict
                            prefix:(NSString *)prefix;

@end

//NS_ASSUME_NONNULL_END
