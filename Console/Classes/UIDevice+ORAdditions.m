/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2016, OpenRemote Inc.
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

#import "UIDevice+ORAdditions.h"
#import "GBDeviceInfo.h"
#import "DevicePrefixer.h"

NSString *const DEVICE_TYPE_IPAD_PRO_12 = PREFIX_IPAD_PRO_12;
NSString *const DEVICE_TYPE_IPAD_PRO_11 = PREFIX_IPAD_PRO_11;
NSString *const DEVICE_TYPE_IPAD_PRO_10_5 = PREFIX_IPAD_PRO_10_5;
NSString *const DEVICE_TYPE_IPAD = PREFIX_IPAD;
NSString *const DEVICE_TYPE_IPAD3 = PREFIX_IPAD3;
NSString *const DEVICE_TYPE_IPHONE_XSMAX = PREFIX_IPHONE_XSMAX;
NSString *const DEVICE_TYPE_IPHONE_XR = PREFIX_IPHONE_XR;
NSString *const DEVICE_TYPE_IPHONE_X = PREFIX_IPHONE_X;
NSString *const DEVICE_TYPE_IPHONE_6_PLUS = PREFIX_IPHONE_6_PLUS;
NSString *const DEVICE_TYPE_IPHONE6 = PREFIX_IPHONE6;
NSString *const DEVICE_TYPE_IPHONE_5 = PREFIX_IPHONE_5;
NSString *const DEVICE_TYPE_IPHONE_4 = PREFIX_IPHONE_4;
NSString *const DEVICE_TYPE_IPHONE = PREFIX_IPHONE;

@implementation UIDevice (ORAdditions)

/**
 *
 * @return A prefix NSString according to the following rules:
 * "iPhone" -> all 3.5" non retina screens
 * "iPhone4" -> all 3.5" retina screens
 * "iPhone5" -> all 4" screens
 * "iPhone6" -> all 4.7" screens
 * "iPhone6Plus" -> all 5.5" screens
 * "iPhoneX" ->  all 5.8" screens
 * "iPhoneXSMax" -> all 6.5" screens
 * "iPhoneXR" -> all 6.1" screens
 * "iPad" -> all non retina iPads with a 4:3 ratio
 * "iPad3" -> all retina iPads with a 4:3 ratio (except iPad Pro 12.9)
 * "iPadPro105" -> iPad Pro 10.5"
 * "iPadPro11" -> iPad Pro 11" (4.3:3 ratio)
 * "iPadPro12" -> iPad Pro 12.9"
 * nil otherwise
 */
- (NSString *)autoSelectPrefix {
    DevicePrefixer *prefixer = [[DevicePrefixer alloc] init];
    GBDeviceInfo *deviceInfo = [[GBDeviceInfo alloc] init];
    return [prefixer prefixForModel:deviceInfo.model];
}

+ (NSArray<NSString *> *)allAutoSelectPrefixes {
    return @[
            DEVICE_TYPE_IPAD_PRO_12,
            DEVICE_TYPE_IPAD_PRO_11,
            DEVICE_TYPE_IPAD_PRO_10_5,
            DEVICE_TYPE_IPAD,
            DEVICE_TYPE_IPAD3,
            DEVICE_TYPE_IPHONE_XSMAX,
            DEVICE_TYPE_IPHONE_XR,
            DEVICE_TYPE_IPHONE_X,
            DEVICE_TYPE_IPHONE_6_PLUS,
            DEVICE_TYPE_IPHONE6,
            DEVICE_TYPE_IPHONE_5,
            DEVICE_TYPE_IPHONE_4,
            DEVICE_TYPE_IPHONE
    ];
}

@end
