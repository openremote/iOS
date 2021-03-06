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
#import "AbsoluteLayoutContainerSubController.h"
#import "ORControllerClient/ORAbsoluteLayoutContainer.h"
#import "ORControllerClient/ORWidget.h"
#import "ComponentSubController.h"

@interface AbsoluteLayoutContainerSubController()

// TODO: have properties from superclass in specific .h
@property (nonatomic, strong) ORLayoutContainer *layoutContainer;
@property (nonatomic, weak) ORControllerConfig *controller;
@property (nonatomic, weak) ImageCache *imageCache;

@property (nonatomic, strong) ComponentSubController *componentSubController;

@end

@implementation AbsoluteLayoutContainerSubController

- (id)initWithImageCache:(ImageCache *)aCache layoutContainer:(ORLayoutContainer *)aLayoutContainer
{
    self = [super initWithImageCache:aCache layoutContainer:aLayoutContainer];
    if (self) {
        ORWidget *widget = ((ORAbsoluteLayoutContainer *)aLayoutContainer).widget;
        self.componentSubController = [[[ComponentSubController subControllerClassForModelObject:widget] alloc] initWithImageCache:aCache component:widget];
        self.componentSubController.view.frame = CGRectMake(self.layoutContainer.left, self.layoutContainer.top, self.layoutContainer.width, self.layoutContainer.height);
    }
    
    return self;
}


- (UIView *)view
{
    return self.componentSubController.view;
}

@synthesize layoutContainer;
@synthesize componentSubController;

@end
