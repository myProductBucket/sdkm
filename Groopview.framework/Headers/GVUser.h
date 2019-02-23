//
//  GVUser.h
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface GVUser : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *avatar;
@property NSInteger countOfUnreadNotifications;

@property Boolean isAdded; // Used for Contact Management
@property Boolean isGroopview; // Used if Groopview user or not
@property Boolean isInvited; // Used if the contact was invited or not

@property (strong, nonatomic) NSString *shortName;

- (void)createShortName;

- (void)save:(NSString *)key;

+ (instancetype)loadUser:(NSString *)key;

@end

//NS_ASSUME_NONNULL_END
