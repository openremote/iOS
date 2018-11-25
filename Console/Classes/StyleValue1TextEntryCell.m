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
#import "StyleValue1TextEntryCell.h"

@implementation StyleValue1TextEntryCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;// no auto capitalization support
        textField.autocorrectionType = UITextAutocorrectionTypeNo;// no auto correction support
        textField.textAlignment = NSTextAlignmentRight;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:textField];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    textField.font = self.detailTextLabel.font;
    textField.textColor = self.detailTextLabel.textColor;
    
    [self.textLabel sizeToFit];
    int offset = self.textLabel.frame.size.width + 20;
    
    textField.frame = CGRectMake(self.textLabel.frame.origin.x + offset, self.textLabel.frame.origin.y,
                                 self.contentView.bounds.size.width - offset - self.textLabel.frame.origin.x - 20, self.textLabel.frame.size.height);
}

@synthesize textField;

@end
