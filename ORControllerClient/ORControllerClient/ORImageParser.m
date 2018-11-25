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
#import "ORImage_Private.h"
#import "ORPanelDefinitionSensorRegistry.h"
#import "ORObjectIdentifier.h"
#import "ORImageLabelDeferredBinding.h"
#import "ORModelObject_Private.h"
#import "DefinitionElementParserRegister.h"
#import "Definition.h"
#import "ORSensorLinkParser.h"
#import "ORSensor.h"
#import "ORSensorState.h"
#import "ORSensorStatesMapping.h"
#import "XMLEntity.h"

@interface ORImageParser ()

@property (nonatomic, strong, readwrite) ORImage *image;

@end

@implementation ORImageParser

- (instancetype)initWithRegister:(DefinitionElementParserRegister *)aRegister attributes:(NSDictionary *)attributeDict
{
    self = [super initWithRegister:aRegister attributes:attributeDict];
    if (self) {
        [self addKnownTag:LINK];
        self.image = [[ORImage alloc] initWithIdentifier:[[ORObjectIdentifier alloc] initWithStringId:attributeDict[ID]]
                                                     src:attributeDict[SRC]];
        [aRegister.definition addImageName:attributeDict[SRC]];
        self.image.definition = aRegister.definition;
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:INCLUDE] && [LABEL isEqualToString:attributeDict[TYPE]]) {
        // This is a reference to another element, will be resolved later, put a standby in place for now
        
        ORImageLabelDeferredBinding *standby = [[ORImageLabelDeferredBinding alloc] initWithBoundComponentIdentifier:[[ORObjectIdentifier alloc] initWithStringId:attributeDict[REF]]
                                                                                             enclosingObject:self.image];
        [self.depRegister addDeferredBinding:standby];
	}
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
}

- (void)endSensorLinkElement:(ORSensorLinkParser *)parser
{
    if (parser.sensor) {
        [self.depRegister.definition.sensorRegistry registerSensor:parser.sensor linkedToComponent:self.image property:@"src" sensorStatesMapping:parser.sensorStatesMapping];
        
        // Adding all possible image names to definition allows cache to prefetch images if desired
        [[[parser.sensorStatesMapping stateValues] allObjects] enumerateObjectsUsingBlock:^(id imageName, NSUInteger idx, BOOL *stop) {
            [self.depRegister.definition addImageName:imageName];
        }];
    }
}

@synthesize image;

@end