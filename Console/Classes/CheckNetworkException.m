/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2012, OpenRemote Inc.
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
#import "CheckNetworkException.h"

@interface CheckNetworkException ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *message;

@end

@implementation CheckNetworkException

+ (CheckNetworkException *)exceptionWithTitle:(NSString *)t message:(NSString *)msg
{
	CheckNetworkException *e = [[CheckNetworkException alloc] initWithName:@"checkNetworkException" reason:@"Check Network Fail" userInfo:nil];
	e.title = t;
	e.message = msg;
	return e;
}

@synthesize title, message;

@end