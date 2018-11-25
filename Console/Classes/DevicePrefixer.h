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

#import <Foundation/Foundation.h>
#import "GBDeviceInfo.h"

#define PREFIX_IPAD_PRO_12 @"iPadPro12"
#define PREFIX_IPAD_PRO_11 @"iPadPro11"
#define PREFIX_IPAD_PRO_10_5 @"iPadPro105"
#define PREFIX_IPAD @"iPad"
#define PREFIX_IPAD3 @"iPad3"
#define PREFIX_IPHONE_XSMAX @"iPhoneXSMax"
#define PREFIX_IPHONE_XR @"iPhoneXR"
#define PREFIX_IPHONE_X @"iPhoneX"
#define PREFIX_IPHONE_6_PLUS @"iPhone6Plus"
#define PREFIX_IPHONE6 @"iPhone6"
#define PREFIX_IPHONE_5 @"iPhone5"
#define PREFIX_IPHONE_4 @"iPhone4"
#define PREFIX_IPHONE @"iPhone"

@interface DevicePrefixer : NSObject

+ (NSArray<NSString *> *)allPrefixes;

- (NSString *)prefixForModel:(GBDeviceModel)deviceModel;

@end
