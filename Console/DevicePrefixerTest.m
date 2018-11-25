/* OpenRemote, the Home of the Digital Home.
 *  * Copyright 2008-2018, OpenRemote Inc-2009, OpenRemote Inc.
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

#import "DevicePrefixerTest.h"
#import "DevicePrefixer.h"

@interface DevicePrefixerTest ()

@property (nonatomic, strong) DevicePrefixer *devicePrefixer;

@end

@implementation DevicePrefixerTest

- (void)setUp {
    [super setUp];
    self.devicePrefixer = [[DevicePrefixer alloc] init];
}


- (void)testPrefixForiPhone4 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone4], PREFIX_IPHONE_4);
}

- (void)testPrefixForiPhone4S {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone4S], PREFIX_IPHONE_4);
}

- (void)testPrefixForiPhone5 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone5], PREFIX_IPHONE_5);
}

- (void)testPrefixForiPhone5c {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone5c], PREFIX_IPHONE_5);
}

- (void)testPrefixForiPhone5s {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone5s], PREFIX_IPHONE_5);
}

- (void)testPrefixForiPhoneSE {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhoneSE], PREFIX_IPHONE_5);
}

- (void)testPrefixForiPhone6 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone6], PREFIX_IPHONE6);
}

- (void)testPrefixForiPhone6Plus {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone6Plus], PREFIX_IPHONE_6_PLUS);
}

- (void)testPrefixForiPhone6s {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone6s], PREFIX_IPHONE6);
}

- (void)testPrefixForiPhone6sPlus {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone6sPlus], PREFIX_IPHONE_6_PLUS);
}

- (void)testPrefixForiPhone7 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone7], PREFIX_IPHONE6);
}

- (void)testPrefixForiPhone7Plus {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone7Plus], PREFIX_IPHONE_6_PLUS);
}

- (void)testPrefixForiPhone8 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone8], PREFIX_IPHONE6);
}

- (void)testPrefixForiPhone8Plus {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhone8Plus], PREFIX_IPHONE_6_PLUS);
}

- (void)testPrefixForiPhoneX {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhoneX], PREFIX_IPHONE_X);
}

- (void)testPrefixForiPhoneXR {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhoneXR], PREFIX_IPHONE_XR);
}

- (void)testPrefixForiPhoneXS {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhoneXS], PREFIX_IPHONE_X);
}

- (void)testPrefixForiPhoneXSMax {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPhoneXSMax], PREFIX_IPHONE_XSMAX);
}

- (void)testPrefixForiPad1 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPad1], PREFIX_IPAD);
}

- (void)testPrefixForiPad2 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPad2], PREFIX_IPAD);
}

- (void)testPrefixForiPad3 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPad3], PREFIX_IPAD3);
}

- (void)testPrefixForiPad4 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPad4], PREFIX_IPAD3);
}

- (void)testPrefixForiPadMini1 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadMini1], PREFIX_IPAD);
}

- (void)testPrefixForiPadMini2 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadMini2], PREFIX_IPAD3);
}

- (void)testPrefixForiPadMini3 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadMini3], PREFIX_IPAD3);
}

- (void)testPrefixForiPadMini4 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadMini4], PREFIX_IPAD3);
}

- (void)testPrefixForiPadAir1 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadAir1], PREFIX_IPAD3);
}

- (void)testPrefixForiPadAir2 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadAir2], PREFIX_IPAD3);
}

- (void)testPrefixForiPadPro9p7Inch {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadPro9p7Inch], PREFIX_IPAD3);
}

- (void)testPrefixForiPadPro10p5Inch {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadPro10p5Inch], PREFIX_IPAD_PRO_10_5);
}

- (void)testPrefixForiPadPro12p9Inch {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadPro12p9Inch], PREFIX_IPAD_PRO_12);
}

- (void)testPrefixForiPadPro10p5Inch2 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadPro10p5Inch2], PREFIX_IPAD_PRO_10_5);
}

- (void)testPrefixForiPadPro12p9Inch2 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadPro12p9Inch2], PREFIX_IPAD_PRO_12);
}

- (void)testPrefixForiPadPro11p {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadPro11p], PREFIX_IPAD_PRO_11);
}

- (void)testPrefixForiPadPro11p1TB {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadPro11p1TB], PREFIX_IPAD_PRO_11);
}

- (void)testPrefixForiPadPro12p9Inch3 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadPro12p9Inch3], PREFIX_IPAD_PRO_12);
}

- (void)testPrefixForiPadPro12p9Inch31TB {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPadPro12p9Inch31TB], PREFIX_IPAD_PRO_12);
}

- (void)testPrefixForiPad5 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPad5], PREFIX_IPAD3);
}

- (void)testPrefixForiPad6 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPad6], PREFIX_IPAD3);
}

- (void)testPrefixForiPod1 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPod1], PREFIX_IPHONE);
}

- (void)testPrefixForiPod2 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPod2], PREFIX_IPHONE);
}

- (void)testPrefixForiPod3 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPod3], PREFIX_IPHONE);
}

- (void)testPrefixForiPod4 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPod4], PREFIX_IPHONE_4);
}

- (void)testPrefixForiPod5 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPod5], PREFIX_IPHONE_5);
}

- (void)testPrefixForiPod6 {
    XCTAssertEqual([self.devicePrefixer prefixForModel:GBDeviceModeliPod6], PREFIX_IPHONE_5);
}

- (void)testAllPrefixes {
    NSArray<NSString *> *expected = @[
            PREFIX_IPAD_PRO_12,
            PREFIX_IPAD_PRO_11,
            PREFIX_IPAD_PRO_10_5,
            PREFIX_IPAD,
            PREFIX_IPAD3,
            PREFIX_IPHONE_XSMAX,
            PREFIX_IPHONE_XR,
            PREFIX_IPHONE_X,
            PREFIX_IPHONE_6_PLUS,
            PREFIX_IPHONE6,
            PREFIX_IPHONE_5,
            PREFIX_IPHONE_4,
            PREFIX_IPHONE
    ];

    NSArray<NSString *> *allPrefixes = [DevicePrefixer allPrefixes];
    XCTAssertEqual(expected.count, allPrefixes.count);
    for (NSString *prefix in expected) {
        XCTAssertTrue([allPrefixes containsObject:prefix]);
    }        
}
@end
