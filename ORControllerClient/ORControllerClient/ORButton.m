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

#import "ORButton.h"
#import "ORButton_Private.h"
#import "ORWidget_Private.h"
#import "ORLabel.h"
#import "ORConsole.h"
#import "Definition.h"

#define kLabelKey                  @"Label"
#define kUnpressedImageKey         @"UnpressedImage"
#define kPressedImageKey           @"PressedImage"
#define kRepeatKey                 @"Repeat"
#define kRepeatDelayKey            @"RepeatDelayKey"
#define kHasPressCommandKey        @"HasPressCommand"
#define kHasShortReleaseCommandKey @"HasShortReleaseCommand"
#define kHasLongPressCommandKey    @"HasLongPressCommand"
#define kHasLongReleaseCommandKey  @"HasLongReleaseCommand"
#define kLongPressDelayKey         @"LongPressDelay"
#define kNavigationKey             @"Navigation"

#define kMinimumRepeatDelay 100
#define kMinimumLongPressDelay  250

@interface ORButton ()

@property (nonatomic, strong, readwrite) ORLabel *label;

@property (nonatomic) BOOL repeat;
@property (nonatomic) NSUInteger repeatDelay;
@property (nonatomic) BOOL hasPressCommand;
@property (nonatomic) BOOL hasShortReleaseCommand;
@property (nonatomic) BOOL hasLongPressCommand;
@property (nonatomic) BOOL hasLongReleaseCommand;
@property (nonatomic) NSUInteger longPressDelay;

@property (nonatomic, strong) NSTimer *buttonRepeatTimer;
@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, getter=isLongPress, setter=setLongPress:) BOOL longPress;

@end

@implementation ORButton

- (instancetype)initWithIdentifier:(ORObjectIdentifier *)anIdentifier
                   label:(ORLabel *)aLabel
                  repeat:(BOOL)repeatFlag
             repeatDelay:(int)aRepeatDelay
         hasPressCommand:(BOOL)hasPressCommandFlag
  hasShortReleaseCommand:(BOOL)hasShortReleaseCommandFlag
     hasLongPressCommand:(BOOL)hasLongPressCommandFlag
   hasLongReleaseCommand:(BOOL)hasLongReleaseCommandFlag
          longPressDelay:(int)aLongPressDelay
{
    self = [super initWithIdentifier:anIdentifier];
	if (self) {
        self.label = aLabel;
        self.repeat = repeatFlag;
        self.repeatDelay = MAX(kMinimumRepeatDelay, aRepeatDelay);
        self.hasPressCommand = hasPressCommandFlag;
        self.hasShortReleaseCommand = hasShortReleaseCommandFlag;
        self.hasLongPressCommand = hasLongPressCommandFlag;
        self.hasLongReleaseCommand = hasLongReleaseCommandFlag;
        self.longPressDelay = MAX(kMinimumLongPressDelay, aLongPressDelay);
        if (self.hasLongPressCommand || self.hasLongReleaseCommand) {
            self.repeat = NO;
        }
    }
    return self;
}

- (void)dealloc
{
    [self cancelTimers];
}

- (void)press
{
	[self cancelTimers];
	self.longPress = NO;
    
	if (self.hasPressCommand == YES) {
        [self.definition sendPressCommandForButton:self];
	 	if (self.repeat == YES ) {
			self.buttonRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:(self.repeatDelay / 1000.0) target:self selector:@selector(press:) userInfo:nil repeats:YES];
		}
	}
    if (self.hasLongPressCommand || self.hasLongReleaseCommand) {
        // Set-up timer to detect when this becomes a long press
        self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:(self.longPressDelay / 1000.0) target:self selector:@selector(longPress:) userInfo:nil repeats:NO];
    }
}

- (void)depress
{
	[self cancelTimers];
    
    if (self.hasShortReleaseCommand && !self.isLongPress) {
        [self.definition sendShortReleaseCommandForButton:self];
    }
    if (self.hasLongReleaseCommand && self.isLongPress) {
        [self.definition sendLongReleaseCommandForButton:self];
    }
    
	if (self.navigation) {
        [self.definition.console navigate:self.navigation];
	}
}

- (void)press:(NSTimer *)timer
{
    [self.definition sendPressCommandForButton:self];
}

- (void)longPress:(NSTimer *)timer
{
    self.longPress = YES;
    [self.definition sendLongPressCommandForButton:self];
}

- (void)cancelTimers
{
	if (self.buttonRepeatTimer) {
		[self.buttonRepeatTimer invalidate];
	}
	self.buttonRepeatTimer = nil;
	if (self.longPressTimer) {
		[self.longPressTimer invalidate];
	}
	self.longPressTimer = nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.label forKey:kLabelKey];
    [aCoder encodeObject:self.unpressedImage forKey:kUnpressedImageKey];
    [aCoder encodeObject:self.pressedImage forKey:kPressedImageKey];
    [aCoder encodeBool:self.repeat forKey:kRepeatKey];
    [aCoder encodeInteger:self.repeatDelay forKey:kRepeatDelayKey];
    [aCoder encodeBool:self.hasPressCommand forKey:kHasPressCommandKey];
    [aCoder encodeBool:self.hasShortReleaseCommand forKey:kHasShortReleaseCommandKey];
    [aCoder encodeBool:self.hasLongPressCommand forKey:kHasLongPressCommandKey];
    [aCoder encodeBool:self.hasLongReleaseCommand forKey:kHasLongReleaseCommandKey];
    [aCoder encodeInteger:self.longPressDelay forKey:kLongPressDelayKey];
    [aCoder encodeObject:self.navigation forKey:kNavigationKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.label = [aDecoder decodeObjectForKey:kLabelKey];
        self.unpressedImage = [aDecoder decodeObjectForKey:kUnpressedImageKey];
        self.pressedImage = [aDecoder decodeObjectForKey:kPressedImageKey];
        self.repeat = [aDecoder decodeBoolForKey:kRepeatKey];
        self.repeatDelay = [aDecoder decodeIntegerForKey:kRepeatDelayKey];
        self.hasPressCommand = [aDecoder decodeBoolForKey:kHasPressCommandKey];
        self.hasShortReleaseCommand = [aDecoder decodeBoolForKey:kHasShortReleaseCommandKey];
        self.hasLongPressCommand = [aDecoder decodeBoolForKey:kHasLongPressCommandKey];
        self.hasLongReleaseCommand = [aDecoder decodeBoolForKey:kHasLongReleaseCommandKey];
        self.longPressDelay = [aDecoder decodeIntegerForKey:kLongPressDelayKey];
        self.navigation = [aDecoder decodeObjectForKey:kNavigationKey];
    }
    return self;
}

@end
