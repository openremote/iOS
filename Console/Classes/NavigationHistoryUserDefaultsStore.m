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

#import "NavigationHistoryUserDefaultsStore.h"
#import "ORControllerClient/Definition.h"
#import "ORControllerClient/ORObjectIdentifier.h"
#import "ORControllerClient/ORGroup.h"
#import "ORControllerClient/ORScreen.h"
#import "ORControllerClient/ORScreenOrGroupReference.h"
#import "ScreenReferenceStack.h"

@implementation NavigationHistoryUserDefaultsStore

- (void)persistHistory:(ScreenReferenceStack *)history forDefinition:(Definition *)definition
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:history] forKey:[self keyForDefinition:definition]];
    [userDefaults synchronize];
}

- (ScreenReferenceStack *)retrieveHistoryForDefinition:(Definition *)definition
{
    ScreenReferenceStack *navigationHistory;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:[self keyForDefinition:definition]]) {
        navigationHistory = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:[self keyForDefinition:definition]]];
    } else {
        ORScreenOrGroupReference *startReference = nil;
        navigationHistory = [[ScreenReferenceStack alloc] initWithCapacity:50];

        // Fall back to legacy way of storing last group / screen id and start history with that
        if ([userDefaults objectForKey:@"lastGroupId"]) {
            ORObjectIdentifier *lastGroupIdentifier = [[ORObjectIdentifier alloc] initWithStringId:[userDefaults objectForKey:@"lastGroupId"]];
        
            ORGroup *group = [definition findGroupByIdentifier:lastGroupIdentifier];
            if (!group) {
                startReference = [definition findFirstScreenReference];
            } else {
                if ([userDefaults objectForKey:@"lastScreenId"]) {
                    ORObjectIdentifier *lastScreenIdenfitier = [[ORObjectIdentifier alloc] initWithStringId:[userDefaults objectForKey:@"lastScreenId"]];
                    ORScreen *screen = [group findScreenByIdentifier:lastScreenIdenfitier];
                    if (!screen) {
                        startReference = [definition findFirstScreenReferenceStartingInGroup:group];
                    } else {
                        startReference = [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:group.identifier screenIdentifier:screen.identifier];
                    }
                } else {
                    startReference = [definition findFirstScreenReferenceStartingInGroup:group];
                }
            }
        } else {
            startReference = [definition findFirstScreenReference];
        }
        if (startReference) {
            [navigationHistory push:startReference];
        }
    }
    return navigationHistory;
}

- (NSString *)keyForDefinition:(Definition *)definition
{
    NSString *string = [NSString stringWithFormat:@"NavigationHistory-%@", definition.dataHash];
    NSLog(@"key %@", string);
    return string;
}

@end
