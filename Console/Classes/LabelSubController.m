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
#import "LabelSubController.h"
#import "ORControllerClient/ORWidget.h"
#import "SensorStatusCache.h"
#import "ORControllerClient/ORLabel.h"

static void * const LabelSubControllerKVOContext = (void*)&LabelSubControllerKVOContext;

@interface LabelSubController()

@property (nonatomic, readwrite, strong) UIView *view;
@property (weak, nonatomic, readonly) ORLabel *label;

@end

@implementation LabelSubController

- (id)initWithImageCache:(ImageCache *)aCache component:(ORWidget *)aComponent
{
    self = [super initWithImageCache:aCache component:aComponent];
    if (self) {
        UILabel *uiLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        uiLabel.backgroundColor = [UIColor clearColor];
        uiLabel.adjustsFontSizeToFitWidth = NO;
        uiLabel.textAlignment = NSTextAlignmentCenter;
        uiLabel.lineBreakMode = NSLineBreakByWordWrapping;
        uiLabel.numberOfLines = 50;
        uiLabel.text = self.label.text;
        
        [self.label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:LabelSubControllerKVOContext];
        uiLabel.font = self.label.font;
        uiLabel.textColor = self.label.textColor;
        self.view = uiLabel;
    }
    return self;
}

- (void)dealloc
{
    [self.label removeObserver:self forKeyPath:@"text"];
}

- (ORLabel *)label
{
    return (ORLabel *)self.component;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == LabelSubControllerKVOContext) {
        if ([@"text" isEqualToString:keyPath]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UILabel *uiLabel = (UILabel *)self.view;
                uiLabel.text = self.label.text;
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@synthesize view;

@end