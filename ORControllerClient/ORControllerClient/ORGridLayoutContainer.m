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
#import "ORGridLayoutContainer_Private.h"
#import "ORGridCell.h"

#define kCellsKey       @"Cells"
#define kRowsKey        @"Rows"
#define kColsKey        @"Cols"

@interface ORGridLayoutContainer ()

@property (nonatomic, strong, readwrite) NSMutableArray *cells;
@property (nonatomic, readwrite) NSUInteger rows;
@property (nonatomic, readwrite) NSUInteger cols;

@property (nonatomic, readwrite) NSInteger left;
@property (nonatomic, readwrite) NSInteger top;
@property (nonatomic, readwrite) NSUInteger width;
@property (nonatomic, readwrite) NSUInteger height;

@end

@implementation ORGridLayoutContainer

- (instancetype)initWithLeft:(NSInteger)leftPos
               top:(NSInteger)topPos
             width:(NSUInteger)widthDim
            height:(NSUInteger)heightDim
              rows:(NSUInteger)rowsNum
              cols:(NSUInteger)colsNum
{
    self = [super init];
    if (self) {
        self.left = leftPos;
        self.top = topPos;
        self.width = widthDim;
        self.height = heightDim;
        self.rows = rowsNum;
        self.cols = colsNum;
		self.cells = [NSMutableArray array];
    }
    return self;
}

- (NSSet *)widgets
{
    NSMutableSet *components = [NSMutableSet setWithCapacity:[self.cells count]];
	for (ORGridCell *cell in self.cells) {
        [components addObject:cell.widget];
    }
    return [NSSet setWithSet:components];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.cells forKey:kCellsKey];
    [aCoder encodeInteger:self.rows forKey:kRowsKey];
    [aCoder encodeInteger:self.cols forKey:kColsKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.cells = [aDecoder decodeObjectForKey:kCellsKey];
        self.rows = [aDecoder decodeIntegerForKey:kRowsKey];
        self.cols = [aDecoder decodeIntegerForKey:kColsKey];
    }
    return self;
}

@synthesize cells, rows, cols;
@synthesize left,top,width,height;

@end