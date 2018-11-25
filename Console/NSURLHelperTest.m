/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2012, OpenRemote Inc.
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
#import "NSURLHelperTest.h"
#import "NSURLHelper.h"

@implementation NSURLHelperTest

- (void)testValidURLs
{
    XCTAssertNotNil([NSURLHelper parseControllerURL:@"http://localhost:8080/controller"], @"");
    XCTAssertNotNil([NSURLHelper parseControllerURL:@"https://localhost:8080/controller"], @"");
    XCTAssertNotNil([NSURLHelper parseControllerURL:@"localhost:8080/controller"], @"");    
    XCTAssertNil([NSURLHelper parseControllerURL:@"http:8080/controller"], @"");
    // TODO: I would have liked that to fail, but it is considered a valid URL and still valid if prepending http://
//    STAssertNil([NSURLHelper parseControllerURL:@"error://localhost:8080/controller"], @"");
    XCTAssertNil([NSURLHelper parseControllerURL:@":8080/controller"], @"");
}

@end
