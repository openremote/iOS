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
#import "ORControllerClient/ORGroup.h"
#import "PaginationController.h"
#import "ErrorViewController.h"

@class ImageCache;

/**
 * Control presentation of group view with group model data.
 */
@interface GroupController : UIViewController

@property (nonatomic, strong) ORGroup *group;

/**
 * Construct group controller with group model data and image cache.
 */
- (id)initWithImageCache:(ImageCache *)aCache group:(ORGroup *)newGroup;

/**
 * Start polling of groupController's rendering screenView.
 */
- (void)startPolling;

/**
 * Stop polling of groupController's rendering screenView.
 */
- (void)stopPolling;

/**
 * Switch the rendering screenView of groupController to the screenView for specified screen.
 */
- (BOOL)switchToScreen:(ORScreen *)aScreen;

/**
 * Get the screen model data of current screenViewController in groupController.
 */
- (ORScreen *)currentScreen;

/**
 * Get the identifier of screen model data of current screenViewController in groupController.
 */
- (ORObjectIdentifier *)currentScreenIdentifier;

/**
 * Get the id of group model data of groupController.
 */
- (ORObjectIdentifier *)groupIdentifier;

/**
 * Get the frame of handset's screen and is depending on the current orientation.
 * If current orientation is landscape, the width of returned frame is height of portrait screen 
 * and the height of returned frame is width of portrait screen.
 */
- (CGRect)getFullFrame;

@property (nonatomic, weak, readonly) ImageCache *imageCache;

@end
