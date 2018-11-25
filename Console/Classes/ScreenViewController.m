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
#import "ScreenViewController.h"
#import "ORControllerClient/ORGesture.h"
#import "ORControllerClient/ORScreen.h"
#import "ORUISlider.h"
#import "ScreenSubController.h"

@interface ScreenViewController ()

@property (nonatomic, strong, readwrite) ORScreen *screen;

@property (nonatomic, strong) ScreenSubController *screenSubController;

@property (nonatomic, strong) NSMutableArray *gestureRecognizers;

@end

@implementation ScreenViewController

- (id)initWithScreen:(ORScreen *)aScreen
{
    self = [super init];
    if (self) {
        self.screen = aScreen;
        self.gestureRecognizers = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

- (void)dealloc
{
    [self cleanupGestureRecognizers];
    [self stopPolling];
	self.screenSubController = nil;
    self.imageCache = nil;
    self.screen = nil;
}

// Implement loadView to create a view hierarchy programmatically.
- (void)viewDidLoad {
    self.screenSubController = [[ScreenSubController alloc] initWithImageCache:self.imageCache screen:self.screen];
    [self addChildViewController:self.screenSubController];
    [self.view addSubview:self.screenSubController.view];
    [self setupGestureRecognizers];
}

- (void)startPolling
{
    // TODO: check if anything required here
}

- (void)stopPolling
{
    // TODO: check if anything required here
}

#pragma mark - Gesture Recognizers handling

- (void)setupGestureRecognizers
{
    [self cleanupGestureRecognizers];

    for (ORGesture *gesture in self.screen.gestures) {
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        recognizer.direction = [self convertGestureTypeToGestureRecognizerDirection:gesture.gestureType];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.delegate = self;
        
        [self.view addGestureRecognizer:recognizer];
        [self.gestureRecognizers addObject:recognizer];
    }
}

- (void)cleanupGestureRecognizers
{
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.view removeGestureRecognizer:obj];
    }];
    [self.gestureRecognizers removeAllObjects];
}

- (UISwipeGestureRecognizerDirection)convertGestureTypeToGestureRecognizerDirection:(ORGestureType)gestureType
{
    switch (gestureType) {
        case ORGestureTypeSwipeBottomToTop:
            return UISwipeGestureRecognizerDirectionUp;
        case ORGestureTypeSwipeTopToBottom:
            return UISwipeGestureRecognizerDirectionDown;
        case ORGestureTypeSwipeLeftToRight:
            return UISwipeGestureRecognizerDirectionRight;
        case ORGestureTypeSwipeRightToLeft:
            return UISwipeGestureRecognizerDirectionLeft;
        default:
            return NSNotFound;
    }
    return NSNotFound;
}

- (ORGestureType)convertGestureRecognizerDirectionToGestureType:(UISwipeGestureRecognizerDirection)direction
{
    if (direction == UISwipeGestureRecognizerDirectionUp) {
        return ORGestureTypeSwipeBottomToTop;
    } else if (direction == UISwipeGestureRecognizerDirectionDown) {
        return ORGestureTypeSwipeTopToBottom;
    } else if (direction == UISwipeGestureRecognizerDirectionRight) {
        return ORGestureTypeSwipeLeftToRight;
    } else {
        return ORGestureTypeSwipeRightToLeft;
    }
}

#pragma mark - Gesture Recognizers delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // This makes sure that any swipe gesture do not interfere with sliders operation
    if ([touch.view.superview isKindOfClass:[ORUISlider class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - Gesture Recognizers action

- (void)handleGesture:(UISwipeGestureRecognizer *)recognizer
{
	ORGesture * g = [self.screen gestureForType:[self convertGestureRecognizerDirectionToGestureType:recognizer.direction]];
	if (g) {
        [g perform];
	}
}

@synthesize screen;
@synthesize screenSubController;

@end