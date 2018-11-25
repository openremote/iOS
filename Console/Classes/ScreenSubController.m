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
#import "ScreenSubController.h"
#import "ORControllerClient/ORScreen.h"
#import "ImageCache.h"
#import "ClippedUIImage.h"
#import "ORControllerClient/ORLayoutContainer.h"
#import "LayoutContainerSubController.h"
#import "ORControllerClient/ORBackground.h"
#import "ORControllerClient/ORImage.h"

@interface ScreenSubController() 

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) ORScreen *screen;
@property (nonatomic, strong) NSMutableArray *layoutContainers;

@property (nonatomic, weak) ImageCache *imageCache;

- (void)createView;
- (void)createSubControllersForLayoutContainers;

@end

@implementation ScreenSubController

- (id)initWithImageCache:(ImageCache *)aCache screen:(ORScreen *)aScreen
{
    self = [super init];
    if (self) {
        self.screen = aScreen;
        self.imageCache = aCache;
        [self createView];
        [self createSubControllersForLayoutContainers];
    }    
    return self;
}

- (void)dealloc
{
    self.imageCache = nil;
}

- (void)createSubControllersForLayoutContainers
{
    self.layoutContainers = [NSMutableArray arrayWithCapacity:[self.screen.layouts count]];
    for (ORLayoutContainer *layout in self.screen.layouts) {
        LayoutContainerSubController *ctrl = [[[LayoutContainerSubController subControllerClassForModelObject:layout] alloc] initWithImageCache:self.imageCache layoutContainer:layout];
        [self addChildViewController:ctrl];
        [self.view addSubview:ctrl.view];
        [self.layoutContainers addObject:ctrl];
    }
}

- (void)createView
{
    int screenBackgroundImageViewWidth = (int) [UIScreen mainScreen].bounds.size.width;
    int screenBackgroundImageViewHeight = (int) [UIScreen mainScreen].bounds.size.height;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBackgroundImageViewWidth, screenBackgroundImageViewHeight)];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenBackgroundImageViewWidth, screenBackgroundImageViewHeight)];
    [self.view addSubview:self.imageView];
//    [self.view setUserInteractionEnabled:YES];
    self.view.backgroundColor = [UIColor blackColor];

	if (self.screen.background.image.src) {
		UIImage *backgroundImage = [self.imageCache getImageNamed:self.screen.background.image.src
                                              finalImageAvailable:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setBackgroundImage:image];
            });
        }];
        if (backgroundImage) {
            [self setBackgroundImage:backgroundImage];
        }
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (!backgroundImage) {
        return;
    }

    UIImageView *backgroundImageView = self.imageView;
    CGFloat viewWidth = backgroundImageView.bounds.size.width;
    CGFloat viewHeight = backgroundImageView.bounds.size.height;

    NSLog(@"BackgroundImage's original width:%f, height:%f", backgroundImage.size.width, backgroundImage.size.height);

    // fillscreen is false
    if (self.screen.background.sizeUnit == ORWidgetUnitNotDefined) {
        NSLog(@"BackgroundImage isn't fillScreen");
        
        CGFloat x, y, width, height;
        BOOL clip = NO;

        CGRect drawRect;
        
        // absolute position of screen background.
        if (self.screen.background.positionUnit == ORWidgetUnitLength) {
            if ((self.screen.background.position.x < 0)
                || (self.screen.background.position.x + backgroundImage.size.width > viewWidth)) {
                clip = YES;
                x = ABS(self.screen.background.position.x);
                width = MIN(backgroundImage.size.width - ABS(self.screen.background.position.x), viewWidth);
            } else {
                x = 0.0;
                width = backgroundImage.size.width;
            }
            
            CGFloat yPos = viewHeight - self.screen.background.position.y;
            // y coord is reversed (starts at bottom on iOS)
            
            if ((yPos > viewHeight)
                || (yPos - backgroundImage.size.height < 0)) {
                clip = YES;
                y = ABS(yPos);
                height = MIN(backgroundImage.size.height - ABS(yPos), viewHeight);
            } else {
                y = 0.0;
                height = backgroundImage.size.height;
            }
            
            drawRect = CGRectMake(MAX(self.screen.background.position.x, 0), MIN(yPos - height, viewHeight), width, height);
        }
        // relative position of screen background.
        else {
            CGFloat x, y, width, height;
            BOOL clip = NO;
            
            if (backgroundImage.size.width > viewWidth) {
                x = (backgroundImage.size.width - viewWidth) * (self.screen.background.position.x / 100.0);
                width = viewWidth;
                clip = YES;
            } else {
                x = 0.0;
                width = backgroundImage.size.width;
            }

            if (backgroundImage.size.height > viewHeight) {
                y = (backgroundImage.size.height - viewHeight) * (self.screen.background.position.y / 100.0);
                height = viewHeight;
                clip = YES;
            } else {
                y = 0.0;
                height = backgroundImage.size.height;
            }

            CGFloat xEmptySpace = MAX(0, viewWidth - backgroundImage.size.width);
            CGFloat yEmptySpace = MAX(0, viewHeight - backgroundImage.size.height);
            
            drawRect = CGRectMake(xEmptySpace * (self.screen.background.position.x / 100.0),
                                  yEmptySpace * (self.screen.background.position.y / 100.0),
                                  width, height);
        }
        
        CGImageRef image = [backgroundImage CGImage];
        if (clip) {
            image = CGImageCreateWithImageInRect([backgroundImage CGImage],
                                                 CGRectMake(x, y, width, height));
        }

        [backgroundImageView setImage:[ClippedUIImage imageFromImage:image size:backgroundImageView.bounds.size sourceRect:drawRect]];
    } else {
        // fillscreen is true
        backgroundImageView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        backgroundImageView.image = backgroundImage;
        backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    self.view.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    UIView *parentView = self.parentViewController.view;
    self.view.frame = CGRectMake(0, 0, parentView.bounds.size.width, parentView.bounds.size.height);
}

@synthesize screen;
@synthesize layoutContainers;

@end