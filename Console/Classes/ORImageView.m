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
#import "ORImageView.h"

@interface ORImageView()

@property (nonatomic, readwrite, strong) UIImageView *image;
@property (nonatomic, readwrite, strong) UILabel *label;

@end

@implementation ORImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [[UIImageView alloc] initWithFrame:frame];
        self.image.contentMode = UIViewContentModeTopLeft;
        [self addSubview:self.image];
        
        self.label = [[UILabel alloc] initWithFrame:frame];
        self.label.hidden = YES;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.image.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    self.label.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
}

- (void)showImage
{
    self.image.hidden = NO;
    self.label.hidden = YES;
}

- (void)showLabel
{
    self.image.hidden = YES;
    self.label.hidden = NO;
}

@synthesize image;
@synthesize label;

@end