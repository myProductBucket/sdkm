//
//  GVUser.m
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import "GVUser.h"

@implementation GVUser

- (void)createUserName {
    if (self.firstName.length > 0
        && self.lastName.length > 0) {
        self.userName = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
    else if (self.firstName.length > 0) {
        self.userName = self.firstName;
    }
    else if (self.lastName.length > 0) {
        self.userName = self.lastName;
    }
    else {
        self.userName = @"Unknown";
    }
}

- (void)createShortName {
    if (![GVGlobal isNull:self.firstName]
        && ![GVGlobal isNull:self.lastName]) {
        if (self.firstName.length > 0
            && self.lastName.length > 0) {
            self.shortName = [[NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]] uppercaseString];
        }
        else if (self.firstName.length > 0) {
            if (self.firstName.length > 1)
                self.shortName = [[self.firstName substringToIndex:2] uppercaseString];
            else
                self.shortName = [self.firstName uppercaseString];
        }
        else if (self.lastName.length > 0) {
            if (self.lastName.length > 1)
                self.shortName = [[self.lastName substringToIndex:2] uppercaseString];
            else
                self.shortName = [self.lastName uppercaseString];
        }
    }
    else if (![GVGlobal isNull:self.firstName]) {
        if (self.firstName.length > 1)
            self.shortName = [[self.firstName substringToIndex:2] uppercaseString];
        else if (self.firstName.length == 1)
            self.shortName = [self.firstName uppercaseString];
    }
    else if (![GVGlobal isNull:self.lastName]) {
        if (self.lastName.length > 1)
            self.shortName = [[self.lastName substringToIndex:2] uppercaseString];
        else if (self.lastName.length == 1)
            self.shortName = [self.lastName uppercaseString];
    }
    
    if ([GVGlobal isNull:self.shortName]
        || self.shortName.length == 0) {
        [self setShortName:@"..."];
    }
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.userName forKey:@"userID"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [encoder encodeObject:self.countryCode forKey:@"countryCode"];
    [encoder encodeObject:self.avatar forKey:@"avatar"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars];
        self.email            = [decoder decodeObjectForKey:@"email"];
        self.userName         = [decoder decodeObjectForKey:@"userName"];
        self.firstName        = [decoder decodeObjectForKey:@"firstName"];
        self.lastName         = [decoder decodeObjectForKey:@"lastName"];
        self.phoneNumber      = [decoder decodeObjectForKey:@"phoneNumber"];
        self.countryCode      = [decoder decodeObjectForKey:@"countryCode"];
        self.avatar           = [decoder decodeObjectForKey:@"avatar"];
    }
    return self;
}

- (void)save:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
}

+ (instancetype)loadUser:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    GVUser *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}

@end
