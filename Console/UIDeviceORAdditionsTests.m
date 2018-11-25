//
// Created by Gilles Durys on 2018-11-14.
// Copyright (c) 2018 OpenRemote, Inc. All rights reserved.
//

#import "UIDeviceORAdditionsTests.h"
#import "UIDevice+ORAdditions.h"
#import "DevicePrefixer.h"

@implementation UIDeviceORAdditionsTests

- (void)testAllPrefixes {
    NSArray<NSString *> *autoSelectPrefixes = [UIDevice allAutoSelectPrefixes];
    NSArray<NSString *> *expectedPrefixes = [DevicePrefixer allPrefixes];
//    NSLog(@"%@", autoSelectPrefixes);
//    NSLog(@"%@", expectedPrefixes);
    XCTAssertEqual(autoSelectPrefixes.count, expectedPrefixes.count, @"Expected %@.\nActual:%@" , expectedPrefixes, autoSelectPrefixes);
    NSMutableArray *mutableAutoSelectPrefixes = [autoSelectPrefixes mutableCopy];
    [mutableAutoSelectPrefixes removeObjectsInArray:expectedPrefixes];
    XCTAssertEqual(mutableAutoSelectPrefixes.count, 0, @"Expected %@.\nActual:%@" , expectedPrefixes, autoSelectPrefixes);
//    XCTAssertEqual([[NSCountedSet alloc] initWithArray:autoSelectPrefixes], [[NSCountedSet alloc] initWithArray:expectedPrefixes]);
}


@end