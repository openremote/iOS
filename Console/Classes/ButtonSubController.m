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
#import "ButtonSubController.h"
#import "DirectoryDefinition.h"
#import "ORControllerClient/ORButton.h"
#import "ORControllerClient/ORImage.h"
#import "ORControllerClient/ORLabel.h"
#import "ClippedUIImage.h"
#import "NotificationConstant.h"
#import "ImageCache.h"

#import "ControllerVersionSelectAPI.h"

@interface ButtonSubController()

@property (nonatomic, readwrite, strong) UIView *view;
@property (weak, nonatomic, readonly) ORButton *button;

@property (nonatomic, weak) ImageCache *imageCache;

- (void)controlButtonUp:(id)sender;
- (void)controlButtonDown:(id)sender;

- (void)setClippedImage:(UIImage *)uiImage forState:(UIControlState)state;

@end

@implementation ButtonSubController

- (id)initWithImageCache:(ImageCache *)aCache component:(ORWidget *)aComponent
{
    self = [super initWithImageCache:aCache component:aComponent];
    if (self) {
        UIButton *uiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [uiButton addTarget:self action:@selector(controlButtonDown:) forControlEvents:UIControlEventTouchDown];	
        [uiButton addTarget:self action:@selector(controlButtonUp:) forControlEvents:UIControlEventTouchUpOutside];	
        [uiButton addTarget:self action:@selector(controlButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        
        /* Observing the frame so the displayed image can be resized to appear centered in the button */
        [uiButton addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
        uiButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        uiButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [uiButton setTitle:self.button.label.text forState:UIControlStateNormal];
        self.view = uiButton;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    /*
     * Resize the images appropriately for the new button dimensions, making sure they are centered, clipped and not resized.
     * Using imageEdgeInsets would be an easier solution to accomplish this but is not available for the background image.
     */
    if (object == self.view) {        
        if (self.button.unpressedImage) {
            UIImage *uiImage = [self.imageCache getImageNamed:self.button.unpressedImage.src finalImageAvailable:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setClippedImage:image forState:UIControlStateNormal];
                });
            }];
            if (uiImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setClippedImage:uiImage forState:UIControlStateNormal];
                });
            }
            
            UIImage *uiImagePressed = [self.imageCache getImageNamed:self.button.pressedImage.src finalImageAvailable:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setClippedImage:image forState:UIControlStateHighlighted];
                });
            }];
            if (uiImagePressed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setClippedImage:uiImagePressed forState:UIControlStateHighlighted];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIButton *uiButton = (UIButton *)self.view;
                UIImage *buttonImage = [[UIImage imageNamed:@"button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:29];
                [uiButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
            });
        }
    }
}

- (void)dealloc
{
    [self.view removeObserver:self forKeyPath:@"frame"];
}

- (ORButton *)button
{
    return (ORButton *)self.component;
}

- (void)controlButtonUp:(id)sender
{
    [self.button depress];
}

- (void)controlButtonDown:(id)sender
{
    [self.button press];
}

#pragma mark - Helper

- (void)setClippedImage:(UIImage *)uiImage forState:(UIControlState)state
{
    UIButton *uiButton = (UIButton *)self.view;
    ClippedUIImage *clippedUIImage = [[ClippedUIImage alloc] initWithUIImage:uiImage
                                                                withinUIView:uiButton
                                                            imageAlignToView:IMAGE_ABSOLUTE_ALIGN_TO_VIEW];
    [uiButton setBackgroundImage:clippedUIImage forState:state];
}

@synthesize view;

@end