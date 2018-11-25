/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2015, OpenRemote Inc.
 *
 * See the contributors.txt file in the distribution for a
 * full listing of individual contributors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#import "ORScreenOrGroupReferenceTest.h"
#import "ORScreenOrGroupReference.h"
#import "ORObjectIdentifier.h"

@implementation ORScreenOrGroupReferenceTest

- (void)testCreation
{
    ORObjectIdentifier *groupId = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    ORObjectIdentifier *screenId = [[ORObjectIdentifier alloc] initWithIntegerId:2];
    
    ORScreenOrGroupReference *reference = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId screenIdentifier:screenId];
    XCTAssertNotNil(reference, @"A screen reference with a group and a screen identifier should be instantiated");
    XCTAssertEqualObjects(reference.groupIdentifier, groupId, @"Reference's group identifier should be the one used to initialize reference");
    XCTAssertEqualObjects(reference.screenIdentifier, screenId, @"Reference's screen identifier should be the one used to initialize reference");
    
    reference = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId screenIdentifier:nil];
    XCTAssertNotNil(reference, @"A screen reference with a group identifier and no screen identifier should be instantiated");
    XCTAssertEqualObjects(reference.groupIdentifier, groupId, @"Reference's group identifier should be the one used to initialize reference");
    XCTAssertNil(reference.screenIdentifier, @"Reference's screen identifier should be nil");
    
    reference = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:nil screenIdentifier:nil];
    XCTAssertNil(reference, @"A screen reference with no group and screen identifier is not allowed");
    
    reference = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:nil screenIdentifier:screenId];
    XCTAssertNil(reference, @"A screen reference with no group identifier is not allowed");
}

- (void)testEqualityAndHash
{
    ORObjectIdentifier *groupId = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    ORObjectIdentifier *screenId = [[ORObjectIdentifier alloc] initWithIntegerId:2];
    
    ORScreenOrGroupReference *reference = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId screenIdentifier:screenId];

    XCTAssertTrue([reference isEqual:reference], @"Reference should be equal to itself");
    XCTAssertFalse([reference isEqual:nil], @"Reference should not be equal to nil");

    ORScreenOrGroupReference *equalReference = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId screenIdentifier:screenId];;
    XCTAssertTrue([equalReference isEqual:reference], @"References created with same information should be equal");
    XCTAssertEqual([equalReference hash], [reference hash], @"Hashses of references created with same information should be equal");
    
    ORScreenOrGroupReference *referenceWithOtherGroupIdentifier = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:3] screenIdentifier:screenId];
    XCTAssertFalse([referenceWithOtherGroupIdentifier isEqual:reference], @"References with different group identifier should not be equal");
    
    ORScreenOrGroupReference *referenceWithOtherScreenIdentifier = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:3]];
    XCTAssertFalse([referenceWithOtherScreenIdentifier isEqual:reference], @"References with different screen identifier should not be equal");
}

- (void)testEqualityAndHashForNilScreenReference
{
    ORObjectIdentifier *groupId = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    
    ORScreenOrGroupReference *reference = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId screenIdentifier:nil];
    
    XCTAssertTrue([reference isEqual:reference], @"Reference should be equal to itself");
    XCTAssertFalse([reference isEqual:nil], @"Reference should not be equal to nil");
    
    ORScreenOrGroupReference *equalReference = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId screenIdentifier:nil];;
    XCTAssertTrue([equalReference isEqual:reference], @"References created with same information should be equal");
    XCTAssertEqual([equalReference hash], [reference hash], @"Hashses of references created with same information should be equal");
    
    ORScreenOrGroupReference *referenceWithOtherGroupIdentifier = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:3] screenIdentifier:nil];
    XCTAssertFalse([referenceWithOtherGroupIdentifier isEqual:reference], @"References with different group identifier should not be equal");
    
    ORScreenOrGroupReference *referenceWithOtherScreenIdentifier = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:3]];
    XCTAssertFalse([referenceWithOtherScreenIdentifier isEqual:reference], @"References with different screen identifier should not be equal");
}

- (void)testCopy
{
    ORObjectIdentifier *groupId1 = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    ORObjectIdentifier *screenId1 = [[ORObjectIdentifier alloc] initWithIntegerId:2];
    ORScreenOrGroupReference *reference1 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId1 screenIdentifier:screenId1];

    ORScreenOrGroupReference *reference2 = [reference1 copy];
    
    XCTAssertNotNil(reference2, @"Copy should create a valid instance");
    XCTAssertEqualObjects(reference2, reference1, @"Copy should be equal to original");
    XCTAssertFalse(reference1 == reference2, @"Copy should not be same instance as original");
    XCTAssertEqualObjects(reference2.groupIdentifier, reference1.groupIdentifier, @"Copy group identifier should be equal to original's one");
    XCTAssertFalse(reference1.groupIdentifier == reference2.groupIdentifier, @"Copy group identifier should be same instance as original's one");
    XCTAssertEqualObjects(reference2.screenIdentifier, reference1.screenIdentifier, @"Copy screen identifier should be equal to original's one");
    XCTAssertFalse(reference1.screenIdentifier == reference2.screenIdentifier, @"Copy screen identifier should be same instance as original's one");
}

- (void)testCopyForNilScreenReference
{
    ORObjectIdentifier *groupId1 = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    ORScreenOrGroupReference *reference1 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId1 screenIdentifier:nil];
    
    ORScreenOrGroupReference *reference2 = [reference1 copy];
    
    XCTAssertNotNil(reference2, @"Copy should create a valid instance");
    XCTAssertEqualObjects(reference2, reference1, @"Copy should be equal to original");
    XCTAssertFalse(reference1 == reference2, @"Copy should not be same instance as original");
    XCTAssertEqualObjects(reference2.groupIdentifier, reference1.groupIdentifier, @"Copy group identifier should be equal to original's one");
    XCTAssertFalse(reference1.groupIdentifier == reference2.groupIdentifier, @"Copy group identifier should be same instance as original's one");
    XCTAssertNil(reference2.screenIdentifier, @"Screen identifier of copy should also be nil");
}

- (void)testNSCoding
{
    ORObjectIdentifier *groupId1 = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    ORObjectIdentifier *screenId1 = [[ORObjectIdentifier alloc] initWithIntegerId:2];
    ORScreenOrGroupReference *reference1 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId1 screenIdentifier:screenId1];
    
    NSData *encodedReference = [NSKeyedArchiver archivedDataWithRootObject:reference1];
    XCTAssertNotNil(encodedReference, @"Archived data should not be nil");
    ORObjectIdentifier *decodedReference = [NSKeyedUnarchiver unarchiveObjectWithData:encodedReference];
    XCTAssertNotNil(decodedReference, @"Decoded object should not be nil");
    XCTAssertEqualObjects(decodedReference, reference1, @"Decoded reference should be equal to original one");
}

- (void)testNSCodingForNilScreenReference
{
    ORObjectIdentifier *groupId1 = [[ORObjectIdentifier alloc] initWithIntegerId:1];
    ORScreenOrGroupReference *reference1 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:groupId1 screenIdentifier:nil];
    
    NSData *encodedReference = [NSKeyedArchiver archivedDataWithRootObject:reference1];
    XCTAssertNotNil(encodedReference, @"Archived data should not be nil");
    ORObjectIdentifier *decodedReference = [NSKeyedUnarchiver unarchiveObjectWithData:encodedReference];
    XCTAssertNotNil(decodedReference, @"Decoded object should not be nil");
    XCTAssertEqualObjects(decodedReference, reference1, @"Decoded reference should be equal to original one");
}

@end
