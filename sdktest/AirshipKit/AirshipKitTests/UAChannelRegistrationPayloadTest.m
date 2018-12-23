/* Copyright 2018 Urban Airship and Contributors */

#import "UABaseTest.h"
#import "UAChannelRegistrationPayload+Internal.h"
#import "NSJSONSerialization+UAAdditions.h"
#import "UAPush+Internal.h"
#import "UAChannelRegistrationPayload+Internal.h"
#import "UAAnalytics.h"

@interface UAChannelRegistrationPayloadTest : UABaseTest
@property (nonatomic, strong) UAChannelRegistrationPayload *payload;

@property (nonatomic, strong) id mockAirship;
@property (nonatomic, strong) id mockAnalytics;

@end

@implementation UAChannelRegistrationPayloadTest

- (void)setUp {
    [super setUp];

    NSDictionary *quietTime = [self buildQuietTimeWithStartDate:[NSDate dateWithTimeIntervalSince1970:30]
                                                    withEndDate:[NSDate dateWithTimeIntervalSince1970:100]];

    self.mockAnalytics = [self mockForClass:[UAAnalytics class]];

    self.mockAirship =[self mockForClass:[UAirship class]];
    [[[self.mockAirship stub] andReturn:self.mockAirship] shared];
    [[[self.mockAirship stub] andReturn:self.mockAnalytics] analytics];

    self.payload = [[UAChannelRegistrationPayload alloc] init];

    // set up the full payload
    self.payload.optedIn = YES;
    self.payload.backgroundEnabled = YES;
    self.payload.pushAddress = @"FAKEADDRESS";
    self.payload.userID = @"fakeUser";
    self.payload.deviceID = @"fakeDeviceID";
    self.payload.badge = [NSNumber numberWithInteger:1];
    self.payload.quietTime =  quietTime;
    self.payload.timeZone = @"timezone";
    self.payload.language = @"language";
    self.payload.country = @"country";
    self.payload.tags = @[@"tagOne", @"tagTwo"];
    self.payload.setTags = YES;
}

- (void)tearDown {
    [self.mockAirship stopMocking];
    [self.mockAnalytics stopMocking];
}

/**
 * Test that the json has the full expected payload
 */
- (void)testAsJsonFullPayload {
    [[[self.mockAnalytics stub] andReturnValue:OCMOCK_VALUE(YES)] isEnabled];

    NSString *jsonString = [[NSString alloc] initWithData:[self.payload asJSONData] encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization objectWithString:jsonString];

    // identity hints
    NSDictionary *identityHints = [dict valueForKey:UAChannelIdentityHintsKey];
    XCTAssertNotNil(identityHints, @"identity hints should be present");
    XCTAssertEqualObjects(self.payload.userID, [identityHints valueForKey:UAChannelUserIDKey], @"user ID should be present");
    XCTAssertEqualObjects(self.payload.deviceID, [identityHints valueForKey:UAChannelDeviceIDKey], @"device ID should be present");

    // channel specific items
    NSDictionary *channel = [dict valueForKey:UAChannelKey];
    XCTAssertEqualObjects(@"ios", [channel valueForKey:UAChannelDeviceTypeKey], @"device type should be present");
    XCTAssertEqualObjects([NSNumber numberWithBool:self.payload.optedIn], [channel valueForKey:UAChannelOptInKey], @"opt-in should be present");
    XCTAssertEqualObjects([NSNumber numberWithBool:self.payload.backgroundEnabled], [channel valueForKey:UABackgroundEnabledJSONKey], @"background should be present");
    XCTAssertEqualObjects(self.payload.pushAddress, [channel valueForKey:UAChannelPushAddressKey], @"push address should be present");
    XCTAssertEqualObjects([NSNumber numberWithBool:self.payload.setTags], [channel valueForKey:UAChannelSetTagsKey], @"set tags should be present");
    XCTAssertEqualObjects(self.payload.tags, [channel valueForKey:UAChannelTagsJSONKey], @"tags should be present");

    // channel specific items
    XCTAssertEqualObjects(@"timezone", [channel valueForKey:UAChannelTopLevelTimeZoneJSONKey], @"timezone key should be available in the channel dictionary");
    XCTAssertEqualObjects(@"language", [channel valueForKey:UAChannelTopLevelLanguageJSONKey], @"locale_language key should be available in the channel dictionary");
    XCTAssertEqualObjects(@"country", [channel valueForKey:UAChannelTopLevelCountryJSONKey], @"locale_country key should be available in the channel dictionary");

    // iOS specific items
    NSDictionary *ios = [channel valueForKey:UAChanneliOSKey];
    XCTAssertNotNil(ios, @"ios should be present");
    XCTAssertEqualObjects(self.payload.badge, [ios valueForKey:UAChannelBadgeJSONKey], @"badge should be present");
    XCTAssertEqualObjects(self.payload.quietTime, [ios valueForKey:UAChannelQuietTimeJSONKey], @"quiet time should be present");
    XCTAssertEqualObjects(self.payload.timeZone, [ios valueForKey:UAChannelTimeZoneJSONKey], @"timezone should be present");
}

/**
 * Tests that a payload initialized from data is equivalent to standard initialized payload
 */
- (void)testPayloadFromData {
    NSData *payloadData = [self.payload asJSONData];

    UAChannelRegistrationPayload *withData = [UAChannelRegistrationPayload channelRegistrationPayloadWithData:payloadData];
    XCTAssertTrue([withData isEqualToPayload:self.payload]);
}

/**
 * Test when tags are empty or nil
 */
- (void)testAsJsonEmptyTags {
    self.payload.tags = nil;

    NSString *jsonString = [[NSString alloc] initWithData:[self.payload asJSONData] encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization objectWithString:jsonString];
    NSDictionary *channel = [dict valueForKey:UAChannelKey];
    XCTAssertNil([channel valueForKey:UAChannelTagsJSONKey], @"tags should be nil");

    // Verify tags is not nil, but an empty nsarray
    self.payload.tags = @[];
    jsonString = [[NSString alloc] initWithData:[self.payload asJSONData] encoding:NSUTF8StringEncoding];
    dict = [NSJSONSerialization objectWithString:jsonString];
    channel = [dict valueForKey:UAChannelKey];
    XCTAssertEqualObjects(self.payload.tags, [channel valueForKey:UAChannelTagsJSONKey], @"tags should be nil");
}

/**
 * Test that tags are not sent when setTags is false
 */
- (void)testAsJsonNoTags {
    self.payload.setTags = NO;

    NSString *jsonString = [[NSString alloc] initWithData:[self.payload asJSONData] encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization objectWithString:jsonString];
    NSDictionary *channel = [dict valueForKey:UAChannelKey];

    // Verify that tags are not present when setTags is false
    jsonString = [[NSString alloc] initWithData:[self.payload asJSONData] encoding:NSUTF8StringEncoding];
    dict = [NSJSONSerialization objectWithString:jsonString];
    channel = [dict valueForKey:UAChannelKey];
    XCTAssertNil([channel valueForKey:UAChannelTagsJSONKey], @"tags should be nil");
}

/**
 * Test that an empty iOS section is not included
 */
- (void)testAsJsonEmptyiOSSection {
    self.payload.badge = nil;
    self.payload.quietTime = nil;
    self.payload.timeZone = nil;

    NSString *jsonString = [[NSString alloc] initWithData:[self.payload asJSONData] encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization objectWithString:jsonString];

    XCTAssertNil([dict valueForKey:UAChanneliOSKey], @"iOS section should not be included in the JSON");
}

/**
 * Test that an empty identity hints section is not included
 */
- (void)testAsJsonEmptyIdentityHints {
    self.payload.deviceID = nil;
    self.payload.userID = nil;

    NSString *jsonString = [[NSString alloc] initWithData:[self.payload asJSONData] encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization objectWithString:jsonString];

    XCTAssertNil([dict valueForKey:UAChannelIdentityHintsKey], @"identity hints section should not be included in the JSON");
}

/**
 * Test isEqualToPayload is equal to its copy
 */
- (void)testisEqualToPayloadCopy {
    UAChannelRegistrationPayload *payloadCopy = [self.payload copy];
    XCTAssertTrue([self.payload isEqualToPayload:payloadCopy], @"A copy should be equal to the original");

    payloadCopy.optedIn = NO;
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.optedIn = self.payload.optedIn;

    payloadCopy.backgroundEnabled = NO;
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.backgroundEnabled = self.payload.backgroundEnabled;

    payloadCopy.pushAddress = @"different-value";
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.pushAddress = self.payload.pushAddress;

    payloadCopy.userID = @"different-value";
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.userID = self.payload.userID;

    payloadCopy.deviceID = @"different-value";
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.deviceID = self.payload.deviceID;

    payloadCopy.badge = [NSNumber numberWithInteger:5];;
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.badge = self.payload.badge;

    payloadCopy.quietTime = [NSDictionary dictionary];
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.quietTime = self.payload.quietTime;

    payloadCopy.timeZone = @"different-value";
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.timeZone = self.payload.timeZone;

    payloadCopy.setTags = NO;
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.setTags = self.payload.setTags;

    payloadCopy.tags = @[@"tagThree", @"tagFour"];;
    XCTAssertFalse([self.payload isEqualToPayload:payloadCopy], @"A payload should not be equal after a modification");
    payloadCopy.tags = self.payload.tags;

    // Make sure its equal again
    XCTAssertTrue([self.payload isEqualToPayload:payloadCopy], @"A copy should be equal to the original");
}

/**
 * Test isEqualToPayload is equal to itself
 */
- (void)testisEqualToPayloadSelf {
    XCTAssertTrue([self.payload isEqualToPayload:self.payload], @"A payload should be equal to itself");
}

/**
 * Test isEqualToPayload is equal to an empty payload
 */
- (void)testisEqualToPayloadEmptyPayload {
    UAChannelRegistrationPayload *emptyPayload = [[UAChannelRegistrationPayload alloc] init];
    XCTAssertFalse([self.payload isEqualToPayload:emptyPayload], @"A payload should not be equal to a different payload");
}

/**
 * Test that payloadDictionary has the full expected payload
 */
- (void)testPayloadDictionaryFullPayload {
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.payload payloadDictionary]];

    // identity hints
    NSDictionary *identityHints = [dict valueForKey:UAChannelIdentityHintsKey];
    XCTAssertNotNil(identityHints, @"identity hints should be present");
    XCTAssertEqualObjects(self.payload.userID, [identityHints valueForKey:UAChannelUserIDKey], @"user ID should be present");
    XCTAssertEqualObjects(self.payload.deviceID, [identityHints valueForKey:UAChannelDeviceIDKey], @"device ID should be present");

    // channel specific items
    NSDictionary *channel = [dict valueForKey:UAChannelKey];
    XCTAssertEqualObjects(@"ios", [channel valueForKey:UAChannelDeviceTypeKey], @"device type should be present");
    XCTAssertEqualObjects([NSNumber numberWithBool:self.payload.optedIn], [channel valueForKey:UAChannelOptInKey], @"opt-in should be present");
    XCTAssertEqualObjects(self.payload.pushAddress, [channel valueForKey:UAChannelPushAddressKey], @"push address should be present");
    XCTAssertEqualObjects([NSNumber numberWithBool:self.payload.setTags], [channel valueForKey:UAChannelSetTagsKey], @"set tags should be present");
    XCTAssertEqualObjects(self.payload.tags, [channel valueForKey:UAChannelTagsJSONKey], @"tags should be present");

    // iOS specific items
    NSDictionary *ios = [channel valueForKey:UAChanneliOSKey];
    XCTAssertNotNil(ios, @"ios should be present");
    XCTAssertEqualObjects(self.payload.badge, [ios valueForKey:UAChannelBadgeJSONKey], @"badge should be present");
    XCTAssertEqualObjects(self.payload.quietTime, [ios valueForKey:UAChannelQuietTimeJSONKey], @"quiet time should be present");
    XCTAssertEqualObjects(self.payload.timeZone, [ios valueForKey:UAChannelTimeZoneJSONKey], @"timezone should be present");
}

/**
 * Test payloadDictionary when tags are empty or nil
 */
- (void)testPayloadDictionaryEmptyTags {
    self.payload.tags = nil;
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.payload payloadDictionary]];
    NSDictionary *channel = [dict valueForKey:UAChannelKey];
    XCTAssertNil([channel valueForKey:UAChannelTagsJSONKey], @"tags should be nil");

    // Verify tags is not nil, but an empty nsarray
    self.payload.tags = @[];
    dict = [[NSDictionary alloc] initWithDictionary:[self.payload payloadDictionary]];
    channel = [dict valueForKey:UAChannelKey];
    XCTAssertEqualObjects(self.payload.tags, [channel valueForKey:UAChannelTagsJSONKey], @"tags should be nil");
}

/**
 * Test that tags are not sent when setTags is false
 */
- (void)testPayloadDictionaryNoTags {
    self.payload.setTags = NO;

    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.payload payloadDictionary]];
    NSDictionary *channel = [dict valueForKey:UAChannelKey];

    channel = [dict valueForKey:UAChannelKey];
    XCTAssertNil([channel valueForKey:UAChannelTagsJSONKey], @"tags should be nil");
}

/**
 * Test that an empty iOS section is not included
 */
- (void)testPayloadDictionaryEmptyiOSSection {
    self.payload.badge = nil;
    self.payload.quietTime = nil;
    self.payload.timeZone = nil;

    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.payload payloadDictionary]];
    XCTAssertNil([dict valueForKey:UAChanneliOSKey], @"iOS section should not be included in the payload");
}

/**
 * Test that an empty identity hints section is not included
 */
- (void)testPayloadDictionaryEmptyIdentityHints {
    self.payload.deviceID = nil;
    self.payload.userID = nil;

    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.payload payloadDictionary]];
    XCTAssertNil([dict valueForKey:UAChannelIdentityHintsKey], @"identity hints section should not be included in the payload");
}

// Helpers
- (NSMutableDictionary *)buildQuietTimeWithStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate {

    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSString *fromStr = [NSString stringWithFormat:@"%ld:%02ld",
                         (long)[cal components:NSCalendarUnitHour fromDate:startDate].hour,
                         (long)[cal components:NSCalendarUnitMinute fromDate:startDate].minute];

    NSString *toStr = [NSString stringWithFormat:@"%ld:%02ld",
                       (long)[cal components:NSCalendarUnitHour fromDate:endDate].hour,
                       (long)[cal components:NSCalendarUnitMinute fromDate:endDate].minute];

    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            fromStr, UAPushQuietTimeStartKey,
            toStr, UAPushQuietTimeEndKey, nil];
    
}


@end
