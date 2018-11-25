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


#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPAD_PRO_12;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPAD_PRO_11;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPAD_PRO_10_5;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPAD;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPAD3;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPHONE_XSMAX;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPHONE_XR;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPHONE_X;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPHONE6;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPHONE_5;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPHONE_4;
FOUNDATION_EXPORT NSString *const DEVICE_TYPE_IPHONE;

@interface UIDevice (ORAdditions)

- (NSString *)autoSelectPrefix;

+ (NSArray<NSString *> *)allAutoSelectPrefixes;

@end
