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
#import "ORSensorRegistry.h"

@class ORDeviceSensor;

/**
 * Class is responsible to manage the list of known sensors
 * and the ORDeviceSensor dependency on those sensors.
 */
@interface ORDeviceModelSensorRegistry : ORSensorRegistry

/**
 * Adds a sensor to the registry, keeping track of the relationship to the component.
 * If sensor exists not linked to that component, dependency is added.
 * If sensor exists and component is already linked to it, mapping is updated with new value.
 *
 * @param sensor Sensor linked to component
 * @param component Component sensor is linked to and will update
 * TODO: for now, component is an NSObject and not a Component because of Label vs ORLabel dichotomy, should fix in the future.
 * @param propertyName name of property on component whose value is updated by sensor
 * @param mapping sensor states mapping to use to translate sensor value when assigned to component property
 */
- (void)registerSensor:(ORSensor *)sensor linkedToORDeviceSensor:(ORDeviceSensor *)deviceSensor;

@end
