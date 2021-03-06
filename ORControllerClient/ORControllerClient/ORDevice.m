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

#import "ORDevice_Private.h"
#import "ORDeviceCommand_Private.h"
#import "ORDeviceSensor_Private.h"
#import "ORObjectIdentifier.h"
#import "ORDeviceSensor.h"


@interface ORDevice ()

@property (nonatomic, strong) NSMutableArray<ORDeviceCommand *> *internalCommands;
@property (nonatomic, strong) NSMutableArray<ORDeviceSensor *> *internalSensors;

@end

@implementation ORDevice

static NSString *const kNameKey = @"_name";
static NSString *const kIdentifierKey = @"_identifier";
static NSString *const kCommandsKey = @"self.internalCommands";
static NSString *const kSensorsKey = @"self.internalSensors";

@synthesize name = _name;
@synthesize identifier = _identifier;

- (instancetype)init
{
    self = [super init];
    if (self) {
    }

    return self;
}

- (void)addCommand:(ORDeviceCommand *)command
{
    if (command) {
        command.device = self;
        [self.internalCommands addObject:command];
    }
}


- (void)addSensor:(ORDeviceSensor *)sensor
{
    if (sensor) {
        sensor.device = self;
        [self.internalSensors addObject:sensor];
    }
}

- (ORDeviceCommand *)findCommandById:(ORObjectIdentifier *)id
{
    for (ORDeviceCommand *command in self.internalCommands) {
        if ([command.identifier isEqual:id]) {
            return command;
        }
    }
    return nil;
}

- (ORDeviceCommand *)findCommandByName:(NSString *)name
{
    for (ORDeviceCommand *command in self.internalCommands) {
        if ([command.name isEqualToString:name]) {
            return command;
        }
    }
    return nil;
}

- (NSSet<ORDeviceCommand *> *)findCommandsByTags:(NSSet<NSString *> *)tags
{
    NSArray *commands = [self.internalCommands filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ORDeviceCommand *command, NSDictionary *bindings) {
        BOOL commandHasTag = NO;
        for (NSString *tag in tags) {
            if ([command.tags containsObject:tag]) {
                commandHasTag = YES;
                break;
            }
        }
        return commandHasTag;
    }]];
    return [NSSet setWithArray:commands];
}

- (ORDeviceSensor *)findSensorById:(ORObjectIdentifier *)id
{
    for (ORDeviceSensor *sensor in self.internalSensors) {
        if ([sensor.identifier isEqual:id]) {
            return sensor;
        }
    }
    return nil;
}

- (ORDeviceSensor *)findSensorByName:(NSString *)name
{
    for (ORDeviceSensor *sensor in self.internalSensors) {
        if ([sensor.name isEqualToString:name]) {
            return sensor;
        }
    }
    return nil;
}


#pragma mark - getters/setter

- (NSArray *)commands
{
    return [self.internalCommands copy];
}

- (NSArray *)sensors
{
    return [self.internalSensors copy];
}

- (NSMutableArray *)internalCommands
{
    if (!_internalCommands) {
        _internalCommands = [[NSMutableArray alloc] init];
    }
    return _internalCommands;
}

- (NSMutableArray *)internalSensors
{
    if (!_internalSensors) {
        _internalSensors = [[NSMutableArray alloc] init];
    }
    return _internalSensors;
}

#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.internalCommands = [coder decodeObjectForKey:kCommandsKey];
        [self.internalCommands enumerateObjectsUsingBlock:^(ORDeviceCommand *command, NSUInteger idx, BOOL *stop) {
            command.device = self;
        }];
        self.internalSensors = [coder decodeObjectForKey:kSensorsKey];
        [self.internalSensors enumerateObjectsUsingBlock:^(ORDeviceSensor *sensor, NSUInteger idx, BOOL *stop) {
            sensor.device = self;
            if (sensor.commandIdentifier) {
                [self.internalCommands enumerateObjectsUsingBlock:^(ORDeviceCommand *command, NSUInteger idxCommand, BOOL *stopCommand) {
                    if ([command.identifier isEqual:sensor.commandIdentifier]) {
                        sensor.command = command;
                        *stopCommand = YES;
                    }
                }];
            }
        }];
        _name = [coder decodeObjectForKey:kNameKey];
        _identifier = [coder decodeObjectForKey:kIdentifierKey];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.internalCommands forKey:kCommandsKey];
    [coder encodeObject:self.internalSensors forKey:kSensorsKey];
    [coder encodeObject:self.name forKey:kNameKey];
    [coder encodeObject:self.identifier forKey:kIdentifierKey];
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToDevice:other];
}

- (BOOL)isEqualToDevice:(ORDevice *)device
{
    if (self == device)
        return YES;
    if (device == nil)
        return NO;
    if (self.internalCommands != device.internalCommands && ![self.internalCommands isEqualToArray:device.internalCommands])
        return NO;
    if (self.internalSensors != device.internalSensors && ![self.internalSensors isEqualToArray:device.internalSensors])
        return NO;
    if (self.name != device.name && ![self.name isEqualToString:device.name])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = [self.internalCommands hash];
    hash = hash * 31u + [self.internalSensors hash];
    hash = hash * 31u + [self.name hash];
    hash = hash * 31u + [self.identifier hash];
    return hash;
}

@end
