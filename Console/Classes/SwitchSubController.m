/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2014, OpenRemote Inc.
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
#import "SwitchSubController.h"
#import "ORControllerClient/ORSwitch.h"
#import "ORControllerClient/ORImage.h"
#import "ImageCache.h"
#import "SensorStatusCache.h"
#import "NotificationConstant.h"

static void * const SwitchSubControllerKVOContext = (void*)&SwitchSubControllerKVOContext;

@interface SwitchSubController()

@property (nonatomic, strong) UIButton *view;
@property (weak, nonatomic, readonly) ORSwitch *sswitch;
@property (nonatomic) BOOL canUseImage;

@property (nonatomic, strong) UIImage *onUIImage;
@property (nonatomic, strong) UIImage *offUIImage;

@property (nonatomic, weak) ImageCache *imageCache;

- (void)stateChanged:(id)sender;

@end

@implementation SwitchSubController

// TODO: review this "canUseImage" thing, possible to only have 1 of the 2 images
// also possible to have image names but never resolve to image

- (id)initWithImageCache:(ImageCache *)aCache component:(ORWidget *)aComponent
{
    self = [super initWithImageCache:aCache component:aComponent];
    if (self) {
        self.view = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *onImage = self.sswitch.onImage.src;
        NSString *offImage = self.sswitch.offImage.src;
        self.canUseImage = onImage && offImage;

        if (self.canUseImage) {
            self.onUIImage = [self.imageCache getImageNamed:onImage finalImageAvailable:^(UIImage *image) {
                self.onUIImage = image;
                [self updateSwitchUI];
            }];
            if (self.onUIImage) {
                [self updateSwitchUI];
            }
            self.offUIImage = [self.imageCache getImageNamed:offImage finalImageAvailable:^(UIImage *image) {
                self.offUIImage = image;
                [self updateSwitchUI];
            }];
            if (self.offUIImage) {
                [self updateSwitchUI];
            }
            [self.view.imageView setContentMode:UIViewContentModeCenter];
        } else {
            UIImage *buttonImage = [[UIImage imageNamed:@"button.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:29];
            [self.view setBackgroundImage:buttonImage forState:UIControlStateNormal];
            self.view.titleLabel.font = [UIFont boldSystemFontOfSize:13];
            self.view.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [self updateSwitchUI];
        }

        [self.sswitch addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:SwitchSubControllerKVOContext];
    }
    return self;
}

- (void)dealloc
{
    [self.sswitch removeObserver:self forKeyPath:@"state"];
}

- (ORSwitch *)sswitch
{
    return (ORSwitch *)self.component;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == SwitchSubControllerKVOContext) {
        if ([@"state" isEqualToString:keyPath]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateSwitchUI];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateSwitchUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.canUseImage) {
            [self.view setImage:(self.sswitch.state?self.onUIImage:self.offUIImage) forState:UIControlStateNormal];
        } else {
            [self.view setTitle:self.sswitch.state?@"ON":@"OFF" forState:UIControlStateNormal];
        }
    });
}

- (void)stateChanged:(id)sender
{
    [self.sswitch toggle];
}

@synthesize view;
@synthesize sswitch;
@synthesize canUseImage;
@synthesize onUIImage;
@synthesize offUIImage;

@end