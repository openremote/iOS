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
#import "Definition.h"
#import "ORGroup.h"
#import "ORScreen.h"
#import "ORPanelDefinitionSensorRegistry.h"
#import "ORController.h"
#import "ORObjectIdentifier.h"
#import "ORLabel.h"
#import "ORImage.h"
#import "ORScreenOrGroupReference.h"

// Import of private is required even if not directly used to make sure setController: is synthesized
#import "Definition_Private.h"

#define kGroupsKey          @"Groups"
#define kScreensKey         @"Screens"
#define kLabelsKey          @"Labels"
#define kImagesKey          @"Images"
#define kButtonsKey         @"Buttons"
#define kSwitchesKey        @"Switches"
#define kSlidersKey         @"Sliders"
#define kColorPickersKey    @"ColorPickers"
#define kWebViewsKey        @"WebViews"
#define kImageNamesKey      @"ImageNames"
#define kSensorRegistryKey  @"SensorRegistry"
#define kDataHashKey        @"DataHash"

@interface Definition ()

@property (nonatomic, strong, readwrite) NSMutableArray *groups;
@property (nonatomic, strong, readwrite) NSMutableArray *screens;

/**
 * All the labels in this panel configuration
 *
 * Implementation note: this is currently filled in by parser during parsing
 */
@property (nonatomic, strong) NSMutableArray *_labels;

@property (nonatomic, strong) NSMutableArray *_images;
@property (nonatomic, strong) NSMutableArray *_buttons;
@property (nonatomic, strong) NSMutableArray *_switches;
@property (nonatomic, strong) NSMutableArray *_sliders;
@property (nonatomic, strong) NSMutableArray *_colorPickers;
@property (nonatomic, strong) NSMutableArray *_webViews;

@property (nonatomic, strong, readwrite) ORPanelDefinitionSensorRegistry *sensorRegistry;

@property (nonatomic, strong, readwrite) NSMutableArray *imageNames;

@end

@implementation Definition

- (id)init
{			
    self = [super init];
    if (self) {
        self.groups = [NSMutableArray array];
		self.screens = [NSMutableArray array];
        self._labels = [NSMutableArray array];
        self._images = [NSMutableArray array];
        self._buttons = [NSMutableArray array];
        self._switches = [NSMutableArray array];
        self._sliders = [NSMutableArray array];
        self._colorPickers = [NSMutableArray array];
        self._webViews = [NSMutableArray array];
		self.imageNames = [NSMutableArray array];
        self.sensorRegistry = [[ORPanelDefinitionSensorRegistry alloc] init];
	}
	return self;
}

- (ORGroup *)findGroupByIdentifier:(ORObjectIdentifier *)groupIdentifier
{
	for (ORGroup *g in self.groups) {
		if ([g.identifier isEqual:groupIdentifier]) {
			return g;
		}
	}
	return nil;
}

- (ORScreen *)findScreenByIdentifier:(ORObjectIdentifier *)screenIdentifier
{
	for (ORScreen *tempScreen in self.screens) {
        if ([tempScreen.identifier isEqual:screenIdentifier]) {
            return tempScreen;
        }
    }
    return nil;
}

- (ORScreenOrGroupReference *)findFirstScreenReference
{
    for (ORGroup *group in self.groups) {
        for (ORScreen *screen in group.screens) {
            return [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:group.identifier screenIdentifier:screen.identifier];
        }
    }
    return nil;
}

- (ORScreenOrGroupReference *)findFirstScreenReferenceStartingInGroup:(ORGroup *)group
{
    for (ORScreen *screen in group.screens) {
        return [[ORScreenOrGroupReference alloc] initWithGroupIdentifier:group.identifier screenIdentifier:screen.identifier];
    }
    return [self findFirstScreenReference];
}

- (void)addGroup:(ORGroup *)group {
	for (int i = 0; i < self.groups.count; i++) {
		ORGroup *tempGroup = [self.groups objectAtIndex:i];
		if ([tempGroup.identifier isEqual:group.identifier]) {
			[self.groups replaceObjectAtIndex:i withObject:group];
			return;
		}
	}
	[self.groups addObject:group];
}

- (void)addScreen:(ORScreen *)screen {
	for (int i = 0; i < self.screens.count; i++) {
		ORScreen *tempScreen = [self.screens objectAtIndex:i];
		if ([tempScreen.identifier isEqual:screen.identifier]) {
			[self.screens replaceObjectAtIndex:i withObject:screen];
			return;
		}
	}
	[self.screens addObject:screen];
}

- (void)addLabel:(ORLabel *)label {
    // TODO: why can this happen, adding multiple time a label with same id ??? -> document or assert can't happen
	for (int i = 0; i < self._labels.count; i++) {
		ORLabel *tempLabel = [self._labels objectAtIndex:i];
		if ([tempLabel.identifier isEqual:label.identifier]) {
            [self._labels replaceObjectAtIndex:i withObject:label];
            
            // TODO: handle sensorRegistry operation for this specific case ???
            
			return;
		}
	}
    [self._labels addObject:label];
}

- (ORLabel *)findLabelById:(int)labelId
{
    return [self findLabelByIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:labelId]];
}

- (ORLabel *)findLabelByIdentifier:(ORObjectIdentifier *)identifier
{
	for (ORLabel *tempLabel in self._labels) {
		if ([tempLabel.identifier isEqual:identifier]) {
			return tempLabel;
		}
	}
	return nil;
}

- (void)addImage:(ORImage *)image
{
    [self._images addObject:image];
}

- (void)addImageName:(NSString *)imageName {
	for (NSString *name in self.imageNames) {
		// avoid duplicated
		if ([name isEqualToString:imageName]) {
			return;
		}
	}
	if (imageName) {
		[[self imageNames] addObject:imageName];	
	}
}

- (void)addButton:(ORButton *)button
{
    [self._buttons addObject:button];
}

- (void)addSwitch:(ORSwitch *)sswitch
{
    [self._switches addObject:sswitch];
}

- (void)addSlider:(ORSlider *)slider
{
    [self._sliders addObject:slider];
}

- (void)addColorPicker:(ORColorPicker *)colorPicker
{
    [self._colorPickers addObject:colorPicker];
}

- (void)addWebView:(ORWebView *)webView
{
    [self._webViews addObject:webView];
}

- (void)clearPanelXMLData
{
    [self.groups removeAllObjects];
    [self.screens removeAllObjects];
    [self._labels removeAllObjects];
    [self.sensorRegistry clearRegistry];
    [self.imageNames removeAllObjects];
    [self._images removeAllObjects];
    [self._buttons removeAllObjects];
    [self._switches removeAllObjects];
    [self._sliders removeAllObjects];
    [self._colorPickers removeAllObjects];
    [self._webViews removeAllObjects];
    self.tabBar = nil;
}

- (NSSet *)labels
{
    return [NSSet setWithArray:self._labels];
}

- (NSSet *)images
{
    return [NSSet setWithArray:self._images];
}

- (NSSet *)buttons
{
    return [NSSet setWithArray:self._buttons];
}

- (NSSet *)switches
{
    return [NSSet setWithArray:self._switches];
}

- (NSSet *)sliders
{
    return [NSSet setWithArray:self._sliders];
}

- (NSSet *)colorPickers
{
    return [NSSet setWithArray:self._colorPickers];
}

- (NSSet *)webViews
{
    return [NSSet setWithArray:self._webViews];
}

- (void)sendPressCommandForButton:(ORButton *)sender
{
    [self.controller sendPressCommandForButton:sender];
}

- (void)sendShortReleaseCommandForButton:(ORButton *)sender
{
    [self.controller sendShortReleaseCommandForButton:sender];
}

- (void)sendLongPressCommandForButton:(ORButton *)sender
{
    [self.controller sendLongPressCommandForButton:sender];
}

- (void)sendLongReleaseCommandForButton:(ORButton *)sender
{
    [self.controller sendLongReleaseCommandForButton:sender];
}

- (void)sendOnForSwitch:(ORSwitch *)sender
{
    [self.controller sendOnForSwitch:sender];
}

- (void)sendOffForSwitch:(ORSwitch *)sender
{
    [self.controller sendOffForSwitch:sender];
}

- (void)sendValue:(float)value forSlider:(ORSlider *)sender
{
    [self.controller sendValue:value forSlider:sender];
}

- (void)sendColor:(UIColor *)color forPicker:(ORColorPicker *)sender
{
    [self.controller sendColor:color forPicker:sender];
}

- (void)performGesture:(ORGesture *)sender
{
    [self.controller performGesture:sender];
}

/*
TODO:
 
 Idea would be that all above methods can check for local vs remote protocol and direct appropriately
 to either self.controller or self.console
 Implementation can be based on something similar to below methods.
 
 With regard to supporting different API version
 Idea is that code in the console is always implementing latest "local controller API".
 There will be parsing code for different API versions and it should always be maintained to
 understand that particular version but "interface" to latest local controller API.


- (void)sendCommandRequest:(NSString *)commandType {
    NSLog(@"commandType %@", commandType);
    
	// Check for local command first
	NSArray *localCommands = [self localCommandsForCommandType:commandType];
    if (localCommands && ([localCommands count] > 0)) {
        [self.clientSideRuntime executeCommands:localCommands commandType:commandType];
	} else {
        @throw [[NSException alloc] initWithName:NSInternalInconsistencyException
                                          reason:@"Only local commands should be handeld this way"
                                        userInfo:@{ @"commandType" : commandType }];
	}
}

- (NSArray *)localCommandsForCommandType:(NSString *)commandType
{
	return [self.controller.definition.localController commandsForComponentIdentifier:self.component.identifier action:commandType];
}

*/


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.groups forKey:kGroupsKey];
    [aCoder encodeObject:self.screens forKey:kScreensKey];
    [aCoder encodeObject:self._labels forKey:kLabelsKey];
    [aCoder encodeObject:self._images forKey:kImagesKey];
    [aCoder encodeObject:self._buttons forKey:kButtonsKey];
    [aCoder encodeObject:self._switches forKey:kSwitchesKey];
    [aCoder encodeObject:self._sliders forKey:kSlidersKey];
    [aCoder encodeObject:self._colorPickers forKey:kColorPickersKey];
    [aCoder encodeObject:self._webViews forKey:kWebViewsKey];
    [aCoder encodeObject:self.imageNames forKey:kImageNamesKey];
    [aCoder encodeObject:self.sensorRegistry forKey:kSensorRegistryKey];
    [aCoder encodeObject:self.dataHash forKey:kDataHashKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init]) {
        self.groups = [aDecoder decodeObjectForKey:kGroupsKey];
        self.screens = [aDecoder decodeObjectForKey:kScreensKey];
        self._labels = [aDecoder decodeObjectForKey:kLabelsKey];
        self._images = [aDecoder decodeObjectForKey:kImagesKey];
        self._buttons = [aDecoder decodeObjectForKey:kButtonsKey];
        self._switches = [aDecoder decodeObjectForKey:kSwitchesKey];
        self._sliders = [aDecoder decodeObjectForKey:kSlidersKey];
        self._colorPickers = [aDecoder decodeObjectForKey:kColorPickersKey];
        self._webViews = [aDecoder decodeObjectForKey:kWebViewsKey];
        self.imageNames = [aDecoder decodeObjectForKey:kImageNamesKey];
        self.sensorRegistry = [aDecoder decodeObjectForKey:kSensorRegistryKey];
        self.dataHash = [aDecoder decodeObjectForKey:kDataHashKey];
    }
    return self;
}

@synthesize groups, screens, tabBar, localController, imageNames, controller;

@end