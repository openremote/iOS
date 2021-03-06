/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2013, OpenRemote Inc.
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

#import "ORRuntimeUtils.h"
#import <objc/runtime.h>

@implementation ORRuntimeUtils

+ (NSArray *)instanceMethodsSelectorsFromProtocol:(Protocol *)aProtocol
{
    NSMutableArray *tmp = [NSMutableArray array];
    unsigned int numMethods;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(aProtocol, NO, YES, &numMethods);
    if (methods) {
        for (int i = 0; i < numMethods; i++) {
            [tmp addObject:[NSValue valueWithPointer:methods[i].name]];
        }
        free(methods);
    }
    methods = protocol_copyMethodDescriptionList(aProtocol, YES, YES, &numMethods);
    if (methods) {
        for (int i = 0; i < numMethods; i++) {
            [tmp addObject:[NSValue valueWithPointer:methods[i].name]];
        }
        free(methods);
    }

    return [NSArray arrayWithArray:tmp];
}

@end