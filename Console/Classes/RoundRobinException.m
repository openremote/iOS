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
#import "RoundRobinException.h"


@implementation RoundRobinException

+ (NSString *)controller:(ORControllerConfig *)controller exceptionMessageOfCode:(NSInteger)code {
	NSString *errorMessage = nil;
	if (code != 200) {
		switch (code) {
			case ROUNDROBIN_TCP_SERVER_START_FAIL://450
				errorMessage = @"The round-robin TCP server of controller didn't startup.";
				break;
			case ROUNDROBIN_UDP_SERVER_START_FAIL://451
				errorMessage = @"The round-robin UDP server of controller didn't startup.";
				break;
			case ROUNDROBIN_UDP_CLIENT_START_FAIL://452
				errorMessage = @"The round-robin UDP client of controller didn't startup.";
				break;
		}
		if (!errorMessage) {
            errorMessage = [NSString stringWithFormat:@"Occured unknown error, satus code is %ld", (long)code];
		}
	}
	return errorMessage;
}

@end
