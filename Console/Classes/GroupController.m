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
#import "GroupController.h"
#import "NotificationConstant.h"
#import "PaginationController.h"
#import "ORControllerClient/ORScreen.h"
#import "ScreenViewController.h"
#import "UIScreen+ORAdditions.h"
#import "UIImage+ORAdditions.h"
#import "ORControllerConfig.h"
#import "ORControllerClient/Definition.h"

@interface GroupController ()

- (NSArray *)viewControllersForScreens:(NSArray *)screens;
- (void)showErrorView;

@property (weak) PaginationController *currentPaginationController;
@property (strong) UIView *maskView;

@property (nonatomic, strong) PaginationController *portraitPaginationController;
@property (nonatomic, strong) PaginationController *landscapePaginationController;
@property (nonatomic, strong) ErrorViewController *errorViewController;

@property (nonatomic, weak, readwrite) ImageCache *imageCache;

@end

@implementation GroupController

- (id)initWithImageCache:(ImageCache *)aCache group:(ORGroup *)newGroup {
    self = [super init];
	if (self) {
		self.group = newGroup;
        self.imageCache = aCache;
        [self createPortraitPaginationController];
        [self createLandscapePaginationController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdate) name:DefinitionUpdateDidFinishNotification object:nil];
    }
	return self;
}

- (void)didUpdate {
    self.currentPaginationController = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)debugLogGeometry
{
    NSLog(@"========================================");
    NSLog(@"view hierarchy %@ %@ %@ %@", self.view, self.view.superview, self.view.superview.superview, self.view.superview.superview);
    OR_LogAffineTransform(@"View transform", self.view.transform);
    OR_LogPoint(@"View center", self.view.center);
    OR_LogRect(@"View bounds", self.view.bounds);
    OR_LogRect(@"View frame", self.view.frame);
    OR_LogAffineTransform(@"Superview transform", self.view.superview.transform);
    OR_LogPoint(@"Superview center", self.view.superview.center);
    OR_LogRect(@"Superview bounds", self.view.superview.bounds);
    OR_LogRect(@"Superview frame", self.view.superview.frame);
    OR_LogAffineTransform(@"Window transform", self.view.window.transform);
    OR_LogPoint(@"Window center", self.view.window.center);
    OR_LogRect(@"Window bounds", self.view.window.bounds);
    OR_LogRect(@"Window frame", self.view.window.frame);
    NSLog(@"========================================");
}


- (CGRect)getFullFrame
{
    return [UIScreen or_fullFrameForInterfaceOrientation:self.parentViewController.interfaceOrientation];
}

- (ORObjectIdentifier *)groupIdentifier
{
	return self.group.identifier;
}

// Returns an array of ScreenViewControllers for the given Screen objects.
// The view controllers are instantiated by this call, there is no cache in place.
- (NSArray *)viewControllersForScreens:(NSArray *)screens {
	NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:[screens count]];
	
	for (ORScreen *screen in screens) {
		NSLog(@"init screen = %@", screen.name);
		ScreenViewController *viewController = [[ScreenViewController alloc] initWithScreen:screen];
        viewController.imageCache = self.imageCache;
		[viewControllers addObject:viewController];
	}
	return [NSArray arrayWithArray:viewControllers];
}

// Show the view of specified orientation depending on the parameter isLandScape specified.
- (void)showLandscapeOrientation:(BOOL)isLandscape {
	
	NSArray *screens = isLandscape ? [self.group landscapeScreens] : [self.group portraitScreens];

	if (screens.count == 0) {
        // Check if other orientation has screens
        isLandscape = !isLandscape;
        screens = isLandscape ? [self.group landscapeScreens] : [self.group portraitScreens];
        if ([screens count] == 0) {
            // Still no luck, error
            [self showErrorView];
            return;
        }
	}
	
	if (isLandscape) {
        self.currentPaginationController = self.landscapePaginationController;
        self.landscapePaginationController.view.hidden = NO;

        // Resize view to fill screen in appropriate orientation
        self.landscapePaginationController.view.frame = self.view.bounds;

		[[self.portraitPaginationController currentScreenViewController] stopPolling];
        self.portraitPaginationController.view.hidden = YES;
		[[self.landscapePaginationController currentScreenViewController] startPolling];
	} else {
        self.currentPaginationController = self.portraitPaginationController;
        self.portraitPaginationController.view.hidden = NO;

        // Resize view to fill screen in appropriate orientation
        self.portraitPaginationController.view.frame = self.view.bounds;

        [[self.landscapePaginationController currentScreenViewController] stopPolling];
        self.landscapePaginationController.view.hidden = YES;
		[[self.portraitPaginationController currentScreenViewController] startPolling];
	}
    [UIViewController attemptRotationToDeviceOrientation];
}

// Show portrait orientation view.
- (void)showPortrait {
	NSLog(@"show portrait");
	[self showLandscapeOrientation:NO];
}

// Show landscape orientation view.
- (void)showLandscape {
	NSLog(@"show landscape");
	[self showLandscapeOrientation:YES];
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
    [self createLandscapePaginationController];
    [self setupLandscapePaginationController];
    [self setupPortraitPaginationController];
    [self setupLandscapePaginationController];
	[self.navigationController setNavigationBarHidden:YES];

    if (UIInterfaceOrientationIsLandscape(self.parentViewController.interfaceOrientation)) {
		NSLog(@"view did load show landscape");
		[self showLandscape];
    } else {
		NSLog(@"view did load show portrait");
		[self showPortrait];
	}
}

- (void)showErrorView {
    
    // TODO: handle this in an appropriate way
    // This will now crash as assigning view from another VC to us
    // Have an errorHandler object injected -> delegate presentation of error to it
    // Can either present error on DefaultViewController as modal or have some non intrusive way to display error (e.g. temporary notification)
    // can also handle log, send to controller, ...
    // Introduce an "ORError" object, can have levels (fatal, warning, info) and decide what to do with error / how to present
    
	self.errorViewController = [[ErrorViewController alloc] initWithErrorTitle:@"No Screen Found" message:@"Please associate screens with this group of this orientation."];
	self.errorViewController.view.frame = [self getFullFrame];
	self.view = self.errorViewController.view;
}

- (ScreenViewController *)currentScreenViewController {
	return [[self currentPaginationController] currentScreenViewController]; 
}

- (ORScreen *)currentScreen {
	return [self currentScreenViewController].screen;
}

- (ORObjectIdentifier *)currentScreenIdentifier {
	return [self currentScreen].identifier;
}

- (void)startPolling {
	if ([self currentPaginationController].viewControllers.count > 0) {
		[[self currentScreenViewController] startPolling];
		NSLog(@"start polling screen_id = %@", [self currentScreenIdentifier]);
	}
}

- (void)stopPolling {
	for (ScreenViewController *svc in [self currentPaginationController].viewControllers) {
		NSLog(@"stop polling screen_id = %@", svc.screen.identifier);
		[svc stopPolling];
	}
}

- (BOOL)switchToScreen:(ORScreen *)aScreen {
	NSLog(@"switch to screen %@", aScreen.identifier);
	BOOL switchToScreen = [[self currentPaginationController] switchToScreen:aScreen];
    if (!switchToScreen) {
        switchToScreen = [[self otherPaginationController] switchToScreen:aScreen];
        if (switchToScreen) {
            if (self.currentPaginationController == self.portraitPaginationController) {
                [self showLandscape];
            } else {
                [self showPortrait];
            }
        }
    }
    return switchToScreen;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask mask;
    if (self.currentScreen.rotatedScreen != nil) {
        if (self.currentScreen.orientation == ORScreenOrientationLandscape) {
            mask = UIInterfaceOrientationMaskPortrait;
        } else {
            mask = UIInterfaceOrientationMaskLandscape;
        }
    } else if (self.currentScreen == nil) {
        if (self.group.landscapeScreens.count) {
            mask = UIInterfaceOrientationMaskLandscape;
        } else if (self.group.portraitScreens.count) {
            mask = UIInterfaceOrientationMaskPortrait;
        } else {
            mask = UIInterfaceOrientationMaskAll;
        }
    } else if (self.currentScreen.orientation == ORScreenOrientationLandscape) {
        mask =  UIInterfaceOrientationMaskLandscape;
    } else {
        mask =  UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return mask;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIImageView *tmpView = [[UIImageView alloc] initWithImage:[UIImage or_screenshotForWindow:self.view.window]];
    if (self.maskView) {
        [self.maskView removeFromSuperview];
    }
    self.maskView = tmpView;
    [self.view.window addSubview:self.maskView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(self.parentViewController.interfaceOrientation)) {
        if ([self currentScreen].orientation == ORScreenOrientationPortrait) {
            // Going to a landscape version and not currently showing a landscape screen
            ORScreen *landscapeScreen = [self currentScreen].rotatedScreen;
            // If there is a landscape version of the screen, install that one
            if (landscapeScreen) {
                [self showLandscape];
                [[self currentPaginationController] switchToScreen:landscapeScreen];
            }
        }
    } else {
        if ([self currentScreen].orientation == ORScreenOrientationLandscape) {
            // Going to portrait and not currently showing a portrait screen
            ORScreen *portraitScreen = [self currentScreen].rotatedScreen;
            if (portraitScreen) {
                // If there is a portrait version of the screen, install that one
                [self showPortrait];
                [[self currentPaginationController] switchToScreen:portraitScreen];
            }
        }
    }
    [self.maskView removeFromSuperview];
}

- (void)createPortraitPaginationController {
    NSArray *screens = [self.group portraitScreens];
    self.portraitPaginationController = [[PaginationController alloc] initWithGroup:self.group
                                                                             tabBar:self.group.definition.tabBar];
    self.portraitPaginationController.imageCache = self.imageCache;
    [self.portraitPaginationController setViewControllers:[self viewControllersForScreens:screens] isLandscape:NO];
}

- (void)setupPortraitPaginationController {
    [self addChildViewController:self.portraitPaginationController];
    [self.view addSubview:self.portraitPaginationController.view];
}

- (void)createLandscapePaginationController {
    NSArray *screens = [self.group landscapeScreens];
    self.landscapePaginationController = [[PaginationController alloc] initWithGroup:self.group
                                                                              tabBar:self.group.definition.tabBar];
    self.portraitPaginationController.imageCache = self.imageCache;
    [self.landscapePaginationController setViewControllers:[self viewControllersForScreens:screens] isLandscape:YES];
}

- (void)setupLandscapePaginationController {
    [self addChildViewController:self.landscapePaginationController];
    [self.view addSubview:self.landscapePaginationController.view];
}

- (PaginationController *)otherPaginationController
{
    return self.currentPaginationController == self.portraitPaginationController ? self.landscapePaginationController : self.portraitPaginationController;
}

@end