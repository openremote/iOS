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

#import "ScreenReferenceStackTest.h"
#import "ScreenReferenceStack.h"
#import "ORScreenOrGroupReference.h"
#import "ORControllerClient/ORObjectIdentifier.h"


@implementation ScreenReferenceStackTest

- (void)testPopOnEmptyStackReturnsNil
{
    ScreenReferenceStack *stack = [[ScreenReferenceStack alloc] initWithCapacity:10];
    XCTAssertNil([stack pop], @"Poping an empty stack should not return anything");
}

- (void)testPushPopAndTop
{
    ScreenReferenceStack *stack = [[ScreenReferenceStack alloc] initWithCapacity:10];
    ORScreenOrGroupReference *ref = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]
                                                           screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:2]];
    [stack push:ref];
    
    ORScreenOrGroupReference *topRef = [stack top];
    XCTAssertNotNil(topRef, @"Should be able to consult object at top of the stack when one was pushed before");
    XCTAssertEqual(topRef, ref, @"Object from top of stack should be one pushed before");
    
    ORScreenOrGroupReference *poppedRef = [stack pop];
    XCTAssertNotNil(poppedRef, @"Should be able to pop an object from a stack where one was pushed before");
    XCTAssertEqual(poppedRef, ref, @"Object poped from stack should be one pushed before");
    XCTAssertEqual(poppedRef, topRef, @"Object poped from stack should be one returned as top of stack");
    
    XCTAssertNil([stack pop], @"It should not be possible to pop a second object from the stack");
    XCTAssertNil([stack top], @"Top of stack should return nil when it's empty");
}

- (void)testStackBehavesAsFIFO
{
    ScreenReferenceStack *stack = [[ScreenReferenceStack alloc] initWithCapacity:10];
    ORScreenOrGroupReference *ref1 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]
                                                            screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:2]];
    [stack push:ref1];
    ORScreenOrGroupReference *ref2 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]
                                                            screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:3]];
    [stack push:ref2];
    XCTAssertEqual([stack pop], ref2, @"First poped object should be the last one pushed");
    XCTAssertEqual([stack pop], ref1, @"Second poped object should be the first one pushed");
}

- (void)testStackDiscardsItemWhenCapacityReached
{
    ScreenReferenceStack *stack = [[ScreenReferenceStack alloc] initWithCapacity:2];
    [stack push:[[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]                 
                                                screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]]];
    ORScreenOrGroupReference *ref1 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]
                                                            screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:2]];
    [stack push:ref1];
    ORScreenOrGroupReference *ref2 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]
                                                            screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:3]];
    [stack push:ref2];
    XCTAssertEqual([stack pop], ref2, @"First poped object should be the last one pushed");
    XCTAssertEqual([stack pop], ref1, @"Second poped object should be the one pushed before");
    XCTAssertNil([stack pop], @"First pushed object should have been discarded from stack");
}

- (void)testNSCoding
{
    ScreenReferenceStack *stack = [[ScreenReferenceStack alloc] initWithCapacity:2];
    [stack push:[[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]
                                                screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]]];
    ORScreenOrGroupReference *ref1 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]
                                                            screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:2]];
    [stack push:ref1];
    ORScreenOrGroupReference *ref2 = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1]
                                                            screenIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:3]];
    [stack push:ref2];
    
    NSData *encodedStack = [NSKeyedArchiver archivedDataWithRootObject:stack];
    XCTAssertNotNil(encodedStack, @"Archived data should not be nil");
    ScreenReferenceStack *decodedStack = [NSKeyedUnarchiver unarchiveObjectWithData:encodedStack];
    XCTAssertNotNil(decodedStack, @"Decoded object should not be nil");
    
    XCTAssertEqualObjects([decodedStack valueForKey:@"stack"], [stack valueForKey:@"stack"], @"Decoded stack's stack should be equal to original one");
    XCTAssertEqual([decodedStack valueForKey:@"capacity"], [stack valueForKey:@"capacity"], @"Decoded stack's capacity should be equal to original one");
}


@end