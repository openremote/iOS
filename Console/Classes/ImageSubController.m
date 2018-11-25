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
#import "ImageSubController.h"
#import "ORControllerClient/ORImage.h"
#import "ORImageView.h"
#import "ImageCache.h"

static void * const ImageSubControllerKVOContext = (void*)&ImageSubControllerKVOContext;

@interface ImageSubController()

@property (nonatomic, readwrite, strong) UIView *view;
@property (weak, nonatomic, readonly) ORImage *image;
@property (nonatomic, weak) ImageCache *imageCache;

@end

@implementation ImageSubController

- (id)initWithImageCache:(ImageCache *)aCache component:(ORWidget *)aComponent
{
    self = [super initWithImageCache:aCache component:aComponent];
    if (self) {
        self.view = [[ORImageView alloc] initWithFrame:CGRectZero];
        [self setImageNamed:self.image.src];
        
        /*
         TODO: re-add font and color properties
        imageView.label.font = [UIFont fontWithName:@"Arial" size:self.image.label.fontSize];
        imageView.label.textColor = [UIColor or_ColorWithRGBString:[self.image.label.color substringFromIndex:1]];
         */
        
        [self.image addObserver:self forKeyPath:@"src" options:NSKeyValueObservingOptionNew context:ImageSubControllerKVOContext];
    }
    return self;
}

- (void)dealloc
{
    [self.image removeObserver:self forKeyPath:@"src"];
}

- (ORImage *)image
{
    return (ORImage *)self.component;
}

- (void)setImageNamed:(NSString *)imageName
{
    ORImageView *imageView = (ORImageView *)self.view;
    UIImage *uiImage = [self.imageCache getImageNamed:self.image.src finalImageAvailable:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                imageView.image.image = image;
                [imageView showImage];
            } else {
                [imageView showLabel];
            }
        });
    }];
    if (uiImage) {
        imageView.image.image = uiImage;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == ImageSubControllerKVOContext) {
        if ([@"src" isEqualToString:keyPath]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImageNamed:self.image.src];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@synthesize view;

@end