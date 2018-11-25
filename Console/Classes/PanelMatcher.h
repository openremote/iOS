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

/**
 * Helper method to match a panel name with device type.
 */
@interface PanelMatcher : NSObject

/**
 * Filter a list of panel identities based on device prefix.
 * Match is made case insensitive if panel identity starts with given prefix.
 * Only full matches are taken into account (e.g. if matching iPhone6, iPhone6Plus... panels will not patch)
 *
 * @param panelIdentities an NSArray of panel identities to filter
 * @param devicePrefix prefix of device to use for filtering
 *
 * @return A NSArray of matching panel identities
 */
+ (NSArray<NSString *> *)filterPanelIdentities:(NSArray *)panelIdentities forDevicePrefix:(NSString *)devicePrefix;

@end
