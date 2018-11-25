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

#import "ORPanelDefinitionSensorRegistry.h"
#import "ORSensorLink.h"
#import "ORSensor.h"
#import "ORObjectIdentifier.h"
#import "ORSensorStatesMapping.h"

#define kLinksPerSensorIdKey  @"LinksPerSensorId"

@interface ORPanelDefinitionSensorRegistry ()

@property (nonatomic, strong) NSMutableDictionary *_linksPerSensorId;

@end

@implementation ORPanelDefinitionSensorRegistry

- (instancetype)init
{
    self = [super init];
    if (self) {
        self._linksPerSensorId = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)clearRegistry
{
    [self._linksPerSensorId removeAllObjects];
    [super clearRegistry];
}

- (void)registerSensor:(ORSensor *)sensor
     linkedToComponent:(NSObject *)component
              property:(NSString *)propertyName
   sensorStatesMapping:(ORSensorStatesMapping *)mapping
{
    [super registerSensor:sensor];
    NSMutableSet *components = self._linksPerSensorId[sensor.identifier];
    if (!components) {
        components = [NSMutableSet setWithCapacity:1];
        self._linksPerSensorId[sensor.identifier] = components;
    }
    NSSet *existingLinks = [components filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"component = %@ AND propertyName = %@", component, propertyName]];
    if ([existingLinks count]) {
        [components minusSet:existingLinks];
    }
    [components addObject:[[ORSensorLink alloc] initWithComponent:component propertyName:propertyName sensorStatesMapping:mapping]];
}

- (NSSet *)sensorLinksForSensorIdentifier:(ORObjectIdentifier *)sensorIdentifier
{
    return [NSSet setWithSet:self._linksPerSensorId[sensorIdentifier]];
}

- (void)updateWithSensorValues:(NSDictionary *)sensorValues
{
    // Update properties of linked element
    [sensorValues enumerateKeysAndObjectsUsingBlock:^(NSString *sensorId, id sensorValue, BOOL *stopSensorValues) {
        ORObjectIdentifier *sensorIdentifier = [[ORObjectIdentifier alloc] initWithStringId:sensorId];
        NSSet *sensorLinks = [self sensorLinksForSensorIdentifier:sensorIdentifier];
        
        [sensorLinks enumerateObjectsUsingBlock:^(ORSensorLink *link, BOOL *stopSensorLinks) {
            // "Map" given sensor value according to defined sensor states
            NSString *mappedSensorValue = [link.sensorStatesMapping stateValueForName:sensorValue];
            // If no mapping, use received sensor value as is
            if (!mappedSensorValue) {
                mappedSensorValue = sensorValue;
            }
            [link.component setValue:mappedSensorValue forKey:link.propertyName];
        }];
    }];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self._linksPerSensorId forKey:kLinksPerSensorIdKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self._linksPerSensorId = [aDecoder decodeObjectForKey:kLinksPerSensorIdKey];
    }
    return self;
}

@end