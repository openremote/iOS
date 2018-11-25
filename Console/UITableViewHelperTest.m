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
#import "UITableViewHelperTest.h"
#import "UITableViewHelper.h"

@implementation UITableViewHelperTest

- (void)testIndexPathsGoingFromLessToMoreRows
{
    NSArray *expectedArray = @[[NSIndexPath indexPathForRow:2 inSection:1], [NSIndexPath indexPathForRow:3 inSection:1]];
    XCTAssertEqualObjects([UITableViewHelper indexPathsForRowCountGoingFrom:2 to:4 section:1], expectedArray, @"Rows 2 and 3 should be added");
}

- (void)testIndexPahtsGoingFromMoreToLessRows
{
    NSArray *expectedArray = @[[NSIndexPath indexPathForRow:2 inSection:1], [NSIndexPath indexPathForRow:3 inSection:1]];
    XCTAssertEqualObjects([UITableViewHelper indexPathsForRowCountGoingFrom:4 to:2 section:1], expectedArray, @"Rows 2 and 3 should be removed");
}

- (void)testIndexPathsWhenNoChangeInRowCount
{
    XCTAssertEqual([[UITableViewHelper indexPathsForRowCountGoingFrom:2 to:2 section:1] count], (NSUInteger)0, @"Rows should no be changed");
}

@end