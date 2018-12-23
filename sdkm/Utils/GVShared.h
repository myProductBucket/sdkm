//
//  GVShared.h
//  sdkm
//
//  Created by Mobile on 16.12.18.
//  Copyright © 2018 BMA. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface GVShared : NSObject

@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *clientSecret;
@property (strong, nonatomic) GVUser *userInfo;
@property (strong, nonatomic) UIColor *themeColor;

@property UIInterfaceOrientationMask lockOrientation;

@property (strong, nonatomic) NSMutableDictionary *createGroopviewInfo;
@property (strong, nonatomic) UIViewController *chooseVideoController;

+ (instancetype)shared;

#pragma mark -

+ (NSBundle *)getBundle;

+ (UIStoryboard *)getStoryboard;

#pragma mark - Session

- (NSString *)clientKeys;

#pragma mark - Screen Orientation

+ (void)lockScreen:(UIInterfaceOrientationMask)orientationMask andRotateTo:(UIInterfaceOrientation)orientation;

#pragma mark - Present View Controllers

+ (void)presentMyGroops:(UIViewController *)from;

+ (void)presentUpcomingGroopviews:(UIViewController *)from;

+ (void)presentGroopviewStart:(UIViewController *)from;

+ (void)presentSetTime:(UIViewController *)from;

@end

//NS_ASSUME_NONNULL_END

#define PREF_CURRENT_USER @"current_user"
#define PREF_UA_TOKEN @"urbanairship_token" // UrbanAirship Device Token

// TODO: 11/27/2018 Create Groopview Info Keys
#define GV_GROOP_ID        @"groop_id"
#define GV_VIDEO_URL       @"video_url"
#define GV_VIDEO_TITLE     @"video_title"
#define GV_VIDEO_THUMBNAIL @"video_thumbnail"
#define GV_FIRST_PHONE     @"first"
#define GV_FIRST_CODE      @"first_code"
#define GV_SECOND_PHONE    @"second"
#define GV_SECOND_CODE     @"second_code"
#define GV_THIRD_PHONE     @"third"
#define GV_THIRD_CODE      @"third_code"
