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

#import "DevicePrefixer.h"

@implementation DevicePrefixer

- (NSString *)prefixForModel:(GBDeviceModel)deviceModel {
    NSString *prefix;
    switch (deviceModel) {
        case GBDeviceModeliPadPro12p9Inch:
        case GBDeviceModeliPadPro12p9Inch2:
        case GBDeviceModeliPadPro12p9Inch3:
        case GBDeviceModeliPadPro12p9Inch31TB:
            prefix = PREFIX_IPAD_PRO_12;
            break;
        case GBDeviceModeliPadPro11p:
        case GBDeviceModeliPadPro11p1TB:
            prefix = PREFIX_IPAD_PRO_11;
            break;
        case GBDeviceModeliPadPro10p5Inch:
        case GBDeviceModeliPadPro10p5Inch2:
            prefix = PREFIX_IPAD_PRO_10_5;
            break;
        case GBDeviceModeliPad1:
        case GBDeviceModeliPad2:
        case GBDeviceModeliPadMini1:
            prefix = PREFIX_IPAD;
            break;
        case GBDeviceModeliPad3:
        case GBDeviceModeliPad4:
        case GBDeviceModeliPad5:
        case GBDeviceModeliPad6:
        case GBDeviceModeliPadMini2:
        case GBDeviceModeliPadMini3:
        case GBDeviceModeliPadMini4:
        case GBDeviceModeliPadAir1:
        case GBDeviceModeliPadAir2:
        case GBDeviceModeliPadPro9p7Inch:
            prefix = PREFIX_IPAD3;
            break;
        case GBDeviceModeliPhone6Plus:
        case GBDeviceModeliPhone6sPlus:
        case GBDeviceModeliPhone7Plus:
        case GBDeviceModeliPhone8Plus:
            prefix = PREFIX_IPHONE_6_PLUS;
            break;
        case GBDeviceModeliPhone6:
        case GBDeviceModeliPhone6s:
        case GBDeviceModeliPhone7:
        case GBDeviceModeliPhone8:
            prefix = PREFIX_IPHONE6;
            break;
        case GBDeviceModeliPhone5:
        case GBDeviceModeliPhone5c:
        case GBDeviceModeliPhone5s:
        case GBDeviceModeliPhoneSE:
        case GBDeviceModeliPod5:
        case GBDeviceModeliPod6:
            prefix = PREFIX_IPHONE_5;
            break;
        case GBDeviceModeliPod4:
        case GBDeviceModeliPhone4:
        case GBDeviceModeliPhone4S:
            prefix = PREFIX_IPHONE_4;
            break;
        case GBDeviceModeliPod1:
        case GBDeviceModeliPod2:
        case GBDeviceModeliPod3:
            prefix = PREFIX_IPHONE;
            break;
        case GBDeviceModeliPhoneX:
        case GBDeviceModeliPhoneXS:
            prefix = PREFIX_IPHONE_X;
            break;
        case GBDeviceModeliPhoneXR:
            prefix = PREFIX_IPHONE_XR;
            break;
        case GBDeviceModeliPhoneXSMax:
            prefix = PREFIX_IPHONE_XSMAX;
            break;
        default:
            break;
    }
    return prefix;
}

+ (NSArray<NSString *> *)allPrefixes {
    return @[
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
}

@end