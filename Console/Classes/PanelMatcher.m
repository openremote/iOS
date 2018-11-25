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

#import "PanelMatcher.h"
#import "UIDevice+ORAdditions.h"

@implementation PanelMatcher

+ (NSArray<NSString *> *)filterPanelIdentities:(NSArray *)panelIdentities forDevicePrefix:(NSString *)devicePrefix
{
    NSMutableArray<NSString *> *candidates;
    if (devicePrefix) {
        candidates = [[NSMutableArray alloc] init];
        // get all identities matching the prefix
        [panelIdentities enumerateObjectsUsingBlock:^(NSString *identity, NSUInteger idx, BOOL *stop) {
            if ([identity.lowercaseString rangeOfString:devicePrefix.lowercaseString].location == 0) {
                [candidates addObject:identity];
            }
        }];
        
        // remove identities matching another prefix
        NSMutableArray *otherPrefixes = [[UIDevice allAutoSelectPrefixes] mutableCopy];
        [otherPrefixes removeObject:devicePrefix];
        
        [otherPrefixes enumerateObjectsUsingBlock:^(NSString *prefix, NSUInteger idxPrefix, BOOL *stopPrefix) {
            if (![devicePrefix containsString:prefix]) {
                __block NSMutableArray<NSString *> *candidatesToRemove = [[NSMutableArray alloc] init];
                [candidates enumerateObjectsUsingBlock:^(NSString *candidate, NSUInteger idxCandidate, BOOL *stopCandidate) {
                    if ([candidate.lowercaseString rangeOfString:prefix.lowercaseString].location == 0) {
                        [candidatesToRemove addObject:candidate];
                    }
                }];
                [candidates removeObjectsInArray:candidatesToRemove];
            }
        }];
    }
    return [candidates copy];
}

@end
