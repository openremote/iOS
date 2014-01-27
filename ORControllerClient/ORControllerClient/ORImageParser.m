/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2014, OpenRemote Inc.
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

#import "ORImageParser.h"
#import "ORSensorRegistry.h"
#import "ORObjectIdentifier.h"
#import "ORImageLabelDeferredBinding.h"

#import "DefinitionElementParserRegister.h"
#import "Definition.h"
#import "ORSensorLinkParser.h"
#import "ORSensor.h"
#import "ORSensorState.h"
#import "XMLEntity.h"

@interface ORImageParser ()

@property (nonatomic, strong, readwrite) ORImage *image;

@end

/**
 * XML fragment example:
 * <image id="60"  src = "b.png" style="">
 *    <link type="sensor" ref="1001">
 *       <state name="on" value="on.png" />
 *       <state name="off" value="off.png" />
 *    </link>
 *    <include type="label" ref="64" />
 * </image>
 */
@implementation ORImageParser

- (id)initWithRegister:(DefinitionElementParserRegister *)aRegister attributes:(NSDictionary *)attributeDict
{
    self = [super initWithRegister:aRegister attributes:attributeDict];
    if (self) {
        [self addKnownTag:LINK];
        self.image = [[ORImage alloc] initWithIdentifier:[[ORObjectIdentifier alloc] initWithStringId:[attributeDict objectForKey:ID]]
                                                    name:[attributeDict objectForKey:SRC]];
        [aRegister.definition addImageName:[attributeDict objectForKey:SRC]];
        self.image.definition = aRegister.definition;
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:INCLUDE] && [LABEL isEqualToString:[attributeDict objectForKey:TYPE]]) {
        // This is a reference to another element, will be resolved later, put a standby in place for now
        
        ORImageLabelDeferredBinding *standby = [[ORImageLabelDeferredBinding alloc] initWithBoundComponentId:[[ORObjectIdentifier alloc] initWithStringId:[attributeDict objectForKey:REF]]
                                                                                             enclosingObject:self.image];
        [self.depRegister addDeferredBinding:standby];
	}
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
}

- (void)endSensorLinkElement:(ORSensorLinkParser *)parser
{
    if (parser.sensor) {
        [self.depRegister.definition.sensorRegistry registerSensor:parser.sensor linkedToComponent:self.image property:@"name" sensorStatesMapping:parser.sensorStatesMapping];
        // TODO : linked to name ?
//        self.image.sensor = parser.sensor;

        // TODO: why is this done (here ? maybe in SensorState itself ?)
        
        /*
         TODO: re-implement
         
        for (SensorState *state in parser.sensor.states) {
			[self.depRegister.definition addImageName:state.value];
		}
         */
    }
}

@synthesize image;

@end