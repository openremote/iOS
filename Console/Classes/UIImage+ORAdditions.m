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
#import "UIImage+ORAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (UIImage_ORAdditions)

// Sample code adapted from Apple documentation
// http://developer.apple.com/library/ios/#qa/qa1703/_index.html#//apple_ref/doc/uid/DTS40010193
+ (UIImage*)or_screenshotForWindow:(UIWindow *)window
{
    // Create a graphics context with the target size
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Center the context around the window's anchor point
    CGContextTranslateCTM(context, [window center].x, [window center].y);
    // Apply the window's transform about the anchor point
    CGContextConcatCTM(context, [window transform]);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context,
                          -[window bounds].size.width * [[window layer] anchorPoint].x,
                          -[window bounds].size.height * [[window layer] anchorPoint].y);
    
    // Render the layer hierarchy to the current context
    [[window layer] renderInContext:context];
    
    // Restore the context
    CGContextRestoreGState(context);
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
