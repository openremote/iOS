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
#import "SliderSubController.h"
#import "ORControllerClient/ORSlider.h"
#import "ORControllerClient/ORImage.h"
#import "SensorStatusCache.h"
#import "ORConsoleSettingsManager.h"
#import "ORConsoleSettings.h"
#import "ORControllerConfig.h"
#import "ORControllerClient/Definition.h"
#import "ORControllerClient/LocalController.h"
#import "NotificationConstant.h"
#import "ORUISlider.h"
#import "ImageCache.h"

#define MIN_SLIDE_VARIANT 1

static void * const SliderSubControllerKVOContext = (void*)&SliderSubControllerKVOContext;

@interface UIImage (RotateAdditions)

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end;

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation UIImage (RotateAdditions)

// Rotate image with specified degrees
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees {   
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
	CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end

@interface SliderSubController()

@property (nonatomic, weak) ORControllerConfig *controller;

@property (nonatomic, readwrite, strong) UIView *view;
@property (weak, nonatomic, readonly) ORSlider *slider;
@property (nonatomic, assign) int currentValue;
@property (nonatomic, strong) UIImageView *sliderTip;

@property (nonatomic, weak) ImageCache *imageCache;

- (int)sliderValue:(ORUISlider *)sender;
- (void)sliderValueChanged:(UISlider *)sender;
- (void)releaseSlider:(UISlider *)sender;
- (void)touchDownSlider:(UISlider *)sender;
- (void)clearSliderTipSubviews:(UIImageView *)sliderTipParam;
- (UIImage *)transformToHorizontalWhenVertical:(UIImage *)vImg;

- (void)refreshTip;

@end

@implementation SliderSubController

- (id)initWithImageCache:(ImageCache *)aCache component:(ORWidget *)aComponent
{
    self = [super initWithImageCache:aCache component:aComponent];
    if (self) {
        ORUISlider *uiSlider = [[ORUISlider alloc] initWithFrame:CGRectZero];
        
        uiSlider.minimumValue = self.slider.minValue;
        NSString *minimumValueImageSrc = self.slider.minImage.src;
        UIImage *minimumValueImage = [self.imageCache getImageNamed:minimumValueImageSrc finalImageAvailable:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                uiSlider.minimumValueImage = [self transformToHorizontalWhenVertical:image];
            });
        }];
        if (minimumValueImage) {
            uiSlider.minimumValueImage = [self transformToHorizontalWhenVertical:minimumValueImage];
        }
        
        uiSlider.maximumValue = self.slider.maxValue;
        NSString *maximumValueImageSrc = self.slider.maxImage.src;
        UIImage *maximumValueImage = [self.imageCache getImageNamed:maximumValueImageSrc finalImageAvailable:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                uiSlider.maximumValueImage = [self transformToHorizontalWhenVertical:image];
            });
        }];
        if (maximumValueImage) {
            uiSlider.maximumValueImage = [self transformToHorizontalWhenVertical:maximumValueImage];
        }
        
        // TrackImages, thumbImage
        uiSlider.backgroundColor = [UIColor clearColor];
        NSString *minTrackImageSrc = self.slider.minTrackImage.src;
        NSString *maxTrackImageSrc = self.slider.maxTrackImage.src;
        NSString *thumbImageSrc = self.slider.thumbImage.src;
        
        UIImage *stretchedLeftTrack = [self.imageCache getImageNamed:minTrackImageSrc finalImageAvailable:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [uiSlider setMinimumTrackImage:[self transformToHorizontalWhenVertical:image]];
            });
        }];
        if (stretchedLeftTrack) {
            [uiSlider setMinimumTrackImage:[self transformToHorizontalWhenVertical:stretchedLeftTrack]];
        }

        UIImage *stretchedRightTrack = [self.imageCache getImageNamed:maxTrackImageSrc finalImageAvailable:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [uiSlider setMaximumTrackImage:[self transformToHorizontalWhenVertical:image]];
            });
        }];
        if (stretchedRightTrack) {
            [uiSlider setMaximumTrackImage:[self transformToHorizontalWhenVertical:stretchedRightTrack]];
        }
        
        UIImage *thumbImage = [self.imageCache getImageNamed:thumbImageSrc finalImageAvailable:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [uiSlider setThumbImage:[self transformToHorizontalWhenVertical:image]];
            });
        }];
        if (thumbImage) {
            [uiSlider setThumbImage:[self transformToHorizontalWhenVertical:thumbImage]];
        }
        
        uiSlider.value = self.slider.value;
        self.currentValue = [self sliderValue:uiSlider];
        
        if (self.slider.vertical) {
            uiSlider.transform = CGAffineTransformMakeRotation(270.0/180*M_PI);
        }

        if (!self.slider.passive) {
            [uiSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [uiSlider addTarget:self action:@selector(touchDownSlider:) forControlEvents:UIControlEventTouchDown];
            [uiSlider addTarget:self action:@selector(releaseSlider:) forControlEvents:UIControlEventTouchUpInside];
            [uiSlider addTarget:self action:@selector(releaseSlider:) forControlEvents:UIControlEventTouchUpOutside];
        } else {
            uiSlider.userInteractionEnabled = NO;
        }
        
        self.view = uiSlider;
        
        [self.slider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:SliderSubControllerKVOContext];
    }
    
    return self;
}

- (void)dealloc
{
    [self.slider removeObserver:self forKeyPath:@"value"];
}

- (ORSlider *)slider
{
    return (ORSlider *)self.component;
}

// Rotate the specified image from horizontal to vertical.
- (UIImage *)transformToHorizontalWhenVertical:(UIImage *)vImg {
	return self.slider.vertical ? [vImg imageRotatedByDegrees:90.0] : vImg;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == SliderSubControllerKVOContext) {
        if ([@"value" isEqualToString:keyPath]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ORUISlider *uiSlider = ((ORUISlider *)self.view);
                uiSlider.value = self.slider.value;
                self.currentValue = [self sliderValue:uiSlider];
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSArray *)localCommandsForCommandType:(NSString *)commandType
{
	return [self.controller.definition.localController commandsForComponentIdentifier:self.component.identifier action:@"setValue"];
}

#pragma mark Private methods

- (int)sliderValue:(ORUISlider *)sender
{
    return (int)roundf([sender value]);
}

- (void)sliderValueChanged:(ORUISlider *)sender
{
    // During the user action, always refresh the tip display
	[self refreshTip];
}

-(void) releaseSlider:(ORUISlider *)sender {
	int afterSlideValue = [self sliderValue:sender];
	if (self.currentValue >= 0 && abs(self.currentValue-afterSlideValue) >= MIN_SLIDE_VARIANT) {
        self.slider.value = afterSlideValue;
	} else {
        sender.value = self.currentValue;
    }
	self.sliderTip.hidden = YES;
	[self clearSliderTipSubviews:self.sliderTip];
}

-(void) touchDownSlider:(ORUISlider *)sender {
    [self refreshTip]; // showTip:sliderTip ofSlider:uiSlider withSender:sender];
}

// Render the bubble tip while tapping slider thumb image.
-(void) refreshTip {
    if (!self.sliderTip) {
        self.sliderTip = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_tip.png"]];        
        [self.view.superview addSubview:self.sliderTip];
        // TODO: superview might clip us anyway, better to add to window or to top view in window
        //        self.view.window.
    }
    self.sliderTip.hidden = NO;
    
    // TODO: get rid of that and make sure label is only added and configured once
	[self clearSliderTipSubviews:self.sliderTip];
    
    // TODO: pre-calculate values that can be and cache them
    ORUISlider *uiSlider = (ORUISlider *)self.view;
	CGFloat x = 0;
	CGFloat y = 0;
	CGFloat span = uiSlider.minimumValue - uiSlider.maximumValue;
    CGFloat thumbHeight = [uiSlider thumbImage].size.height; //    ForState:UIControlStateNormal].size.height;
    CGFloat thumbWidth = [uiSlider thumbImage].size.width; // ForState:UIControlStateNormal].size.width;
    CGFloat trackWidth = uiSlider.frame.size.width;
    CGFloat trackHeight = uiSlider.frame.size.height;
    if (uiSlider.minimumValueImage) {
        trackWidth = trackWidth - uiSlider.minimumValueImage.size.width - 14;
        trackHeight = trackHeight - uiSlider.minimumValueImage.size.height - 14;
    }
    if (uiSlider.maximumValueImage) {
        trackWidth = trackWidth - uiSlider.maximumValueImage.size.width - 14;
        trackHeight = trackHeight - uiSlider.maximumValueImage.size.height - 14;
    }
    
	if (self.slider.vertical) {
		x = uiSlider.frame.origin.x + uiSlider.frame.size.width / 2;
		y = ((uiSlider.value - uiSlider.maximumValue)/span) * (trackHeight - thumbHeight) + uiSlider.frame.origin.y;
        if (uiSlider.maximumValueImage) {
            y = y + uiSlider.maximumValueImage.size.height + 14;
        }
	} else {
		x = ((uiSlider.minimumValue - uiSlider.value)/span) * (trackWidth - thumbWidth) + uiSlider.frame.origin.x + thumbWidth / 2;
		y = uiSlider.frame.origin.y + uiSlider.frame.size.height / 2;
        if (uiSlider.minimumValueImage) {
            x = x + uiSlider.minimumValueImage.size.width + 14;
        }
	}
	
	self.sliderTip.frame = CGRectMake(x - 40, y - 100, 80, 80);
	
	// SliderView is in the AbsoluteLayoutContainerView
    /*	if ([self.superview isMemberOfClass:[AbsoluteLayoutContainerView class]]) {
     [self.superview.superview bringSubviewToFront:[self superview]];
     }
     // SliderView is in the GridCellView
     else if ([self.superview isMemberOfClass:[GridCellView class]]) {
     [self.superview.superview.superview bringSubviewToFront:[self superview]];
     }
     */
    UILabel *tipText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
	tipText.font = [UIFont systemFontOfSize:40];
	tipText.backgroundColor = [UIColor clearColor];
	tipText.textAlignment = NSTextAlignmentCenter;
	tipText.text = [NSString stringWithFormat:@"%d", [self sliderValue:uiSlider]];
	[self.sliderTip addSubview:tipText];
}

- (void)clearSliderTipSubviews:(UIImageView *)sliderTipParam {
	for(UIView *aView in sliderTipParam.subviews) {
		[aView removeFromSuperview];
	}
}

@synthesize view;
@synthesize currentValue;
@synthesize sliderTip;

@end