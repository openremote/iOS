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
#import "PaginationController.h"
#import "GroupController.h"
#import "ORControllerClient/ORObjectIdentifier.h"
#import "ORControllerClient/ORScreen.h"
#import "ORControllerClient/ORTabBar.h"
#import "ORControllerClient/ORTabBarItem.h"
#import "ORControllerClient/ORImage.h"
#import "ORControllerClient/ORLabel.h"
#import "ORControllerClient/Definition.h"
#import "ORControllerClient/ORNavigation.h"
#import "ORControllerClient/ORScreenNavigation.h"
#import "ORControllerClient/ORConsole.h"
#import "ORConsoleSettingsManager.h"
#import "ORControllerConfig.h"
#import "ORScrollView.h"

#define PAGE_CONTROL_HEIGHT ((CGFloat)20)
#define kTabBarHeight ((CGFloat) 49.0)

@interface PaginationController ()

@property (nonatomic, strong) ORGroup *group;
@property (nonatomic, strong) ORTabBar *tabBar;
@property (nonatomic, weak) UITabBar *uiTabBar;
@property (nonatomic, readwrite) NSUInteger selectedIndex;

@property (nonatomic) BOOL inRotation;
@end

@implementation PaginationController

- (id)initWithGroup:(ORGroup *)aGroup tabBar:(ORTabBar *)aTabBar
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.group = aGroup;
        if (self.group.tabBar) {
            self.tabBar = self.group.tabBar;
        } else {
            self.tabBar = aTabBar;
        }
    }
    return self;
}

- (void)dealloc
{
    self.uiTabBar.delegate = nil;
    self.uiTabBar = nil;
    self.imageCache = nil;
}

/**
 * Assign the ScreenViewController array to paginationController with landscape boolean value.
 */
- (void)setViewControllers:(NSArray *)newViewControllers isLandscape:(BOOL)isLandscapeOrientation {
	self.isLandscape = isLandscapeOrientation;

	for (UIView *view in [self.scrollView subviews]) {
		[view removeFromSuperview];
	}
	
	self.viewControllers = newViewControllers;
	
	//Recover last screen
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    ORObjectIdentifier *lastScreenIdenfitier = [[ORObjectIdentifier alloc] initWithStringId:[userDefaults objectForKey:@"lastScreenId"]];
	NSLog(@"last screen id = %@", lastScreenIdenfitier);
	
	if (lastScreenIdenfitier) {
		for (unsigned int i = 0; i < [self.viewControllers count]; i++) {
			if ([lastScreenIdenfitier isEqual:[(ORScreen *)[self.viewControllers[i] screen] identifier]]) {
//				UIViewController *vc = [viewControllers objectAtIndex:i];
                // TODO: ebr : check why this is ???
//				vc.view.bounds = scrollView.bounds;
                self.selectedIndex = i;
				break;
			}
		}
	} else {
        self.selectedIndex = 0;
	}
}

- (BOOL)switchToFirstScreen {
	return [self switchToScreen:((ScreenViewController *) self.viewControllers[0]).screen];
}

- (ScreenViewController *)currentScreenViewController {
    if (self.viewControllers.count) {
        return self.viewControllers[self.selectedIndex];
    } else {
        return nil;
    }
}

- (void)initView {
	self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * [self.viewControllers count], self.view.frame.size.height);
	self.pageControl.numberOfPages = [self.viewControllers count];
	[self updateViewForCurrentPage];
}

- (void)updateView {
	self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * [self.viewControllers count], self.view.frame.size.height);
	self.pageControl.numberOfPages = [self.viewControllers count];
	[self updateViewForCurrentPageAndBothSides];
}

//Return YES if succuess, without animation.
- (BOOL)switchToScreen:(ORScreen *)aScreen {
	return [self switchToScreen:aScreen withAnimation:NO];
}

//Return YES if succuess
- (BOOL)switchToScreen:(ORScreen *)aScreen withAnimation:(BOOL) withAnimation {
	int index = -1;
	for (int i = 0; i< self.viewControllers.count; i++) {
		ScreenViewController *svc = (ScreenViewController *) self.viewControllers[(NSUInteger) i];
		if ([svc.screen.identifier isEqual:aScreen.identifier]) {
			index = i;
			break;
		}
	}
	if (index != -1) {//found screen in current orientation
        self.selectedIndex = (NSUInteger) index;
		NSLog(@"switch to screen index = %lu, id = %@ animation=%d", (unsigned long)self.selectedIndex, aScreen.identifier, withAnimation);
		[self.pageControl setCurrentPage:self.selectedIndex];
		[self scrollToSelectedViewWithAnimation:withAnimation];
	} else {
		// not found, may be in the opposite orientation, or a invalid screenId.
		return NO;
	}
	
    [self updateTabBarItemSelection];
	return YES;
}

// Save last screen's id while switching screen view for recovery of lastScreenView in RootViewController.
- (void)saveLastScreen {
	if (self.selectedIndex < self.viewControllers.count) {
		ORObjectIdentifier *lastScreenIdentifier = ((ScreenViewController *) self.viewControllers[self.selectedIndex]).screen.identifier;
		if (!lastScreenIdentifier) {
			return;
		}
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:[lastScreenIdentifier stringValue] forKey:@"lastScreenId"];
	}
}

// Refresh the current screenView.
- (void)updateViewForCurrentPage {
	[self initViewForPage:self.selectedIndex];
	self.pageControl.currentPage = self.selectedIndex;
    [self updateTabBarItemSelection];
}

// Refresh the current screenView, previous screenView and next screenView.
- (void)updateViewForCurrentPageAndBothSides {
	[self updateViewForPage:self.selectedIndex - 1];
	[self updateViewForPage:self.selectedIndex];
	[self updateViewForPage:self.selectedIndex + 1];
    [self updateTabBarItemSelection];

	[self.pageControl setCurrentPage:self.selectedIndex];
	[self saveLastScreen];
}

// Init current screen view of paginationController with specified page index.
- (void)initViewForPage:(NSUInteger)page {
	if (page >= [self.viewControllers count]) return;
	UIViewController *controller = self.viewControllers[page];
	
	if (controller.view.superview != self.scrollView) {
		CGRect frame = self.scrollView.bounds;
		frame.origin.x = self.view.frame.size.width * page;
		[controller.view setFrame:frame];
		self.scrollView.contentOffset = CGPointMake(frame.origin.x, 0);
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
	}
	
	if (page == self.selectedIndex) {
		[((ScreenViewController *)controller) startPolling];
	} else {
		[((ScreenViewController *)controller) stopPolling];
	}
}

// Refresh the screenView page index specified.
- (void)updateViewForPage:(NSUInteger)page {
	if (page >= [self.viewControllers count]) return;
	UIViewController *controller = self.viewControllers[page];
    
	CGRect frame = self.scrollView.bounds;
	frame.origin.x = self.view.frame.size.width * page;
	[controller.view setFrame:frame];
	if (controller.view.superview != self.scrollView) {
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
	}
	
	if (page == self.selectedIndex) {
		[((ScreenViewController *)controller) startPolling];
	} else {
		[((ScreenViewController *)controller) stopPolling];
	}	
}

//if you have changed *selectedIndex* then calling this method will scroll to that seleted view immediately
- (void)scrollToSelectedViewWithAnimation:(BOOL)withAnimation {
	
	//HACK: clear 2nd view, it's a hack, beause 2nd view always cover 1st view.
	//TODO: should fix this hack.
	if (!withAnimation && self.selectedIndex == 0 && self.viewControllers.count > 1) {
		UIViewController *vc = self.viewControllers[1];
		[vc.view removeFromSuperview];
	}
	
	[self updateViewForCurrentPage];
	CGRect frame = self.scrollView.bounds;

	frame.origin.x = self.view.frame.size.width * self.selectedIndex;
	frame.origin.y = 0;
	[self.scrollView scrollRectToVisible:frame animated:withAnimation];
}

- (void)loadView {
	[super loadView];
	self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

	self.scrollView = [[ORScrollView alloc] init];
	self.scrollView.delegate = self;
	self.scrollView.pagingEnabled = YES;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
	self.scrollView.opaque = YES;
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    // Scroll view takes whole screen height, even if a tab bar is present
    // This is so the rendering on iOS console is in sync with how the modeler presents it
	self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	self.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
	self.pageControl = [[UIPageControl alloc] init];
	if (self.viewControllers.count > 1) {
		self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		self.pageControl.frame = CGRectMake(0, self.view.frame.size.height - PAGE_CONTROL_HEIGHT - (self.tabBar?kTabBarHeight:0.0f), self.view.frame.size.width, PAGE_CONTROL_HEIGHT);
		self.pageControl.backgroundColor = [UIColor clearColor];
		self.pageControl.opaque = NO;
		[self.pageControl addTarget:self action:@selector(pageControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.pageControl];
	}
    // Tab bar added latest so it sits on top of other views
    if (self.tabBar) {
        UITabBar *tmpBar = [[UITabBar alloc] initWithFrame:CGRectZero];
        self.uiTabBar = tmpBar;
        self.uiTabBar.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.uiTabBar];
        [self.view addConstraints:@[
                [NSLayoutConstraint constraintWithItem:self.uiTabBar
                                             attribute:NSLayoutAttributeBottom
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.view
                                             attribute:NSLayoutAttributeBottom
                                            multiplier:1
                                              constant:0],
                [NSLayoutConstraint constraintWithItem:self.uiTabBar
                                             attribute:NSLayoutAttributeLeading
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.view
                                             attribute:NSLayoutAttributeLeading
                                            multiplier:1
                                              constant:0],
                [NSLayoutConstraint constraintWithItem:self.uiTabBar
                                             attribute:NSLayoutAttributeTrailing
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:self.view
                                             attribute:NSLayoutAttributeTrailing
                                            multiplier:1
                                              constant:0],
                [NSLayoutConstraint constraintWithItem:self.uiTabBar
                                             attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                             attribute:NSLayoutAttributeNotAnAttribute
                                            multiplier:1
                                              constant:kTabBarHeight]
        ]];
        NSMutableArray *tmpItems = [NSMutableArray arrayWithCapacity:[self.tabBar.items count]];
        // Not using fast iteration but standard for loop to have access to object index
        for (unsigned int i = 0; i < [self.tabBar.items count]; i++) {
            ORTabBarItem *item = self.tabBar.items[i];
            UITabBarItem *uiItem = [[UITabBarItem alloc] initWithTitle:item.label.text image:nil tag:i];
            UIImage *itemImage = [self.imageCache getImageNamed:item.image.src finalImageAvailable:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    uiItem.image = image;
                });
            }];
            if (itemImage) {
                uiItem.image = itemImage;
                uiItem.selectedImage = itemImage;
            }
            [tmpItems addObject:uiItem];
        }
        self.uiTabBar.items = tmpItems;
        self.uiTabBar.delegate = self;
    }

    [self initView];
}

- (void)didReceiveMemoryWarning {
	// Our view will be released when it has no superview, so set these references to nil
	if (self.view.superview == nil) {
		self.scrollView = nil;
		self.pageControl = nil;
	}
	
	[super didReceiveMemoryWarning];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // don't handle scrolling while rotating, it messes up selectedIndex
    if (!self.inRotation) {
        // Switch the indicator when more than 50% of the previous/next page is visible
        int calculatedIndex = (int) (floor((self.scrollView.contentOffset.x - self.view.frame.size.width / 2) / self.view.frame.size.width) + 1);
        self.selectedIndex = MIN(MAX(0, calculatedIndex), [self.viewControllers count] - 1);
        [self updateViewForCurrentPageAndBothSides];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)s {
	//HACK: correct hacked larger ContentSize back to normal.
	//TODO: should fix this hack.
// EBR - 20111024 - Not sure if this is of any use
//	[scrollView setContentSize:CGSizeMake(frameWidth * pageControl.numberOfPages, frameHeight)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)pageControlValueDidChange:(id)sender {
    self.selectedIndex = self.pageControl.currentPage;
	[self updateViewForCurrentPageAndBothSides];
	
	CGRect frame = self.scrollView.bounds;
	frame.origin.x = self.view.frame.size.width * self.selectedIndex;
	frame.origin.y = 0;
	[self.scrollView scrollRectToVisible:frame animated:YES];

	// DENNIS: Maybe you want to make sure that the user can't interact with the scroll view while it is animating.
	//[scrollView setUserInteractionEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * [self.viewControllers count], self.view.frame.size.height);
}


/**
 * Verify that the screen that is current displayed is the target of the navigation of an item in the tab bar.
 * If it is, select that item. Items are search in order and the first one matching is selected.
 * If no matching item is found, selection is cleared.
 */
- (void)updateTabBarItemSelection
{
    NSUInteger selected = NSNotFound;
    
    for (ORTabBarItem *tabBarItem in self.tabBar.items) {
		if (tabBarItem.navigation && tabBarItem.navigation.navigationType == ORNavigationTypeToGroupOrScreen) {
            ORScreenNavigation *navigation = ((ORScreenNavigation *)tabBarItem.navigation);
            if ([self.group.identifier isEqual:navigation.destinationGroup.identifier]) {
                if (!navigation.destinationScreen || [navigation.destinationScreen.identifier isEqual: [self currentScreenViewController].screen.identifier]) {
                    selected = [self.tabBar.items indexOfObject:tabBarItem];
                    break;
                }
			}
		}
    }
    if (selected != NSNotFound) {
        self.uiTabBar.selectedItem = self.uiTabBar.items[selected];
    }
    else {
        self.uiTabBar.selectedItem = nil;
    }
}

#pragma mark UITabBar delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    ORTabBarItem *tabBarItem = self.tabBar.items[item.tag];
	if (tabBarItem && tabBarItem.navigation) {
        [self.group.definition.console navigate:tabBarItem.navigation];
	}
    
    // ! Do not do anything anymore here as after the navigation, self will be released if we moved to a different group
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.inRotation = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.inRotation = NO;
    [self initView];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
