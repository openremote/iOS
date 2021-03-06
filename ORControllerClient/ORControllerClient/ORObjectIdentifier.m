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

#import "ORObjectIdentifier.h"

@interface ORObjectIdentifier ()

@property (nonatomic) NSInteger _id;

@end

#define kIdKey       @"Id"

@implementation ORObjectIdentifier

- (instancetype)initWithIntegerId:(NSInteger)intId
{
    self = [super init];
    if (self) {
        self._id = intId;
    }
    return self;
}

- (instancetype)initWithStringId:(NSString *)stringId
{
    return [self initWithIntegerId:[stringId integerValue]];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[ORObjectIdentifier class]]) {
        return NO;
    }
    ORObjectIdentifier *other = (ORObjectIdentifier *)object;
    return other._id == self._id;
}

- (NSUInteger)hash
{
    return self._id;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithIntegerId:self._id];
}

- (NSString *)stringValue
{
    return [NSString stringWithFormat:@"%ld", (long)self._id];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self._id forKey:kIdKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithIntegerId:[aDecoder decodeIntegerForKey:kIdKey]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"ORObjectIdentifier [%ld]", (long)self._id];
}

@end