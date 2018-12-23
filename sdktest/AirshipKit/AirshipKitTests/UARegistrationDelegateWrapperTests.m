/* Copyright 2018 Urban Airship and Contributors */

#import <UIKit/UIKit.h>
#import "UABaseTest.h"
#import "UARegistrationDelegateWrapper+Internal.h"

@interface UARegistrationDelegateWrapperTests : UABaseTest
@property (nonatomic, strong) UARegistrationDelegateWrapper *wrapper;
@property (nonatomic, strong) id mockDelegate;
@end

@implementation UARegistrationDelegateWrapperTests

- (void)setUp {
    [super setUp];
    self.wrapper = [[UARegistrationDelegateWrapper alloc] init];
    self.mockDelegate = [self mockForProtocol:@protocol(UARegistrationDelegate)];
    self.wrapper.delegate = self.mockDelegate;
}

- (void)testChannelRegistrationSucceeded {
    [[self.mockDelegate expect] registrationSucceededForChannelID:@"some-channel" deviceToken:@"some-token"];
    [self.wrapper registrationSucceededForChannelID:@"some-channel" deviceToken:@"some-token"];
    [self.mockDelegate verify];
}

- (void)testRegistrationFailed {
    [[self.mockDelegate expect] registrationFailed];
    [self.wrapper registrationFailed];
    [self.mockDelegate verify];
}

- (void)testAPNSRegistrationSucceededWithDeviceToken {
    NSData *token = [@"some-token" dataUsingEncoding:NSUTF8StringEncoding];
    [[self.mockDelegate expect] apnsRegistrationSucceededWithDeviceToken:token];
    [self.wrapper apnsRegistrationSucceededWithDeviceToken:token];
    [self.mockDelegate verify];
}

- (void)testAPNSRegistrationFailedWithError {
    NSError *error = [[NSError alloc] init];
    [[self.mockDelegate expect] apnsRegistrationFailedWithError:error];
    [self.wrapper apnsRegistrationFailedWithError:error];
    [self.mockDelegate verify];
}

- (void)testNotificationRegistrationFinished {
    UANotificationCategory *category = [UANotificationCategory categoryWithIdentifier:@"cool" actions:@[] intentIdentifiers:@[] options:0];
    NSSet *categories = [NSSet setWithArray:@[category]];

    UAAuthorizedNotificationSettings authorizedSettings = UAAuthorizedNotificationSettingsAlert | UAAuthorizedNotificationSettingsBadge;
    UANotificationOptions legacyOptions = UANotificationOptionAlert;
    UAAuthorizationStatus status = UAAuthorizationStatusProvisional;

    XCTestExpectation *withoutStatus = [self expectationWithDescription:@"notificationRegistrationFinishedWithAuthorizedSettings:categories:"];
    [[[self.mockDelegate expect] andDo:^(NSInvocation *invocation) {
        [withoutStatus fulfill];
    }] notificationRegistrationFinishedWithAuthorizedSettings:authorizedSettings categories:categories];

    XCTestExpectation *withStatus = [self expectationWithDescription:@"notificationRegistrationFinishedWithAuthorizedSettings:categories:status:"];
    [[[self.mockDelegate expect] andDo:^(NSInvocation *invocation) {
        [withStatus fulfill];
    }] notificationRegistrationFinishedWithAuthorizedSettings:authorizedSettings categories:categories status:status];

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    XCTestExpectation *deprecated = [self expectationWithDescription:@"notificationRegistrationFinishedWithOptions:categories:"];
    [[[self.mockDelegate expect] andDo:^(NSInvocation *invocation) {
        [deprecated fulfill];
    }] notificationRegistrationFinishedWithOptions:legacyOptions categories:categories];
#pragma GCC diagnostic pop

    [self.wrapper notificationRegistrationFinishedWithAuthorizedSettings:authorizedSettings legacyOptions:legacyOptions categories:categories status:status];

    [self waitForExpectationsWithTimeout:5 handler:nil];
    [self.mockDelegate verify];
}

- (void)testAuthorizedSettingsDidChange {
    UAAuthorizedNotificationSettings authorizedSettings = UAAuthorizedNotificationSettingsAlert | UAAuthorizedNotificationSettingsBadge;
    UANotificationOptions legacyOptions = UANotificationOptionAlert;

    [[self.mockDelegate expect] notificationAuthorizedSettingsDidChange:authorizedSettings];

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    [[self.mockDelegate expect] notificationAuthorizedOptionsDidChange:legacyOptions];
#pragma GCC diagnostic pop

    [self.wrapper notificationAuthorizedSettingsDidChange:authorizedSettings legacyOptions:legacyOptions];
}

@end
