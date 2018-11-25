/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2018, OpenRemote Inc.
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
#import "UIViewController+ORAdditions.h"
#import "AppDelegate.h"

@implementation UIViewController (ORAdditions)

- (BOOL)hasTopNotch {
    UIWindow *window = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) mainWindow];
    if (@available(iOS 11.0, *)) {
        if ([window respondsToSelector:@selector(safeAreaInsets)]) {
            return window.safeAreaInsets.top > 20;
        }
    }
    return NO;
}

- (CGFloat)safeAreaTop {
    UIWindow *window = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) mainWindow];
    if (@available(iOS 11.0, *)) {
        if ([window respondsToSelector:@selector(safeAreaInsets)]) {
            return window.safeAreaInsets.top;
        }
    }
    return 0;
}

- (CGFloat)safeAreaBottom {
    UIWindow *window = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) mainWindow];
    if (@available(iOS 11.0, *)) {
        if ([window respondsToSelector:@selector(safeAreaInsets)]) {
            return window.safeAreaInsets.bottom;
        }
    }
    return 0;
}

@end
