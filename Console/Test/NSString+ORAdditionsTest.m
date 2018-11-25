/* OpenRemote, the Home of the Digital Home.
 *  * Copyright 2008-2011, OpenRemote Inc-2009, OpenRemote Inc.
 * 
 * See the contributors.txt file in the distribution for a
 * full listing of individual contributors.
 * 
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 3.0 of
 * the License, or (at your option) any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * You should have received a copy of the GNU General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

#import "NSString+ORAdditionsTest.h"
#import "NSString+ORAdditions.h"

@implementation NSString_ORAdditionsTest

- (void)test_isValidIPAddress_ValidIPAddress {
    XCTAssertTrue([@"192.168.0.1" isValidIPAddress], @"Provided string is a valid IP address");
}

- (void)test_isValidIPAddress_InvalidIPAddress {
    XCTAssertFalse([@"192.168.433.1" isValidIPAddress], @"Provided string is not a valid IP address");
}

- (void)test_isValidIPAddress_HostName {
    XCTAssertFalse([@"www.openremote.org" isValidIPAddress], @"Provided string is not a valid IP address");
}

- (void)test_hostOfURL_ValidURL_HostName {
    XCTAssertEqualObjects([@"http://localhost:8080/controller" hostOfURL], @"localhost", @"Expected localhost as host");
}

- (void)test_hostOfURL_ValidURL_IPAddress {
    XCTAssertEqualObjects([@"http://192.168.1.1:8080/controller" hostOfURL], @"192.168.1.1", @"Expected 192.168.1.1 as host");    
}

- (void)test_hostOfURL_InvalidURL {
    XCTAssertNil([@"not a URL" hostOfURL], @"Provided string is not a URL, should return nil");
}

- (void)test_portAsStringOfURL_ValidURL {    
    XCTAssertEqualObjects([@"http://localhost:8080/controller" portAsStringOfURL], @"8080", @"Expected 8080 as port");
}

- (void)test_portAsStringOfURL_ValidURL_NoPort {    
    XCTAssertNil([@"http://localhost/controller" portAsStringOfURL], @"Provided URL does not define any port, should return nil");
}

- (void)test_portAsStringOfURL_InvalidURL {
    XCTAssertNil([@"not a URL" portAsStringOfURL], @"Provided string is not a URL, should return nil");
}

@end
