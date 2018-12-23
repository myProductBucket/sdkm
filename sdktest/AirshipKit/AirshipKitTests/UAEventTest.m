/* Copyright 2018 Urban Airship and Contributors */

#import "UABaseTest.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "UAPush+Internal.h"
#import "UAUser+Internal.h"
#import "UAEvent+Internal.h"
#import "UAirship+Internal.h"
#import "UAAnalytics.h"
#import "UAAppInitEvent+Internal.h"
#import "UAAppExitEvent+Internal.h"
#import "UAAppBackgroundEvent+Internal.h"
#import "UAAppForegroundEvent+Internal.h"
#import "UADeviceRegistrationEvent+Internal.h"
#import "UAPushReceivedEvent+Internal.h"
#import "UAUtils+Internal.h"



@interface UAEventTest : UABaseTest

// stubs
@property (nonatomic, strong) id analytics;
@property (nonatomic, strong) id airship;
@property (nonatomic, strong) id reachability;
@property (nonatomic, strong) id timeZone;
@property (nonatomic, strong) id airshipVersion;
@property (nonatomic, strong) id application;
@property (nonatomic, strong) id push;
@property (nonatomic, strong) id currentDevice;
@property (nonatomic, strong) id user;
@property (nonatomic, strong) id utils;

@end

@implementation UAEventTest

- (void)setUp {
    [super setUp];

    self.analytics = [self mockForClass:[UAAnalytics class]];
    self.push = [self mockForClass:[UAPush class]];
    self.user = [self mockForClass:[UAUser class]];

    self.airship = [self mockForClass:[UAirship class]];

    [[[self.airship stub] andReturn:self.analytics] sharedAnalytics];
    [[[self.airship stub] andReturn:self.push] push];
    [[[self.airship stub] andReturn:self.user] inboxUser];

    [UAirship setSharedAirship:self.airship];

    self.utils = [self mockForClass:[UAUtils class]];

    self.timeZone = [self mockForClass:[NSTimeZone class]];
    [[[self.timeZone stub] andReturn:self.timeZone] defaultTimeZone];

    self.airshipVersion = [self mockForClass:[UAirshipVersion class]];

    self.application = [self mockForClass:[UIApplication class]];
    [[[self.application stub] andReturn:self.application] sharedApplication];

    self.currentDevice = [self mockForClass:[UIDevice class]];
    [[[self.currentDevice stub] andReturn:self.currentDevice] currentDevice];
}

- (void)tearDown {
    [self.analytics stopMocking];
    [self.airship stopMocking];
    [self.timeZone stopMocking];
    [self.airshipVersion stopMocking];
    [self.application stopMocking];
    [self.push stopMocking];
    [self.currentDevice stopMocking];
    [self.utils stopMocking];

    [super tearDown];
}

/**
 * Test app init event
 */
- (void)testAppInitEvent {
    [[[self.user stub] andReturn:@"user ID"] username];

    [[[self.analytics stub] andReturn:@"push ID"] conversionSendID];
    [[[self.analytics stub] andReturn:@"base64metadataString"] conversionPushMetadata];
    [[[self.analytics stub] andReturn:@"rich push ID"] conversionRichPushID];

    [[[self.timeZone stub] andReturnValue:OCMOCK_VALUE((NSInteger)2000)] secondsFromGMT];

    [[[self.timeZone stub] andReturnValue:OCMOCK_VALUE(YES)] isDaylightSavingTime];

    [(UIDevice *)[[self.currentDevice stub] andReturn:@"os version"]systemVersion];

    [[[self.airshipVersion stub] andReturn:@"airship version"] get];

    [[[self.application stub] andReturnValue:OCMOCK_VALUE(UIApplicationStateActive)] applicationState];

    [[[self.utils stub] andReturnValue:OCMOCK_VALUE(kUAConnectionTypeCell)] connectionType];

    [[[self.push stub] andReturnValue:OCMOCK_VALUE(UAAuthorizationStatusNotDetermined)] authorizationStatus];

    NSDictionary *expectedData = @{@"user_id": @"user ID",
                                   @"connection_type": @"cell",
                                   @"push_id": @"push ID",
                                   @"metadata": @"base64metadataString",
                                   @"rich_push_id": @"rich push ID",
                                   @"time_zone": @2000,
                                   @"daylight_savings": @"true",
                                   @"notification_types": @[],
                                   @"notification_authorization": @"not_determined",
                                   @"os_version": @"os version",
                                   @"lib_version": @"airship version",
                                   @"package_version": @"",
                                   @"foreground": @"true"};


    UAAppInitEvent *event = [UAAppInitEvent event];

    XCTAssertEqualObjects(event.data, expectedData, @"Event data is unexpected.");
    XCTAssertEqualObjects(event.eventType, @"app_init", @"Event type is unexpected.");
    XCTAssertNotNil(event.eventID, @"Event should have an ID");

}

/**
 * Test app foreground event
 */
- (void)testAppForegroundEvent {
    [[[self.user stub] andReturn:@"user ID"] username];
    [[[self.analytics stub] andReturn:@"push ID"] conversionSendID];
    [[[self.analytics stub] andReturn:@"base64metadataString"] conversionPushMetadata];
    [[[self.analytics stub] andReturn:@"rich push ID"] conversionRichPushID];

    [[[self.timeZone stub] andReturnValue:OCMOCK_VALUE((NSInteger)2000)] secondsFromGMT];
    [[[self.timeZone stub] andReturnValue:OCMOCK_VALUE(YES)] isDaylightSavingTime];

    [[[self.utils stub] andReturnValue:OCMOCK_VALUE(kUAConnectionTypeCell)] connectionType];

    [(UIDevice *)[[self.currentDevice stub] andReturn:@"os version"]systemVersion];

    [[[self.airshipVersion stub] andReturn:@"airship version"] get];

    [[[self.push stub] andReturnValue:OCMOCK_VALUE(UAAuthorizationStatusProvisional)] authorizationStatus];

    // Same as app init but without the foreground key
    NSDictionary *expectedData = @{@"user_id": @"user ID",
                                   @"connection_type": @"cell",
                                   @"push_id": @"push ID",
                                   @"metadata": @"base64metadataString",
                                   @"rich_push_id": @"rich push ID",
                                   @"time_zone": @2000,
                                   @"daylight_savings": @"true",
                                   @"notification_types": @[],
                                   @"notification_authorization": @"provisional",
                                   @"os_version": @"os version",
                                   @"lib_version": @"airship version",
                                   @"package_version": @""};


    UAAppForegroundEvent *event = [UAAppForegroundEvent event];

    XCTAssertEqualObjects(event.data, expectedData, @"Event data is unexpected.");
    XCTAssertEqualObjects(event.eventType, @"app_foreground", @"Event type is unexpected.");
    XCTAssertNotNil(event.eventID, @"Event should have an ID");

}

/**
 * Test app exit event
 */
- (void)testAppExitEvent {

    [[[self.analytics stub] andReturn:@"push ID"] conversionSendID];
    [[[self.analytics stub] andReturn:@"base64metadataString"] conversionPushMetadata];
    [[[self.analytics stub] andReturn:@"rich push ID"] conversionRichPushID];

    [[[self.utils stub] andReturnValue:OCMOCK_VALUE(kUAConnectionTypeCell)] connectionType];
    
    NSDictionary *expectedData = @{@"connection_type": @"cell",
                                   @"push_id": @"push ID",
                                   @"metadata": @"base64metadataString",
                                   @"rich_push_id": @"rich push ID"};

    UAAppExitEvent *event = [UAAppExitEvent event];
    XCTAssertEqualObjects(event.data, expectedData, @"Event data is unexpected.");
    XCTAssertEqualObjects(event.eventType, @"app_exit", @"Event type is unexpected.");
    XCTAssertNotNil(event.eventID, @"Event should have an ID");
}

/**
 * Test app background event
 */
- (void)UAAppBackgroundEvent {
    NSDictionary *expectedData = @{@"class_name": @""};

    UAAppBackgroundEvent *event = [UAAppBackgroundEvent event];
    XCTAssertEqualObjects(event.data, expectedData, @"Event data is unexpected.");
    XCTAssertEqualObjects(event.eventType, @"app_background", @"Event type is unexpected.");
    XCTAssertNotNil(event.eventID, @"Event should have an ID");
}

/**
 * Test device registration event when pushTokenRegistrationEnabled is YES.
 */
- (void)testRegistrationEvent {
    [[[self.push stub] andReturnValue:@YES] pushTokenRegistrationEnabled];
    [[[self.push stub] andReturn:@"a12312ad"] deviceToken];
    [[[self.push stub] andReturn:@"someChannelID"] channelID];
    [[[self.user stub] andReturn:@"someUserID"] username];

    NSDictionary *expectedData = @{@"device_token": @"a12312ad",
                                   @"channel_id": @"someChannelID",
                                   @"user_id": @"someUserID"};

    UADeviceRegistrationEvent *event = [UADeviceRegistrationEvent event];
    XCTAssertEqualObjects(event.data, expectedData, @"Event data is unexpected.");
    XCTAssertEqualObjects(event.eventType, @"device_registration", @"Event type is unexpected.");
    XCTAssertNotNil(event.eventID, @"Event should have an ID");
}

/**
 * Test device registration event when pushTokenRegistrationEnabled is NO.
 */
- (void)testRegistrationEventPushTokenRegistrationEnabledNo {
    [[[self.push stub] andReturnValue:@NO] pushTokenRegistrationEnabled];
    [[[self.push stub] andReturn:@"a12312ad"] deviceToken];
    [[[self.push stub] andReturn:@"someChannelID"] channelID];
    [[[self.user stub] andReturn:@"someUserID"] username];

    NSDictionary *expectedData = @{@"channel_id": @"someChannelID",
                                   @"user_id": @"someUserID"};

    UADeviceRegistrationEvent *event = [UADeviceRegistrationEvent event];
    XCTAssertEqualObjects(event.data, expectedData, @"Event data is unexpected.");
    XCTAssertEqualObjects(event.eventType, @"device_registration", @"Event type is unexpected.");
    XCTAssertNotNil(event.eventID, @"Event should have an ID");
}

/**
 * Test push received event
 */
- (void)testPushReceivedEvent {
    id notification = @{ @"_": @"push ID",
                         @"_uamid": @"rich push ID",
                         @"com.urbanairship.metadata": @"base64metadataString"};


    NSDictionary *expectedData = @{@"rich_push_id": @"rich push ID",
                                   @"push_id": @"push ID",
                                   @"metadata": @"base64metadataString"};

    UAPushReceivedEvent *event = [UAPushReceivedEvent eventWithNotification:notification];
    XCTAssertEqualObjects(event.data, expectedData, @"Event data is unexpected.");
    XCTAssertEqualObjects(event.eventType, @"push_received", @"Event type is unexpected.");
    XCTAssertNotNil(event.eventID, @"Event should have an ID");
}

/**
 * Test push received event without a push ID will send "MISSING_SEND_ID".
 */
- (void)testPushReceivedEventNoPushID {
    id notification = @{ @"_uamid": @"rich push ID" };


    NSDictionary *expectedData = @{@"rich_push_id": @"rich push ID",
                                   @"push_id": @"MISSING_SEND_ID"};

    UAPushReceivedEvent *event = [UAPushReceivedEvent eventWithNotification:notification];
    XCTAssertEqualObjects(event.data, expectedData, @"Event data is unexpected.");
    XCTAssertEqualObjects(event.eventType, @"push_received", @"Event type is unexpected.");
    XCTAssertNotNil(event.eventID, @"Event should have an ID");
}

/**
 * Test authorization status
 */
- (void)testAuthorizationStatus {
    UAEvent *event = [[UAEvent alloc] init];
    
    __block UAAuthorizationStatus status;
    [[[self.push stub] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:(void *)&status];
    }] authorizationStatus];

    status = UAAuthorizationStatusNotDetermined;
    XCTAssertEqualObjects(event.notificationAuthorization, @"not_determined");
    
    status = UAAuthorizationStatusDenied;
    XCTAssertEqualObjects(event.notificationAuthorization, @"denied");
    
    status = UAAuthorizationStatusAuthorized;
    XCTAssertEqualObjects(event.notificationAuthorization, @"authorized");
    
    status = UAAuthorizationStatusProvisional;
    XCTAssertEqualObjects(event.notificationAuthorization, @"provisional");
    
    // this tests that the next enum value returns "unknown". If an enum value is added
    // without updating [UAEvent notificationAuthorization] and this test, the test will fail.
    NSArray<NSNumber *> *allStatus = [NSArray arrayWithObjects:
                                                 [NSNumber numberWithInteger:UAAuthorizationStatusNotDetermined],
                                                 [NSNumber numberWithInteger:UAAuthorizationStatusDenied],
                                                 [NSNumber numberWithInteger:UAAuthorizationStatusAuthorized],
                                                 [NSNumber numberWithInteger:UAAuthorizationStatusProvisional],
                                                 nil];
    status = (UAAuthorizationStatus)([[allStatus valueForKeyPath:@"@max.self"] integerValue] + 1);
    XCTAssertEqualObjects(event.notificationAuthorization, @"not_determined");
}

@end
