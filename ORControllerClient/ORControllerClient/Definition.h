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
#import <UIKit/UIKit.h>

@class ORTabBar;
@class ORLabel;
@class ORImage;
@class Group;
@class Screen;
@class LocalController;

@class ORPanelDefinitionSensorRegistry;
@class ORController;
@class ORObjectIdentifier;
@class ORButton;
@class ORSwitch;
@class ORSlider;
@class ORColorPicker;
@class ORWebView;
@class ORGroup;
@class ORScreen;
@class ORGesture;

@class ORScreenOrGroupReference;

@protocol ORConsole;

/**
 * This class is responsible for storing some models data (groups, screens, labels, tabBar, images and local controllers)
 */
@interface Definition : NSObject <NSCoding>

/**
 * Clear stored models data(groups, screens, labels and tabBar).
 */
- (void)clearPanelXMLData;

/**
 * Add image name to a array for downloading images into image cache.
 */
- (void)addImageName:(NSString *)imageName;

/**
 * Get a group instance with group identifier.
 */
- (ORGroup *)findGroupByIdentifier:(ORObjectIdentifier *)groupIdentifier;

/**
 * Get a screen instance with screen identifier.
 */
- (ORScreen *)findScreenByIdentifier:(ORObjectIdentifier *)screenIdentifier;

/**
 * Finds the first screen in the model, that is the first screen in the first group that has screens.
 * If no screen exists, returns nil.
 *
 * @return ORScreenOrGroupReference reference to first screen in model or nil if none exist.
 */
- (ORScreenOrGroupReference *)findFirstScreenReference;

/**
 * Finds the first screen in the given group.
 * If that group does not contain any screen, finds the first screen in the whole model.
 * If no screen exists, returns nil.
 *
 * @return ORScreenOrGroupReference reference to first screen in group or in whole model if group does not contain any screen.
 */
- (ORScreenOrGroupReference *)findFirstScreenReferenceStartingInGroup:(ORGroup *)group;

/**
 * Add a group instance for caching.
 */
- (void)addGroup:(ORGroup *)group;

/**
 * Add a screen instance for caching.
 */
- (void)addScreen:(ORScreen *)screen;

/**
 * Add a label instance for caching.
 */
- (void) addLabel:(ORLabel *)label;

/**
 * Get a label instance with label id.
 */
- (ORLabel *)findLabelById:(int)labelId;

- (ORLabel *)findLabelByIdentifier:(ORObjectIdentifier *)identifier;

- (void)addImage:(ORImage *)image;
- (void)addButton:(ORButton *)button;
- (void)addSwitch:(ORSwitch *)sswitch;
- (void)addSlider:(ORSlider *)slider;
- (void)addColorPicker:(ORColorPicker *)colorPicker;
- (void)addWebView:(ORWebView *)webView;

- (void)sendPressCommandForButton:(ORButton *)sender;
- (void)sendShortReleaseCommandForButton:(ORButton *)sender;
- (void)sendLongPressCommandForButton:(ORButton *)sender;
- (void)sendLongReleaseCommandForButton:(ORButton *)sender;

- (void)sendOnForSwitch:(ORSwitch *)sender;
- (void)sendOffForSwitch:(ORSwitch *)sender;

- (void)sendValue:(float)value forSlider:(ORSlider *)sender;

- (void)sendColor:(UIColor *)color forPicker:(ORColorPicker *)sender;

- (void)performGesture:(ORGesture *)sender;

@property (nonatomic, strong, readonly) NSMutableArray *groups;
@property (nonatomic, strong, readonly) NSMutableArray *screens;

@property (nonatomic, strong, readonly) NSSet *labels;

/**
 * Collection of all images used in this panel definition.
 * This includes only standalone images, not the ones used on buttons, sliders, ...
 */
@property (nonatomic, strong, readonly) NSSet *images;

/**
 * Collection of all buttons used in this panel definition.
 */
@property (nonatomic, strong, readonly) NSSet *buttons;

/**
 * Collection of all switches used in this panel definition.
 */
@property (nonatomic, strong, readonly) NSSet *switches;

/**
 * Collection of all sliders used in this panel definition.
 */
@property (nonatomic, strong, readonly) NSSet *sliders;

/**
 * Collection of all color pickers used in this panel definition.
 */
@property (nonatomic, strong, readonly) NSSet *colorPickers;

/**
 * Collection of all web views used in this panel definition.
 */
@property (nonatomic, strong, readonly) NSSet *webViews;

@property (nonatomic, strong) ORTabBar *tabBar;
@property (nonatomic, strong) LocalController *localController;
@property (nonatomic, strong, readonly) NSMutableArray *imageNames;

@property (nonatomic, strong, readonly) ORPanelDefinitionSensorRegistry *sensorRegistry;

/**
 * Controller the Definition is attached to.
 * Values of widgets are only updated when the Definition is attached to a controller.
 * Property is nil when Definition is not attached to any controller.
 */
@property (nonatomic, weak, readonly) ORController *controller;

/**
 * Client application using this Definition.
 */
@property (nonatomic, weak) NSObject<ORConsole> *console;

@property (nonatomic, copy) NSString *dataHash;
@end