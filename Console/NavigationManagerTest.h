/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2015, OpenRemote Inc.
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

#import <XCTest/XCTest.h>


@interface NavigationManagerTest : XCTestCase

/**
 * Tests that the NavigationManager initiliazes correctly with a valid Definition object.
 */
- (void)testValidInit;

/**
 * Tests that it's not possible to initialize a NavigationManager without a Definition, should return nil.
 */
- (void)testInitWithNoDefinition;


/**
 * Tests that current screen reference is initialized correctly.
 */
- (void)testCurrentScreenOnInit;

/**
 * Tests that the current screen reference is initialized correctly when the definition's first group has no screen.
 */
- (void)testCurrentScreenOnInitWithFirstGroupWithNoScreen;

/**
 * Tests that the current screen reference is nil when definition only contains empty groups.
 */
- (void)testCurrentScreenOnInitWithOnlyGroupsWithoutScreen;

/**
 * Tests that the current screen reference is nil when definition does not contain any group.
 */
- (void)testCurrentScreenOnInitWithEmptyDefinition;

/**
 * Tests navigation to an existing group and screen in the definition.
 */
- (void)testNavigateToExistingGroupAndScreen;

/**
 * Tests navigation to an invalid group does not perform navigation and returns nil.
 */
- (void)testNavigateToInvalidGroup;

/**
 * Tests navigation to an invalid screen within a valid group does not perform navigation and returns nil.
 */
- (void)testNavigateToInvalidScreenInValidGroup;

/**
 * Tests navigation to a valid group without specifying any specific screen.
 */
- (void)testNavigateToGroupWithNoScreenSpecified;

/**
 * Tests navigation to an empty troup without specifying any specific screen does not perform navigation and returns nil.
 */
- (void)testNavigateToEmptyGroupWithNoScreenSpecified;


/*
 * Tests navigation to the next screen in a group (when there is one in the group).
 */
- (void)testNavigateToNextScreen;

/**
 * Tests navigation to the next screen in a group when there is none does not perform navigation and returns nil.
 */
- (void)testNavigateToNextScreenNoMoreScreens;

/**
 * Tests navigation to the previous screen in a group (when there is one in the group).
 */
- (void)testNavigateToPreviousScreen;

/**
 * Tests navigation to the previous screen in a group where there is none does not perform navigation and returns nil.
 */
- (void)testNavigateToPreviousScreenNoMoreScreens;

/*
 * Tests navigation back on an existing stack and that nil is returned when top of history is reached.
 */
- (void)testNavigateBack;

@end