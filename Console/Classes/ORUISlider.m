/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2013, OpenRemote Inc.
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

#import "ORUISlider.h"

// For better visual results, displayed track is smaller than track thumb can move over
// This means that when the thumb is at 0, the track will start at THUMB_SIDE_SPACING
// The value indicates the number of points on each side of the track
#define THUMB_SIDE_SPACING  0 // 1.5

@interface ORUISlider ()

@property (nonatomic, strong) UIView *minTrackView;
@property (nonatomic, strong) UIView *maxTrackView;
@property (nonatomic, strong) UIView *thumbView;

@property (nonatomic, strong) UIImageView *minTrackImageView;
@property (nonatomic, strong) UIImageView *maxTrackImageView;

@property (nonatomic, strong) UIImageView *minValueImageView;
@property (nonatomic, strong) UIImageView *maxValueImageView;

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic) CGPoint previousTouch;
@property (nonatomic) BOOL userMovingSlider;
@property (nonatomic) float userMovingValue;

@property (nonatomic) float thumbTrackWidth;
@property (nonatomic) float minValueSpacing;

@end

@implementation ORUISlider

void printFrame(NSString *comment, UIView *v)
{
    NSLog(@"%@ frame (%f,%f - %f,%f)", comment, v.frame.origin.x, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
}

void printBounds(NSString *comment, UIView *v)
{
    NSLog(@"%@ bounds (%f,%f - %f,%f)", comment, v.bounds.origin.x, v.bounds.origin.y, v.bounds.size.width, v.bounds.size.height);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.value = 0.0;
        self.minimumValue = 0.0;
        self.maximumValue = 1.0;
        self.minTrackView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.minTrackView.clipsToBounds = YES;
        [self addSubview:self.minTrackView];
        self.maxTrackView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.maxTrackView.clipsToBounds = YES;
        [self addSubview:self.maxTrackView];
        self.thumbView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 23.0, 23.0)];
        self.thumbView.clipsToBounds = YES;
        [self addSubview:self.thumbView];
        
        // Use default images used by iOS
        UIImage *greenSlider = [UIImage imageNamed:@"ORSliderGreen.png"];
        UIImage *whiteSlider = [UIImage imageNamed:@"ORSliderWhite.png"];
        self.minimumTrackImage = [greenSlider resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        self.maximumTrackImage = [whiteSlider resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        self.thumbImage = [UIImage imageNamed:@"ORSliderThumb.png"];
        
        self.continuous = YES;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //    printFrame(@"Slider", self);
    //    printBounds(@"Slider", self);
    
    float heightFactor = 1.0;
    float widthFactor = 1.0;
    // If image taller than container, resize
    if (self.minimumValueImage.size.height > self.bounds.size.height) {
        heightFactor = self.bounds.size.height / self.minimumValueImage.size.height;
    }
    // If image is wider than 20% of container, resize
    if (self.minimumValueImage.size.width > self.bounds.size.width * .2) {
        widthFactor = (self.bounds.size.width * .2) / self.minimumValueImage.size.width;
    }
    float scaleFactor = MIN(heightFactor, widthFactor);
    int minImageWidth = self.minimumValueImage.size.width * scaleFactor;
    int minImageHeight = self.minimumValueImage.size.height * scaleFactor;
    self.minValueImageView.frame = CGRectMake(0.0, (self.bounds.size.height - minImageHeight) / 2.0, minImageWidth, minImageHeight);
    
    heightFactor = 1.0;
    widthFactor = 1.0;
    // If image taller than container, resize
    if (self.maximumValueImage.size.height > self.bounds.size.height) {
        heightFactor = self.bounds.size.height / self.maximumValueImage.size.height;
    }
    // If image is wider than 20% of container, resize
    if (self.maximumValueImage.size.width > self.bounds.size.width * .2) {
        widthFactor = (self.bounds.size.width * .2) / self.maximumValueImage.size.width;
    }
    scaleFactor = MIN(heightFactor, widthFactor);
    int maxImageWidth = self.maximumValueImage.size.width * scaleFactor;
    int maxImageHeight = self.maximumValueImage.size.height * scaleFactor;
    self.maxValueImageView.frame = CGRectMake(self.bounds.size.width - maxImageWidth, (self.bounds.size.height - maxImageHeight) / 2.0, maxImageWidth, maxImageHeight);
    
    CGFloat trackWidth = self.bounds.size.width - 2.0 * THUMB_SIDE_SPACING;
    if (self.minimumValueImage) {
        trackWidth = trackWidth - minImageWidth - 2.0;
    }
    if (self.maximumValueImage) {
        trackWidth = trackWidth - maxImageWidth - 2.0;
    }
    
    //    NSLog(@"track available width %f", trackWidth);
    float ratio = 0.0;
    if (self.userMovingSlider) {
        ratio = (self.userMovingValue - self.minimumValue) / abs(self.maximumValue - self.minimumValue);
    } else {
        ratio = (self.value - self.minimumValue) / abs(self.maximumValue - self.minimumValue);
    }
    
    //    NSLog(@"ratio %f", ratio);
    
    float halfThumbWidth = (self.thumbImage.size.width / 2);
    
    self.thumbTrackWidth = trackWidth + 2.0 * THUMB_SIDE_SPACING - self.thumbImage.size.width;
    float thumbLeftBorderPosition = (int)((self.thumbTrackWidth - 1.0) * ratio);
    float thumbCenterPosition = (int)(thumbLeftBorderPosition + halfThumbWidth);
    
    self.minValueSpacing = (self.minimumValueImage?minImageWidth + 2.0:0.0);
    
    //    NSLog(@"Offset %f", offset);
    //    NSLog(@"Thumb left border position %f", thumbLeftBorderPosition);
    //    NSLog(@"Thumb center position %f", thumbCenterPosition);
    
    /*
     * We're using an image view within a view for each part of the track.
     * The image view is sized to be the full width of the track, so that the image is scaled appropriately.
     * It is never scaled in the height direction. If the image is too big, the containing view will ensure it gets clipped.
     * The view is used as a viewport to clip the visible portion of the image.
     * In case of the max track view, some shifting is also required.
     * The track views draw up to (for min) and start from (for max) the center of the thumb.
     */
    self.minTrackImageView.frame = CGRectMake(0.0, (int)((self.bounds.size.height - self.minimumTrackImage.size.height) / 2.0), trackWidth, self.minimumTrackImage.size.height);
    self.minTrackView.frame = CGRectMake(self.minValueSpacing + THUMB_SIDE_SPACING, 0.0, MAX(thumbCenterPosition - THUMB_SIDE_SPACING, 0.0), self.bounds.size.height);
    
    //    printFrame(@"minTrackView", self.minTrackView);
    //    printFrame(@"minTrackImageView", self.minTrackImageView);
    
    self.maxTrackImageView.frame = CGRectMake(-thumbCenterPosition - 1.0 + THUMB_SIDE_SPACING, (int)((self.bounds.size.height - self.maximumTrackImage.size.height) / 2.0), trackWidth, self.maximumTrackImage.size.height);
    self.maxTrackView.frame = CGRectMake(self.minValueSpacing + thumbCenterPosition, 0.0, trackWidth - 1.0 - thumbCenterPosition + THUMB_SIDE_SPACING, self.bounds.size.height);
    
    //    printFrame(@"maxTrackView", self.maxTrackView);
    //    printFrame(@"maxTrackImageView", self.maxTrackImageView);
    
    /**
     * Using same mechanism for thumb, have a view that acts as viewport and an image view inside.
     * Here however, the thumb image is not scaled at all.
     */
    self.thumbImageView.frame = CGRectMake(0.0, (int)((self.bounds.size.height - self.thumbImage.size.height) / 2.0), self.thumbImage.size.width, self.thumbImage.size.height);
    self.thumbView.frame = CGRectMake(self.minValueSpacing + thumbLeftBorderPosition, 0.0, self.thumbImage.size.width, self.bounds.size.height);
    
    //    printFrame(@"thumb", self.thumbView);
}

- (void)setValue:(float)value
{
    // Ensure the value is always within bounds, required for correct drawing
    _value = MIN(MAX(value, self.minimumValue), self.maximumValue);
    [self setNeedsLayout];
}

- (void)setMinimumValue:(float)minimumValue
{
    _minValue = minimumValue;
    self.value = self.value; // Ensures value is within new bounds and slider is redrawn
}

- (void)setMaximumValue:(float)maximumValue
{
    _maxValue = maximumValue;
    self.value = self.value; // Ensures value is within new bounds and slider is redrawn
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage
{
    if (_minimumTrackImage != minimumTrackImage) {
        _minimumTrackImage = minimumTrackImage;
        
        if (self.minTrackImageView) {
            [self.minTrackImageView removeFromSuperview];
        }
        self.minTrackImageView = [[UIImageView alloc] initWithImage:minimumTrackImage];
        [self.minTrackView addSubview:self.minTrackImageView];
        [self setNeedsLayout];
    }
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage
{
    if (_maximumTrackImage != maximumTrackImage) {
        _maximumTrackImage = maximumTrackImage;
        
        if (self.maxTrackImageView) {
            [self.maxTrackImageView removeFromSuperview];
        }
        self.maxTrackImageView = [[UIImageView alloc] initWithImage:maximumTrackImage];
        [self.maxTrackView addSubview:self.maxTrackImageView];
        [self setNeedsLayout];
    }
}

- (void)setMinimumValueImage:(UIImage *)minimumValueImage
{
    if (_minimumValueImage != minimumValueImage) {
        _minimumValueImage = minimumValueImage;
        
        if (self.minValueImageView) {
            [self.minValueImageView removeFromSuperview];
        }
        self.minValueImageView = [[UIImageView alloc] initWithImage:minimumValueImage];
        [self addSubview:self.minValueImageView];
        [self setNeedsLayout];
    }
}

- (void)setMaximumValueImage:(UIImage *)maximumValueImage
{
    if (_maximumValueImage != maximumValueImage) {
        _maximumValueImage = maximumValueImage;
        
        if (self.maxValueImageView) {
            [self.maxValueImageView removeFromSuperview];
        }
        self.maxValueImageView = [[UIImageView alloc] initWithImage:maximumValueImage];
        [self addSubview:self.maxValueImageView];
        [self setNeedsLayout];
    }
}

- (void)setThumbImage:(UIImage *)thumbImage
{
    if (_thumbImage != thumbImage) {
        _thumbImage = thumbImage;
        
        if (self.thumbImageView) {
            [self.thumbImageView removeFromSuperview];
        }
        self.thumbImageView = [[UIImageView alloc] initWithImage:thumbImage];
        [self.thumbView addSubview:self.thumbImageView];
        [self setNeedsLayout];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// We only support single touches, so anyObject retrieves just that touch from touches
	UITouch *touch = [touches anyObject];
	if ([touch view] == self.thumbView) {
		self.previousTouch = [touch locationInView:self];
        self.userMovingSlider = YES;
        self.userMovingValue = self.value;
        [self sendActionsForControlEvents:UIControlEventTouchDown];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	// If the touch was in the thumb, move the thumb accordingly, staying within limits
	if ([touch view] == self.thumbView) {
		CGPoint location = [touch locationInView:self];
        
        float delta = location.x - self.previousTouch.x;
		self.previousTouch = location;
        
        if ((location.x < self.minValueSpacing && delta > 0) || ((location.x > self.minValueSpacing + self.thumbTrackWidth + self.thumbImage.size.width) && delta < 0)) {
            return;
        }
		
        self.userMovingValue = MIN(MAX(self.userMovingValue + abs(self.maximumValue - self.minimumValue) * (delta / (self.thumbTrackWidth - 1.0)), self.minimumValue), self.maximumValue);
        
        if (self.continuous) {
            self.value = self.userMovingValue;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        [self setNeedsLayout];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.value = self.userMovingValue;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    self.userMovingSlider = NO;
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.userMovingSlider = NO;
    [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

@synthesize minimumValue = _minValue;
@synthesize maximumValue = _maxValue;

@end
