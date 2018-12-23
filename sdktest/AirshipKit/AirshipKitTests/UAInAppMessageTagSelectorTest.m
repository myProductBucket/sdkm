/* Copyright 2018 Urban Airship and Contributors */

#import "UABaseTest.h"
#import "UAInAppMessageTagSelector+Internal.h"

@interface UAInAppMessageTagSelectorTest : UABaseTest

@property (nonatomic, strong) UAInAppMessageTagSelector *selector;
@property (nonatomic, strong) UAInAppMessageTagSelector *selectorWithTagGroups;
@end

@implementation UAInAppMessageTagSelectorTest

- (void)setUp {
    [super setUp];
    self.selector = [UAInAppMessageTagSelector or:@[[UAInAppMessageTagSelector and:@[[UAInAppMessageTagSelector tag:@"some-tag"],
                                                                                     [UAInAppMessageTagSelector not:[UAInAppMessageTagSelector tag:@"not-tag"]]]],
                                                    [UAInAppMessageTagSelector tag:@"some-other-tag"]]];

    self.selectorWithTagGroups = [UAInAppMessageTagSelector and:@[[UAInAppMessageTagSelector tag:@"some-tag" group:@"some-group"],
                                                                  [UAInAppMessageTagSelector tag:@"some-tag"],
                                                                  [UAInAppMessageTagSelector not:[UAInAppMessageTagSelector tag:@"not-tag"]]]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testJSON {
    NSError *error;
    UAInAppMessageTagSelector *toAndFromJson = [UAInAppMessageTagSelector selectorWithJSON:[self.selector toJSON] error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(self.selector, toAndFromJson);
}

- (void)testSelector {
    NSMutableArray<NSString *> *tags = [NSMutableArray array];

    // Empty list
    XCTAssertFalse([self.selector apply:tags]);
    
    [tags addObject:@"some-tag"];
    
    // Contains "some-tag" and not "not-tag"
    XCTAssertTrue([self.selector apply:tags]);

    [tags addObject:@"not-tag"];

    // Contains "some-tag" and "not-tag"
    XCTAssertFalse([self.selector apply:tags]);

    [tags addObject:@"some-other-tag"];

    // Contains "some-other-tag"
    XCTAssertTrue([self.selector apply:tags]);
}

- (void)testSelectorWithTagGroups {

    NSMutableArray<NSString *> *tags = [NSMutableArray array];

    [tags addObject:@"some-tag"];

    UATagGroups *tagGroups = [UATagGroups tagGroupsWithTags:@{@"wrong-group" : @[@"some-tag"], @"some-group" : @[@"wrong-tag"]}];

    // Wrong group for the right tag, wrong tag for right group
    XCTAssertFalse([self.selectorWithTagGroups apply:tags tagGroups:tagGroups]);

    tagGroups = [UATagGroups tagGroupsWithTags:@{@"wrong-group" : @[@"some-tag"], @"some-group" : @[@"some-tag"]}];

    // The right group should now contain the right tag
    XCTAssertTrue([self.selectorWithTagGroups apply:tags tagGroups:tagGroups]);
}

- (void)testContainsTagGroups {
    XCTAssertFalse([self.selector containsTagGroups]);
    XCTAssertTrue([self.selectorWithTagGroups containsTagGroups]);
}

- (void)testTagGroups {
    UATagGroups *tagGroups = self.selectorWithTagGroups.tagGroups;

    XCTAssertNotNil([tagGroups.tags objectForKey:@"some-group"]);
    XCTAssertEqual(tagGroups.tags.count, 1);
    XCTAssertEqualObjects(tagGroups.tags[@"some-group"], [NSSet setWithArray:@[@"some-tag"]]);
    XCTAssertEqual([tagGroups.tags[@"some-group"] count], 1);

}

@end
