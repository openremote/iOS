//
//  SensorStatusCacheTest.m
//  openremote
//
//  Created by Eric Bariaux on 05/05/12.
//  Copyright (c) 2012 OpenRemote, Inc. All rights reserved.
//

#import "SensorStatusCacheTest.h"
#import "SensorStatusCache.h"
#import "NotificationConstant.h"
#import "ORObjectIdentifier.h"
#import <OCMock/OCMock.h>

@interface SensorStatusCacheTest ()

@property (nonatomic, retain) SensorStatusCache *statusCache;

@end

@implementation SensorStatusCacheTest

- (void)setUp
{
    self.statusCache = [[SensorStatusCache alloc] initWithNotificationCenter:[NSNotificationCenter defaultCenter]];
}

- (void)tearDown
{
    self.statusCache = nil;
}

- (void)testPublishedValueNotificationSent
{    
    id mockCenter = [OCMockObject mockForClass:[NSNotificationCenter class]];
    SensorStatusCache *cache = [[SensorStatusCache alloc] initWithNotificationCenter:mockCenter];
    ORObjectIdentifier *sensorIdentifier = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    [[mockCenter expect] postNotificationName:[NSString stringWithFormat:NotificationPollingStatusIdFormat, sensorIdentifier] object:cache];
    [cache publishNewValue:@"Value1" forSensorIdentifier:sensorIdentifier];
    [mockCenter verify];
}

- (void)testReadingValueFromCache
{
    ORObjectIdentifier *sensorIdentifier = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    [self.statusCache publishNewValue:@"Value1" forSensorIdentifier:sensorIdentifier];
    XCTAssertEqualObjects([self.statusCache valueForSensorIdentifier:sensorIdentifier], @"Value1", @"Value should have been updated to Value1");
    [self.statusCache publishNewValue:@"Value2" forSensorIdentifier:sensorIdentifier];
    XCTAssertEqualObjects([self.statusCache valueForSensorIdentifier:sensorIdentifier], @"Value2", @"Value should have been updated to Value2");
}

- (void)testReadingValueFromCacheAfterCacheCleaned
{
    ORObjectIdentifier *sensorIdentifier = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    [self.statusCache publishNewValue:@"Value1" forSensorIdentifier:sensorIdentifier];
    [self.statusCache clearStatusCache];
    XCTAssertNil([self.statusCache valueForSensorIdentifier:sensorIdentifier], @"Value should not be in cache after it was cleared");
}

@synthesize statusCache;

@end