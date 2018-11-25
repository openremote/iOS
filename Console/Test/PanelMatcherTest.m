//
//  PanelMatcherTest.m
//  openremote
//
//  Created by Eric Bariaux on 13/12/16.
//  Copyright © 2016 OpenRemote, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PanelMatcher.h"

@interface PanelMatcherTest : XCTestCase

@end

@implementation PanelMatcherTest

- (void)testExactMatch {
    NSArray *panelIdentities = @[@"iPhone6", @"iPhone6Plus"];
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6"], @[@"iPhone6"], @"Expected iPhone6 as panel identity");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6Plus"], @[@"iPhone6Plus"], @"Expected iPhone6Plus as panel identity");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone"], @[], @"Expected no panel identity");
}

- (void)testStartsWith {
    NSArray *panelIdentities = @[@"iPhone6 Panel", @"iPhone6Plusdesign"];
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6"], @[@"iPhone6 Panel"], @"Expected iPhone6 Panel as panel identity");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6Plus"], @[@"iPhone6Plusdesign"], @"Expected iPhone6Plusdesign as panel identity");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone"], @[], @"Expected no panel identity");
}

- (void)testCaseDifferences {
    NSArray *panelIdentities = @[@"IPHONE6 Panel", @"iphone6PLUSdesign"];
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6"], @[@"IPHONE6 Panel"], @"Expected IPHONE6 Panel as panel identity");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6Plus"], @[@"iphone6PLUSdesign"], @"Expected iphone6PLUSdesign as panel identity");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone"], @[], @"Expected no panel identity");
}

- (void)testMultipleMatches {
    NSArray *panelIdentities = @[@"iPhone6 Panel1", @"iPhone6 Panel2", @"iPhone6Plus"];
    NSArray *expectedPanels = @[@"iPhone6 Panel1", @"iPhone6 Panel2"];
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6"], expectedPanels, @"Expected multiple panel identities");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6Plus"], @[@"iPhone6Plus"], @"Expected iPhone6Plus as panel identity");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone"], @[], @"Expected no panel identity");
}

- (void)testNoContains {
    NSArray *panelIdentities = @[@"iPhone6", @"iPhone6Plus", @"Panel iPhone6", @"Panel iPhone6 plus"];
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6"], @[@"iPhone6"], @"Expected iPhone6 as panel identity");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone6Plus"], @[@"iPhone6Plus"], @"Expected iPhone6Plus as panel identity");
    XCTAssertEqualObjects([PanelMatcher filterPanelIdentities:panelIdentities forDevicePrefix:@"iPhone"], @[], @"Expected no panel identity");
}

@end
