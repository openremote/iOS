/* OpenRemote, the Home of the Digital Home.
 *  * Copyright 2008-2011, OpenRemote Inc-2009, OpenRemote Inc.
 * 
 * See the contributors.txt file in the distribution for a
 * full listing of individual contributors.
 * 
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 3.0 of
 * the License, or (at your option) any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * You should have received a copy of the GNU General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

#import "PanelXMLParsingTests.h"
#import "ORControllerClient/ORLayoutContainer.h"
#import "ORControllerClient/ORAbsoluteLayoutContainer.h"
#import "ORControllerClient/ORSwitch.h"
#import "ORControllerClient/ORButton.h"
#import "ORControllerClient/ORGridLayoutContainer.h"
#import "ORControllerClient/ORGridCell.h"
#import "ORControllerClient/ORImage.h"
#import "ORControllerClient/ORGesture.h"
#import "ORControllerClient/XMLEntity.h"
#import "ORControllerClient/ORTabbarItem.h"
#import "ORControllerClient/Definition.h"
#import "ORControllerClient/ORGroup.h"
#import "ORControllerClient/ORScreen.h"
#import "ORControllerClient/ORNavigation.h"
#import "ORControllerClient/ORTabBar.h"
#import "ORControllerClient/ORBackground.h"
#import "PanelDefinitionParser.h"

#import "ORControllerClient/ORLabel.h"
#import "ORControllerClient/ORObjectIdentifier.h"

@implementation PanelXMLParsingTests

- (NSString *)pathForXMLFile:(NSString *)filename {
 	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
	return [thisBundle pathForResource:filename ofType:@"xml"];
}

// panel_grid_button.xml test
- (void) testParsePanelGridButtonXML {
	NSLog(@"testParsePanelGridButtonXML ");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_grid_button"]];
    Definition *definition = [parser parseDefinitionFromXML:data];
	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int image_index = 0;
	int but_index = 0;
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	NSMutableArray *buts = [[NSMutableArray alloc] init];
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORGridLayoutContainer class]]){
					NSLog(@"layout is grid ");
					ORGridLayoutContainer *grid =(ORGridLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu",(long)grid.left,(long)grid.top,(unsigned long)grid.width,(unsigned long)grid.height];
					NSString *expectedAttrs = @"20 20 300 400";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					for (ORGridCell *cell in grid.cells) {
						[cells addObject:cell];
						if ([cell.widget isKindOfClass:[ORButton class]]) {
							ORButton * but = (ORButton *)cell.widget;
							[buts addObject:but];
							NSString *expectedName = [[NSMutableString alloc] initWithFormat:@"%c",(char)65 + but_index];						
							XCTAssertTrue([but.label.text isEqualToString:expectedName],@"expected %@, but %@",expectedName,but.label.text);
							ORObjectIdentifier *expectedIdentifier = [[ORObjectIdentifier alloc] initWithIntegerId:(59 + but_index++)];
							XCTAssertTrue([expectedIdentifier isEqual:but.identifier], @"expected %@, but %@", expectedIdentifier, but.identifier);
							NSString *expectedDefaultImageName = nil;
							if (but.unpressedImage) {
								expectedDefaultImageName = [[NSMutableString alloc] initWithFormat:@"%c.png",(char)97 + image_index++];						
								XCTAssertTrue([but.unpressedImage.src isEqualToString:expectedDefaultImageName],@"expected %@, but %@",expectedDefaultImageName,but.unpressedImage.src);
							}
							NSString *expectedPressedImageName = nil;
							if (but.pressedImage) {
								expectedPressedImageName = [[NSMutableString alloc] initWithFormat:@"%c.png",(char)97 + image_index++];
								XCTAssertTrue([but.pressedImage.src isEqualToString:expectedPressedImageName],@"expected %@, but %@",expectedPressedImageName,but.pressedImage.src);
							}
                        }
					}
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
	for (int i=0;i<screenNames.count;i++) {
		XCTAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		XCTAssertTrue([[[ORObjectIdentifier alloc] initWithIntegerId:i+5] isEqual:[[screens objectAtIndex:i] identifier]], @"expected %d, but %@",i+5,[[screens objectAtIndex:i] identifier]);
	}
	
	//check groups
	for (int i=0;i<groupNames.count;i++) {
		XCTAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		XCTAssertTrue([[[ORObjectIdentifier alloc] initWithIntegerId:i+1] isEqual:[[groups objectAtIndex:i] identifier]], @"expected %d, but %@",i+1,[[groups objectAtIndex:i] identifier]);
	}
	
	XCTAssertTrue(cells.count== 11,@"expected %d, but %lu",11,(unsigned long)cells.count);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:0]).colspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:0]).rowspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:1]).rowspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:2]).colspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:3]).colspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:4]).colspan == 2,@"expected %d",2);
	ORScreen *screen1 = (ORScreen *)[screens objectAtIndex:0];
//	NSString *ids = [[screen1 pollingComponentsIds] componentsJoinedByString:@","];
//	STAssertTrue([@"" isEqualToString:ids],@"expected '', but %@",ids);
	
	
	XCTAssertTrue(buts.count== 11,@"expected %d, but %lu",11,(unsigned long)buts.count);
                      /*
	STAssertTrue(((ORButton *)[buts objectAtIndex:0]).navigat.toScreen == 19,@"expected %d",19);
	STAssertTrue(((ORButton *)[buts objectAtIndex:0]).hasPressCommand == NO,@"expected NO");
	STAssertTrue(((ORButton *)[buts objectAtIndex:1]).hasPressCommand == YES,@"expected YES");
	STAssertTrue(((ORButton *)[buts objectAtIndex:1]).navigate == nil,@"expected nil");
	STAssertTrue(((ORButton *)[buts objectAtIndex:2]).hasPressCommand == NO,@"expected NO");
	STAssertTrue(((ORButton *)[buts objectAtIndex:2]).navigate.toScreen == 29,@"expected %d",29);
	STAssertTrue(((ORButton *)[buts objectAtIndex:3]).hasPressCommand == NO,@"expected %d",NO);
	STAssertTrue(((ORButton *)[buts objectAtIndex:3]).navigate.toGroup == 9,@"expected %d",9);
	STAssertTrue(((ORButton *)[buts objectAtIndex:4]).hasPressCommand == NO,@"expected %d",NO);
	STAssertTrue(((ORButton *)[buts objectAtIndex:4]).navigate.toGroup == 9,@"expected %d",9);
	STAssertTrue(((ORButton *)[buts objectAtIndex:5]).hasPressCommand == NO,@"expected %d",NO);
	STAssertTrue(((ORButton *)[buts objectAtIndex:5]).navigate.isPreviousScreen == YES,@"expected %d",YES);
	STAssertTrue(((ORButton *)[buts objectAtIndex:6]).hasPressCommand == NO,@"expected %d",NO);
	STAssertTrue(((ORButton *)[buts objectAtIndex:6]).navigate.isNextScreen == YES,@"expected %d",YES);
	STAssertTrue(((ORButton *)[buts objectAtIndex:7]).navigate.isSetting == YES,@"expected %d",YES);
	STAssertTrue(((ORButton *)[buts objectAtIndex:8]).navigate.isBack == YES,@"expected %d",YES);
	STAssertTrue(((ORButton *)[buts objectAtIndex:9]).navigate.isLogin == YES,@"expected %d",YES);
	STAssertTrue(((ORButton *)[buts objectAtIndex:10]).navigate.isLogout == YES,@"expected %d",YES);
                       */
}

// panel_grid_switch.xml test
- (void) testParsePanelGridSwitchXML {
	NSLog(@"testParsePanelGridSwitchXML ");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_grid_switch"]];
    Definition *definition = [parser parseDefinitionFromXML:data];
	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int state_index = 0;
	int switch_index = 0;
	int state_value_index = 0;
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORGridLayoutContainer class]]){
					NSLog(@"layout is grid ");
					ORGridLayoutContainer *grid =(ORGridLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu",(long)grid.left,(long)grid.top,(unsigned long)grid.width,(unsigned long)grid.height];
					NSString *expectedAttrs = @"20 20 300 400";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					for (ORGridCell *cell in grid.cells) {
						[cells addObject:cell];
						if ([cell.widget isKindOfClass:[ORSwitch class]]) {
							ORSwitch *theSwitch = (ORSwitch *)cell.widget;
							ORObjectIdentifier *expectedIdentifier = [[ORObjectIdentifier alloc] initWithIntegerId:(59 + switch_index++)];
							XCTAssertTrue([expectedIdentifier isEqual:theSwitch.identifier], @"expected %@, but %@", expectedIdentifier, theSwitch.identifier);
							NSString *expectedOnName = [[NSMutableString alloc] initWithFormat:@"%c.png",(char)97 + state_index++];						
							XCTAssertTrue([theSwitch.onImage.src isEqualToString:expectedOnName],@"expected %@, but %@",expectedOnName,theSwitch.onImage.src);
							NSString *expectedOffName = [[NSMutableString alloc] initWithFormat:@"%c.png",(char)97 + state_index++];
							XCTAssertTrue([theSwitch.offImage.src isEqualToString:expectedOffName],@"expected %@, but %@",expectedOffName,theSwitch.offImage.src);
							
							// assert sensor
                            /*
							for (int i = 0; i < [theSwitch.sensor.states count]; i++) {
								NSString *expectedStateName;
								NSString *expectedStateValue = [@"" stringByAppendingFormat:@"%c.png", (char)97 + state_value_index++];
								if (i % 2 == 0) {
									expectedStateName = @"on";
								} else {
									expectedStateName = @"off";
								}
								SensorState *sensorState = [theSwitch.sensor.states objectAtIndex:i];
								STAssertTrue([expectedStateName isEqualToString:sensorState.name], @"expected %@, but %@", expectedStateName, sensorState.name);
								STAssertTrue([expectedStateValue isEqualToString:sensorState.value], @"expected %@, but %@", expectedStateValue, sensorState.value);
							}
                             */
						}	
					}
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
	for (int i=0;i<screenNames.count;i++) {
		XCTAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		XCTAssertTrue([[[ORObjectIdentifier alloc] initWithIntegerId:i+5] isEqual:[[screens objectAtIndex:i] identifier]], @"expected %d, but %@", i+5, [[screens objectAtIndex:i] identifier]);
	}
	
	//check groups
	for (int i=0;i<groupNames.count;i++) {
		XCTAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		XCTAssertTrue([[[ORObjectIdentifier alloc] initWithIntegerId:i+1] isEqual:[[groups objectAtIndex:i] identifier]], @"expected %d, but %@", i+1, [[groups objectAtIndex:i] identifier]);
	}
	
	XCTAssertTrue(cells.count== 5,@"expected %d, but %lu",5,(unsigned long)cells.count);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:0]).colspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:0]).rowspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:1]).rowspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:2]).colspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:3]).colspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:4]).colspan == 2,@"expected %d",2);
	ORScreen *screen1 = (ORScreen *)[screens objectAtIndex:0];
                      /*
    NSSet *ids = [NSSet setWithArray:[screen1 pollingComponentsIds]];
    NSSet *expectedIds = [NSSet setWithObjects:@"59", @"60", @"61", @"62", nil];
    STAssertEqualObjects(expectedIds, ids, @"expected 59,60,61,62, but got %@",ids);	
                       */
}

// panel_absolute_switch.xml test
- (void) testParsePanelAbsoluteSwitchXML {
	NSLog(@"testParsePanelAbsoluteSwitchXML ");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_absolute_switch"]];
    Definition *definition = [parser parseDefinitionFromXML:data];
	
	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int state_index = 0;
	int switch_index = 0;
	int state_value_index = 0;
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORAbsoluteLayoutContainer class]]){
					NSLog(@"layout is absolute ");
					ORAbsoluteLayoutContainer *abso =(ORAbsoluteLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu",(long)abso.left,(long)abso.top,(unsigned long)abso.width,(unsigned long)abso.height];
					NSString *expectedAttrs = @"20 320 100 100";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					if ([abso.widget isKindOfClass:[ORSwitch class]]) {
						ORSwitch *theSwitch = (ORSwitch *)abso.widget;
						ORObjectIdentifier *expectedIdentifier = [[ORObjectIdentifier alloc] initWithIntegerId:(59 + switch_index++)];
						XCTAssertTrue([expectedIdentifier isEqual:theSwitch.identifier], @"expected %@, but %@", expectedIdentifier, theSwitch.identifier);
						NSString *expectedOnName = [[NSMutableString alloc] initWithFormat:@"%c.png",(char)97 + state_index++];						
						XCTAssertTrue([theSwitch.onImage.src isEqualToString:expectedOnName],@"expected %@, but %@",expectedOnName,theSwitch.onImage.src);
						NSString *expectedOffName = [[NSMutableString alloc] initWithFormat:@"%c.png",(char)97 + state_index++];
						XCTAssertTrue([theSwitch.offImage.src isEqualToString:expectedOffName],@"expected %@, but %@",expectedOffName,theSwitch.offImage.src);
/*
						// assert sensor
						for (int i = 0; i < [theSwitch.sensor.states count]; i++) {
							NSString *expectedStateName;
							NSString *expectedStateValue = [@"" stringByAppendingFormat:@"%c.png", (char)97 + state_value_index++];
							if (i % 2 == 0) {
								expectedStateName = @"on";
							} else {
								expectedStateName = @"off";
							}
							SensorState *sensorState = [theSwitch.sensor.states objectAtIndex:i];
							STAssertTrue([expectedStateName isEqualToString:sensorState.name], @"expected %@, but %@", expectedStateName, sensorState.name);
							STAssertTrue([expectedStateValue isEqualToString:sensorState.value], @"expected %@, but %@", expectedStateValue, sensorState.value);
						}
 */
					}					
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
	for (int i=0;i<screenNames.count;i++) {
		XCTAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		XCTAssertTrue([[[ORObjectIdentifier alloc] initWithIntegerId:i+5] isEqual:[[screens objectAtIndex:i] identifier]], @"expected %d, but %@", i+5, [[screens objectAtIndex:i] identifier]);
	}
	
	//check groups
	for (int i=0;i<groupNames.count;i++) {
		XCTAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		XCTAssertTrue([[[ORObjectIdentifier alloc] initWithIntegerId:i+1] isEqual:[[groups objectAtIndex:i] identifier]], @"expected %d, but %@", i+1, [[groups objectAtIndex:i] identifier]);
	}
	ORScreen *screen1 = (ORScreen *)[screens objectAtIndex:0];
                      /*
	NSString *ids = [[screen1 pollingComponentsIds] componentsJoinedByString:@","];
	STAssertTrue([@"59,60" isEqualToString:ids],@"expected 59,60 but %@",ids);
                       */
}

// panel_grid_slider.xml test
/*
- (void) testParsePanelGridSliderXML {
	NSLog(@"Begin testParsePanelGridSliderXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_grid_slider"]];
    Definition *definition = [parser parseDefinitionFromXML:data];
	
	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int slider_index = 0;
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	for (Group *group in groups) {
		NSLog(@"group %@ has %d screen", group.name,group.screens.count);
		for (Screen *screen in group.screens) {			
			NSLog(@"screen %@ has %d layout", screen.name, screen.layouts.count);
			for (LayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[GridLayoutContainer class]]){					
					NSLog(@"layout is grid ");
					GridLayoutContainer *grid =(GridLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%d %d %d %d",grid.left,grid.top,grid.width,grid.height];
					NSString *expectedAttrs = @"20 20 300 400";
					STAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					for (GridCell *cell in grid.cells) {			
						[cells addObject:cell];
						if ([cell.component isKindOfClass:[Slider class]]) {
							Slider *theSlider = (Slider *)cell.component;
							int expectedId = (59 + slider_index);
							STAssertTrue(expectedId == theSlider.componentId,@"expected %d, but %d",expectedId,theSlider.componentId);
							float maxValue = 100.0f;						
							STAssertTrue(theSlider.maxValue == maxValue,@"expected %f, but %f", maxValue, theSlider.maxValue);
							float minValue = 0.0f;
							STAssertTrue(theSlider.minValue == minValue,@"expected %f, but %f", minValue, theSlider.minValue);
							
							NSString *expectedThumbImageSrc = @"thumbImage.png";
							NSString *expectedMinImageSrc = @"mute.png";
							NSString *expectedMinTrackImageSrc = @"red.png";
							NSString *expectedMaxImageSrc = @"loud.png";
							NSString *expectedMaxTrackImageSrc = @"green.png";
							NSString *assertMsgOfImageSrc = @"expected %@, but %@";
							BOOL expectedVertical = NO;
							BOOL expectedPassive = NO;
							if (slider_index % 2 == 0) {
								expectedVertical = YES;
								expectedPassive = YES;
							}
							STAssertTrue([theSlider.thumbImage.src isEqualToString:expectedThumbImageSrc], assertMsgOfImageSrc, expectedThumbImageSrc, theSlider.thumbImage.src);
							STAssertTrue([theSlider.minImage.src isEqualToString:expectedMinImageSrc], assertMsgOfImageSrc, expectedMinImageSrc, theSlider.minImage.src);
							STAssertTrue([theSlider.minTrackImage.src isEqualToString:expectedMinTrackImageSrc], assertMsgOfImageSrc, expectedMinTrackImageSrc, theSlider.minTrackImage.src);
							STAssertTrue([theSlider.maxImage.src isEqualToString:expectedMaxImageSrc], assertMsgOfImageSrc, expectedMaxImageSrc, theSlider.maxImage.src);
							STAssertTrue([theSlider.maxTrackImage.src isEqualToString:expectedMaxTrackImageSrc], assertMsgOfImageSrc, expectedMaxTrackImageSrc, theSlider.maxTrackImage.src);
							STAssertTrue(theSlider.vertical == expectedVertical, @"expected %d, but %d", expectedVertical, theSlider.vertical);
							STAssertTrue(theSlider.passive == expectedPassive, @"expected %d, but %d", expectedPassive, theSlider.passive);
							slider_index++;
						}	
					}
				}				
			}
		}
	}
	
	NSLog(@"groups count = %d",[groups count]);
	NSLog(@"screens count = %d",[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
	
	//check groups
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
	
	STAssertTrue(cells.count== 5,@"expected %d, but %d",5,cells.count);
	STAssertTrue(((GridCell *)[cells objectAtIndex:0]).colspan == 1,@"expected %d",1);
	STAssertTrue(((GridCell *)[cells objectAtIndex:0]).rowspan == 1,@"expected %d",1);
	STAssertTrue(((GridCell *)[cells objectAtIndex:1]).rowspan == 1,@"expected %d",1);
	STAssertTrue(((GridCell *)[cells objectAtIndex:2]).colspan == 1,@"expected %d",1);
	STAssertTrue(((GridCell *)[cells objectAtIndex:3]).colspan == 1,@"expected %d",1);
	STAssertTrue(((GridCell *)[cells objectAtIndex:4]).colspan == 2,@"expected %d",2);
	Screen *screen1 = (Screen *)[screens objectAtIndex:0];
    NSSet *ids = [NSSet setWithArray:[screen1 pollingComponentsIds]];
    NSSet *expectedIds = [NSSet setWithObjects:@"59", @"60", @"61", @"62", nil];
    STAssertEqualObjects(expectedIds, ids, @"expected 59,60,61,62, but got %@",ids);	

	NSLog(@"End testParsePanelGridSliderXML");
}

// panel_absolute_slider.xml test
- (void) testParsePanelAbsoluteSliderXML {
	NSLog(@"Begin testParsePanelAbsoluteSliderXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_absolute_slider"]];
    Definition *definition = [parser parseDefinitionFromXML:data];

	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int slider_index = 0;
	for (Group *group in groups) {
		NSLog(@"group %@ has %d screen", group.name,group.screens.count);
		for (Screen *screen in group.screens) {			
			NSLog(@"screen %@ has %d layout", screen.name, screen.layouts.count);
			for (LayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[AbsoluteLayoutContainer class]]){					
					NSLog(@"layout is absolute ");
					AbsoluteLayoutContainer *abso =(AbsoluteLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%d %d %d %d",abso.left,abso.top,abso.width,abso.height];
					NSString *expectedAttrs = @"20 320 100 100";
					STAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					if ([abso.component isKindOfClass:[Slider class]]) {
						Slider *theSlider = (Slider *)abso.component;
						int expectedId = (59 + slider_index);
						STAssertTrue(expectedId == theSlider.componentId,@"expected %d, but %d",expectedId,theSlider.componentId);
						float maxValue = 100.0f;						
						STAssertTrue(theSlider.maxValue == maxValue,@"expected %f, but %f", maxValue, theSlider.maxValue);
						float minValue = 0.0f;
						STAssertTrue(theSlider.minValue == minValue,@"expected %f, but %f", minValue, theSlider.minValue);
						
						BOOL expectedVertical = NO;
						BOOL expectedPassive = NO;
						if (slider_index % 2 == 0) {
							expectedVertical = YES;
							expectedPassive = YES;
						}
						slider_index++;
						
						NSString *expectedThumbImageSrc = @"thumbImage.png";
						NSString *expectedMinImageSrc = @"mute.png";
						NSString *expectedMinTrackImageSrc = @"red.png";
						NSString *expectedMaxImageSrc = @"loud.png";
						NSString *expectedMaxTrackImageSrc = @"green.png";
						NSString *assertMsgOfImageSrc = @"expected %@, but %@";
						STAssertTrue([theSlider.thumbImage.src isEqualToString:expectedThumbImageSrc], assertMsgOfImageSrc, expectedThumbImageSrc, theSlider.thumbImage.src);
						STAssertTrue([theSlider.minImage.src isEqualToString:expectedMinImageSrc], assertMsgOfImageSrc, expectedMinImageSrc, theSlider.minImage.src);
						STAssertTrue([theSlider.minTrackImage.src isEqualToString:expectedMinTrackImageSrc], assertMsgOfImageSrc, expectedMinTrackImageSrc, theSlider.minTrackImage.src);
						STAssertTrue([theSlider.maxImage.src isEqualToString:expectedMaxImageSrc], assertMsgOfImageSrc, expectedMaxImageSrc, theSlider.maxImage.src);
						STAssertTrue([theSlider.maxTrackImage.src isEqualToString:expectedMaxTrackImageSrc], assertMsgOfImageSrc, expectedMaxTrackImageSrc, theSlider.maxTrackImage.src);
						STAssertTrue(theSlider.vertical == expectedVertical, @"expected %d, but %d", expectedVertical, theSlider.vertical);
						STAssertTrue(theSlider.passive == expectedPassive, @"expected %d, but %d", expectedPassive, theSlider.passive);
					}					
				}				
			}
		}
	}
	
	NSLog(@"groups count = %d",[groups count]);
	NSLog(@"screens count = %d",[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
	
	//check groups
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
	Screen *screen1 = (Screen *)[screens objectAtIndex:0];
	NSString *ids = [[screen1 pollingComponentsIds] componentsJoinedByString:@","];
	STAssertTrue([@"59,60" isEqualToString:ids],@"expected 59,60 but %@",ids);
	
	NSLog(@"End testParsePanelAbsoluteSliderXML");
}
*/
// panel_grid_label.xml test
- (void) testParsePanelGridLabelXML {
	NSLog(@"Begin testParsePanelGridLabelXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_grid_label"]];
    Definition *definition = [parser parseDefinitionFromXML:data];

	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int label_index = 0;
	int state_index = 0;
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORGridLayoutContainer class]]){					
					NSLog(@"layout is grid ");
					ORGridLayoutContainer *grid =(ORGridLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu",(long)grid.left,(long)grid.top, (unsigned long)grid.width,(unsigned long)grid.height];
					NSString *expectedAttrs = @"20 20 300 400";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					for (ORGridCell *cell in grid.cells) {
						[cells addObject:cell];
						if ([cell.widget isKindOfClass:[ORLabel class]]) {
							ORLabel *theLabel = (ORLabel *)cell.widget;
							
							// assert atrributes
							int expectedId = (59 + label_index);							
							int expectedFontSize = 14;
							NSString *expectedColor = [@"#" stringByAppendingFormat:@"%c%c%c%c%c%c", (char)65 + label_index, (char)65 + label_index, (char)65 + label_index, (char)65 + label_index, (char)65 + label_index, (char)65 + label_index];
							NSString *expectedText = [@"" stringByAppendingFormat:@"%cWaiting", (char)65 + label_index];
/*							STAssertTrue(expectedId == theLabel.componentId,@"expected %d, but %d",expectedId,theLabel.componentId);
							STAssertTrue(expectedFontSize == theLabel.fontSize, @"expected %d, but %d", expectedFontSize, theLabel.fontSize);
							STAssertTrue([expectedColor isEqualToString:theLabel.color], @"expected %@, but %@", expectedColor, theLabel.color);
							STAssertTrue([expectedText isEqualToString:theLabel.text], @"expected %@, but %@", expectedText, theLabel.text);
*/
							// assert sensor
/*							for (int i = 0; i < [theLabel.sensor.states count]; i++) {
								NSString *expectedStateName;
								NSString *expectedStateValue;
								if (i % 2 == 0) {
									expectedStateName = @"on";
									expectedStateValue = @"LAMP_ON";
								} else {
									expectedStateName = @"off";
									expectedStateValue = @"LAMP_OFF";
								}
								SensorState *sensorState = [theLabel.sensor.states objectAtIndex:i];
								STAssertTrue([expectedStateName isEqualToString:sensorState.name], @"expected %@, but %@", expectedStateName, sensorState.name);
								STAssertTrue([expectedStateValue isEqualToString:sensorState.value], @"expected %@, but %@", expectedStateValue, sensorState.value);
							}
 */
							
							label_index++;
							state_index++;
						}	
					}
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
    /*
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
     */
	
	//check groups
    /*
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
     */
	
	XCTAssertTrue(cells.count== 5,@"expected %d, but %lu",5,(unsigned long)cells.count);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:0]).colspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:0]).rowspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:1]).rowspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:2]).colspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:3]).colspan == 1,@"expected %d",1);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:4]).colspan == 2,@"expected %d",2);

	NSLog(@"End testParsePanelGridLabelXML");
}

// panel_absolute_label.xml test
- (void) testParsePanelAbsoluteLabelXML {
	NSLog(@"Begin testParsePanelAbsoluteLabelXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_absolute_label"]];
    Definition *definition = [parser parseDefinitionFromXML:data];

	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int label_index = 0;
	int state_index = 0;
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORAbsoluteLayoutContainer class]]){					
					NSLog(@"layout is absolute ");
					ORAbsoluteLayoutContainer *abso =(ORAbsoluteLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu", (long)abso.left,(long)abso.top,(unsigned long)abso.width,(unsigned long)abso.height];
					NSString *expectedAttrs = @"20 320 100 100";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					if ([abso.widget isKindOfClass:[ORLabel class]]) {
						ORLabel *theLabel= (ORLabel *)abso.widget;
						int expectedId = (59 + label_index);
                        /*
						STAssertTrue(expectedId == theLabel.componentId,@"expected %d, but %d",expectedId,theLabel.componentId);
						
						int expectedFontSize = 14;
						NSString *expectedColor = [@"#" stringByAppendingFormat:@"%c%c%c%c%c%c", (char)65 + label_index, (char)65 + label_index, (char)65 + label_index, (char)65 + label_index, (char)65 + label_index, (char)65 + label_index];
						NSString *expectedText = [@"" stringByAppendingFormat:@"%cWaiting", (char)65 + label_index];
						STAssertTrue(expectedFontSize == theLabel.fontSize, @"expected %d, but %d", expectedFontSize, theLabel.fontSize);
						STAssertTrue([expectedColor isEqualToString:theLabel.color], @"expected %@, but %@", expectedColor, theLabel.color);
						STAssertTrue([expectedText isEqualToString:theLabel.text], @"expected %@, but %@", expectedText, theLabel.text);
						
						// assert sensor
						for (int i = 0; i < [theLabel.sensor.states count]; i++) {
							NSString *expectedStateName;
							NSString *expectedStateValue;
							if (i % 2 == 0) {
								expectedStateName = @"on";
								expectedStateValue = @"LAMP_ON";
							} else {
								expectedStateName = @"off";
								expectedStateValue = @"LAMP_OFF";
							}
							SensorState *sensorState = [theLabel.sensor.states objectAtIndex:i];
							STAssertTrue([expectedStateName isEqualToString:sensorState.name], @"expected %@, but %@", expectedStateName, sensorState.name);
							STAssertTrue([expectedStateValue isEqualToString:sensorState.value], @"expected %@, but %@", expectedStateValue, sensorState.value);
						}
                         
                         */
						
						label_index++;
						state_index++;
					}					
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
    /*
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
     */
	
	//check groups
    /*
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
     */
	
	NSLog(@"End testParsePanelAbsoluteLabelXML");
}

// panel_grid_image.xml test
- (void) testParsePanelGridImageXML {
	NSLog(@"Begin testParsePanelGridImageXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_grid_image"]];
    Definition *definition = [parser parseDefinitionFromXML:data];
	
	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int image_index = 0;
	int state_index = 0;
	NSLog(@"groups count is %lu", (unsigned long)groups.count);
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORGridLayoutContainer class]]){					
					NSLog(@"layout is grid ");
					ORGridLayoutContainer *grid =(ORGridLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu",(long)grid.left, (long)grid.top,(unsigned long)grid.width,(unsigned long)grid.height];
					NSString *expectedAttrs = @"20 20 300 400";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);

					NSLog(@"Grid cells count is : %lu", (unsigned long)grid.cells.count);
					for (ORGridCell *cell in grid.cells) {
						[cells addObject:cell];
						if ([cell.widget isKindOfClass:[ORImage class]]) {
							ORImage *theImage = (ORImage *)cell.widget;
							ORObjectIdentifier *expectedId = [[ORObjectIdentifier alloc] initWithIntegerId:(59 + image_index++)];
							XCTAssertEqualObjects(expectedId, theImage.identifier, @"Expected %@, but %@",expectedId,theImage.identifier);
							NSString *expectedImageSrc = [[NSString alloc] initWithFormat:@"%c.png", (char)97 + state_index++];					
							XCTAssertTrue([theImage.src isEqualToString:expectedImageSrc],@"expected %@, but %@", expectedImageSrc, theImage.src);
//							NSString *expectedImageStyle = @"";
//							STAssertTrue([theImage.style isEqualToString:expectedImageStyle], @"expected %@, but %@", expectedImageStyle, theImage.style);
							
							// assert sensor
                            /*
							for (int i = 0; i < [theImage.sensor.states count]; i++) {
								NSString *expectedStateName;
								NSString *expectedStateValue;
								if (i % 2 == 0) {
									expectedStateName = @"on";
									expectedStateValue = @"on.png";
								} else {
									expectedStateName = @"off";
									expectedStateValue = @"off.png";
								}
								SensorState *sensorState = [theImage.sensor.states objectAtIndex:i];
								STAssertTrue([expectedStateName isEqualToString:sensorState.name], @"expected %@, but %@", expectedStateName, sensorState.name);
								STAssertTrue([expectedStateValue isEqualToString:sensorState.value], @"expected %@, but %@", expectedStateValue, sensorState.value);
							}
                             */
							
                            
                            // TODO: did comment out that bit for now as we're transitionning from legacy to new object model
                            /*
							// assert include
							Label *includedLabel = theImage.label;
							for (Label *tempLabel in definition.legacyLabels) {
								if (tempLabel.componentId == includedLabel.componentId) {
									includedLabel = tempLabel;
									break;
								}
							}
							STAssertTrue(includedLabel.componentId == 64, @"expected 64, but %d", includedLabel.componentId);
							int expectedIncludedLabelSensorId = 1001;
							STAssertTrue(includedLabel.sensor.sensorId == expectedIncludedLabelSensorId, @"expected %d, but %d", expectedIncludedLabelSensorId, includedLabel.sensor.sensorId);
							
							// assert include label's sensor
							NSLog(@"grid image includedLabel.sensor.states count is %d", includedLabel.sensor.states.count);
							for (int i = 0; i < [includedLabel.sensor.states count]; i++) {
								NSString *expectedStateName;
								NSString *expectedStateValue;
								if (i % 2 == 0) {
									expectedStateName = @"on";
									expectedStateValue = @"LAMP_ON";
								} else {
									expectedStateName = @"off";
									expectedStateValue = @"LAMP_OFF";
								}
								SensorState *sensorState = [includedLabel.sensor.states objectAtIndex:i];
								STAssertTrue([expectedStateName isEqualToString:sensorState.name], @"expected %@, but %@", expectedStateName, sensorState.name);
								STAssertTrue([expectedStateValue isEqualToString:sensorState.value], @"expected %@, but %@", expectedStateValue, sensorState.value);
							}
                             */
						}	
					}
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
    /*
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
     */
	
	//check groups
    /*
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
     */
	
	XCTAssertTrue(cells.count== 6,@"expected %d, but %lu",6,(unsigned long)cells.count);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:0]).colspan == 1,@"expected %d, but %lu",1, (unsigned long)((ORGridCell *)[cells objectAtIndex:0]).colspan);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:0]).rowspan == 1,@"expected %d, but %lu",1, (unsigned long)((ORGridCell *)[cells objectAtIndex:0]).rowspan);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:1]).rowspan == 1,@"expected %d, but %lu",1, (unsigned long)((ORGridCell *)[cells objectAtIndex:1]).rowspan);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:2]).colspan == 1,@"expected %d, but %lu",1, (unsigned long)((ORGridCell *)[cells objectAtIndex:2]).colspan);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:3]).colspan == 1,@"expected %d, but %lu",1, (unsigned long)((ORGridCell *)[cells objectAtIndex:3]).colspan);
	XCTAssertTrue(((ORGridCell *)[cells objectAtIndex:4]).colspan == 1,@"expected %d, but %lu",1, (unsigned long)((ORGridCell *)[cells objectAtIndex:4]).colspan);
	
	NSLog(@"End testParsePanelGridImageXML");
}

// panel_absolute_image.xml test
- (void) testParsePanelAbsoluteImageXML {
	NSLog(@"Begin testParsePanelAbsoluteImageXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_absolute_image"]];
    Definition *definition = [parser parseDefinitionFromXML:data];
	
	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int image_index = 0;
	int state_index = 0;
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORAbsoluteLayoutContainer class]]){					
					NSLog(@"layout is absolute ");
					ORAbsoluteLayoutContainer *abso =(ORAbsoluteLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu",(long)abso.left,(long)abso.top,(unsigned long)abso.width, (unsigned long)abso.height];
					NSString *expectedAttrs = @"20 320 100 100";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					if ([abso.widget isKindOfClass:[ORImage class]]) {
						ORImage *theImage= (ORImage *)abso.widget;
						ORObjectIdentifier *expectedId = [[ORObjectIdentifier alloc] initWithIntegerId:(59 + image_index++)];
						XCTAssertEqualObjects(expectedId, theImage.identifier, @"expected %@, but %@", expectedId, theImage.identifier);
						NSString *imageSrc = [[NSString alloc] initWithFormat:@"%c.png", (char)97 + state_index++];
						XCTAssertTrue([theImage.src isEqualToString:imageSrc],@"expected %@, but %@", theImage.src, imageSrc);
//						NSString *expectedImageStyle = @"";
//						STAssertTrue([theImage.style isEqualToString:expectedImageStyle], @"expected %@, but %@", expectedImageStyle, theImage.style);
						
						// assert sensor
                        /*
						for (int i = 0; i < [theImage.sensor.states count]; i++) {
							NSString *expectedStateName;
							NSString *expectedStateValue;
							if (i % 2 == 0) {
								expectedStateName = @"on";
								expectedStateValue = @"on.png";
							} else {
								expectedStateName = @"off";
								expectedStateValue = @"off.png";
							}
							SensorState *sensorState = [theImage.sensor.states objectAtIndex:i];
							STAssertTrue([expectedStateName isEqualToString:sensorState.name], @"expected %@, but %@", expectedStateName, sensorState.name);
							STAssertTrue([expectedStateValue isEqualToString:sensorState.value], @"expected %@, but %@", expectedStateValue, sensorState.value);
						}
                         */
						
                        // TODO: did comment out that bit for now as we're transitionning from legacy to new object model
                        /*
						// assert include
						Label *includedLabel = theImage.label;
						for (Label *tempLabel in definition.legacyLabels) {
							if (tempLabel.componentId == includedLabel.componentId) {
								includedLabel = tempLabel;
								break;
							}
						}
						STAssertTrue(includedLabel.componentId == 62, @"expected 62, but %d", includedLabel.componentId);
						int expectedIncludedLabelSensorId = 1001;
						STAssertTrue(includedLabel.sensor.sensorId == expectedIncludedLabelSensorId, @"expected %d, but %d", expectedIncludedLabelSensorId, includedLabel.sensor.sensorId);
						
						// assert include label's sensor
						NSLog(@"absolute image includedLabel.sensor.states count is %d", includedLabel.sensor.states.count);
						for (int i = 0; i < [includedLabel.sensor.states count]; i++) {
							NSString *expectedStateName;
							NSString *expectedStateValue;
							if (i % 2 == 0) {
								expectedStateName = @"on";
								expectedStateValue = @"LAMP_ON";
							} else {
								expectedStateName = @"off";
								expectedStateValue = @"LAMP_OFF";
							}
							SensorState *sensorState = [includedLabel.sensor.states objectAtIndex:i];
							STAssertTrue([expectedStateName isEqualToString:sensorState.name], @"expected %@, but %@", expectedStateName, sensorState.name);
							STAssertTrue([expectedStateValue isEqualToString:sensorState.value], @"expected %@, but %@", expectedStateValue, sensorState.value);
						}
                         */
					}					
				}
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
    /*
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
     */
	
	//check groups
    /*
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
     */
	
	NSLog(@"End testParsePanelAbsoluteImageXML");
}

// panel_absolute_screen_backgroundimage.xml test
- (void) testParsePanelAbsoluteScreenBackgroundimageXML {
	NSLog(@"Begin testParsePanelAbsoluteScreenBackgroundimageXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_absolute_screen_backgroundimage"]];
    Definition *definition = [parser parseDefinitionFromXML:data];

	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int background_index = 1;
	int image_index = 0;
	int state_index = 0;
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			
			NSLog(@"Begin test background of screen %@", [screen name]);
            /*
			// absolute position
			STAssertTrue([[screen background] isBackgroundImageAbsolutePosition], @"expected %d, but %d", YES, [[screen background] isBackgroundImageAbsolutePosition]);
			NSLog(@"isBackgroundImageAbsolutePosition of screen background is %d", [[screen background] isBackgroundImageAbsolutePosition]);
			
			int backgroundImageLeft = [[screen background] backgroundImageAbsolutePositionLeft];
			int backgroundImageTop = [[screen background] backgroundImageAbsolutePositionTop];
			int expectedBackgroundImageLeft = 100*background_index;
			int expectedBackgroundImageTop = 100*background_index;
			STAssertTrue(backgroundImageLeft == expectedBackgroundImageLeft, @"expected %d, but %d", expectedBackgroundImageLeft, backgroundImageLeft);
			STAssertTrue(backgroundImageTop == expectedBackgroundImageTop, @"expected %d, but %d", expectedBackgroundImageTop, backgroundImageTop);
			NSLog(@"absolute position of background image is: %d,%d", backgroundImageLeft, backgroundImageTop);
			
			// fillscreen
			BOOL fillScreen = [[screen background] fillScreen];
			BOOL expectedFillScreen = NO;
			STAssertTrue(fillScreen == expectedFillScreen, @"expected %d, but %d", expectedFillScreen, fillScreen);
			NSLog(@"fillScreen of background image is %d", fillScreen);
			
			// background image src
			NSString *backgroundImageSrc = [[[screen background] backgroundImage] src];
			NSString *expectedBackgroundImageSrc = [[NSString alloc] initWithFormat:@"basement%d.png", background_index];
			STAssertTrue([expectedBackgroundImageSrc isEqualToString:backgroundImageSrc], @"expected %@, but %@", expectedBackgroundImageSrc, backgroundImageSrc);
			NSLog(@"background image src of background is %@", backgroundImageSrc);
			
			NSLog(@"End test background of screen %@", [screen name]);			
			background_index++;
			*/
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORAbsoluteLayoutContainer class]]){					
					NSLog(@"layout is absolute ");
					ORAbsoluteLayoutContainer *abso =(ORAbsoluteLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu",(long)abso.left,(long)abso.top,(unsigned long)abso.width,(unsigned long)abso.height];
					NSString *expectedAttrs = @"20 320 100 100";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					if ([abso.widget isKindOfClass:[ORImage class]]) {
						ORImage *theImage= (ORImage *)abso.widget;
						ORObjectIdentifier *expectedId = [[ORObjectIdentifier alloc] initWithIntegerId:(59 + image_index++)];
						XCTAssertEqualObjects(expectedId, theImage.identifier, @"expected %@, but %@", expectedId, theImage.identifier);
						NSString *imageSrc = [[NSString alloc] initWithFormat:@"%c.png", (char)97 + state_index++];
						XCTAssertTrue([theImage.src isEqualToString:imageSrc],@"expected %@, but %@", theImage.src, imageSrc);
					}					
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
    /*
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
     */
	
	//check groups
    /*
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
     */
    
	NSLog(@"End testParsePanelAbsoluteScreenBackgroundimageXML");
}

// panel_relative_screen_backgroundimage.xml test
- (void) testParsePanelRelativeScreenBackgroundimageXML {
	NSLog(@"Begin testParsePanelRelativeScreenBackgroundimageXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_relative_screen_backgroundimage"]];
    Definition *definition = [parser parseDefinitionFromXML:data];

	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int background_index = 1;
	int image_index = 0;
	int state_index = 0;
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			/*
			NSLog(@"Begin test background of screen %@", [screen name]);
			// relative position
			STAssertTrue(![[screen background] isBackgroundImageAbsolutePosition], @"expected %d, but %d", NO, [[screen background] isBackgroundImageAbsolutePosition]);
			NSLog(@"isBackgroundImageAbsolutePosition of screen background is %d", [[screen background] isBackgroundImageAbsolutePosition]);
			
			NSString *backgroundImageRelativePosition = [[screen background] backgroundImageRelativePosition];
			NSString *expectedBackgroundImageRelativePosition;
			if (background_index%2 != 0) {
				expectedBackgroundImageRelativePosition = BG_IMAGE_RELATIVE_POSITION_LEFT;
			} else {
				expectedBackgroundImageRelativePosition = BG_IMAGE_RELATIVE_POSITION_RIGHT;
			}
			STAssertTrue([backgroundImageRelativePosition isEqualToString:expectedBackgroundImageRelativePosition], @"expected %@, but %@", expectedBackgroundImageRelativePosition, backgroundImageRelativePosition);
			NSLog(@"relative position of background image is %@", backgroundImageRelativePosition);
			
			// fillscreen
			BOOL fillScreen = [[screen background] fillScreen];
			BOOL expectedFillScreen = NO;
			STAssertTrue(fillScreen == expectedFillScreen, @"expected %d, but %d", expectedFillScreen, fillScreen);
			NSLog(@"fillScreen of background image is %d", fillScreen);
			
			// background image src
			NSString *backgroundImageSrc = [[[screen background] backgroundImage] src];
			NSString *expectedBackgroundImageSrc = [[NSString alloc] initWithFormat:@"basement%d.png", background_index];
			STAssertTrue([expectedBackgroundImageSrc isEqualToString:backgroundImageSrc], @"expected %@, but %@", expectedBackgroundImageSrc, backgroundImageSrc);
			NSLog(@"background image src is %@ ", backgroundImageSrc);
			
			background_index++;
			*/
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORAbsoluteLayoutContainer class]]){					
					NSLog(@"layout is absolute ");
					ORAbsoluteLayoutContainer *abso =(ORAbsoluteLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu", (long)abso.left,(long)abso.top,(unsigned long)abso.width,(unsigned long)abso.height];
					NSString *expectedAttrs = @"20 320 100 100";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					if ([abso.widget isKindOfClass:[ORImage class]]) {
						ORImage *theImage= (ORImage *)abso.widget;
						ORObjectIdentifier *expectedId = [[ORObjectIdentifier alloc] initWithIntegerId:(59 + image_index++)];
						XCTAssertEqualObjects(expectedId, theImage.identifier, @"expected %@, but %@", expectedId, theImage.identifier);
						NSString *imageSrc = [[NSString alloc] initWithFormat:@"%c.png", (char)97 + state_index++];
						XCTAssertTrue([theImage.src isEqualToString:imageSrc],@"expected %@, but %@", theImage.src, imageSrc);
					}					
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
    /*
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
     */
	
	//check groups
    /*
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
     */

	NSLog(@"End testParsePanelRelativeScreenBackgroundimageXML");
}

/*
// panel_absolute_slider_gesture.xml test
- (void) testParsePanelAbsoluteSliderGestureXML {
	NSLog(@"Begin testParsePanelAbsoluteSliderGestureXML ");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_absolute_slider_gesture"]];
    Definition *definition = [parser parseDefinitionFromXML:data];

	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	int slider_index = 0;
	int gesture_index = 0;
	for (Group *group in groups) {
		NSLog(@"group %@ has %d screen", group.name,group.screens.count);
		for (Screen *screen in group.screens) {
			int count = screen.gestures.count;
			STAssertTrue(4 == count, @"expected 4, but %d",count);
			for (Gesture *gesture in screen.gestures) {
				STAssertEquals(gesture.swipeType, gesture_index % 4, @"expected %d, but %d",gesture_index % 4,gesture.swipeType);
				STAssertEquals(gesture.hasControlCommand, YES, @"expected yes, but %d",gesture.hasControlCommand);
				
				switch (gesture_index % 4) {
					case 0:
						STAssertEquals(gesture.navigate.toScreen, 19, @"expected 19, but %d",gesture.navigate.toScreen);
						break;
					case 1:
						STAssertEquals(gesture.navigate.toGroup, 19, @"expected 19, but %d",gesture.navigate.toGroup);
						break;
					case 2:
						STAssertEquals(gesture.navigate.isSetting, YES, @"expected YES, but %d",gesture.navigate.isSetting);
						break;
					case 3:
						STAssertTrue(gesture.navigate == nil, @"expected nil, but %d",gesture.navigate);
						break;
					default:
						break;
				}
				
				gesture_index++;
				
			}
			NSLog(@"screen %@ has %d layout", screen.name, screen.layouts.count);
			for (LayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[AbsoluteLayoutContainer class]]){					
					NSLog(@"laylongt is absolute ");
					AbsoluteLayoutContainer *abso =(AbsoluteLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%d %d %d %d",abso.left,abso.top,abso.width,abso.height];
					NSString *expectedAttrs = @"20 320 100 100";
					STAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					if ([abso.component isKindOfClass:[Slider class]]) {
						Slider *theSlider = (Slider *)abso.component;
						int expectedId = (59 + slider_index++);
						STAssertTrue(expectedId == theSlider.componentId,@"expected %d, but %d",expectedId,theSlider.componentId);
						float maxValue = 100.0f;						
						STAssertTrue(theSlider.maxValue == maxValue,@"expected %f, but %f", maxValue, theSlider.maxValue);
						float minValue = 0.0f;
						STAssertTrue(theSlider.minValue == minValue,@"expected %f, but %f", minValue, theSlider.minValue);
					}					
				}				
			}
		}
	}
	
	NSLog(@"groups count = %d",[groups count]);
	NSLog(@"screens count = %d",[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
	
	//check groups
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
	Screen *screen1 = (Screen *)[screens objectAtIndex:0];
	NSString *ids = [[screen1 pollingComponentsIds] componentsJoinedByString:@","];
	STAssertTrue([@"59,60" isEqualToString:ids],@"expected 59,60 but %@",ids);
}
*/
// panel_global_tabbar.xml test
- (void) testParsePanelGlobalTabbarXML {
	NSLog(@"Begin testParsePanelTabbarXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_global_tabbar"]];
    Definition *definition = [parser parseDefinitionFromXML:data];

	// Begin assert tabbar.
	ORTabBar *tabBar = definition.tabBar;
	NSLog(@"Tabbar is : %@", tabBar);
	NSMutableArray *expectedTabBarItemsName = [NSMutableArray arrayWithObjects:@"previous", @"next", @"setting", nil];
	NSMutableArray *expectedTabBarItemsImageSrc = [NSMutableArray arrayWithObjects:@"previous.png", @"next.png", @"setting.png", nil];
	NSArray *tabBarItems = tabBar.items;
	NSLog(@"TabBar items count is : %lu", (unsigned long)tabBarItems.count);
	for (int i=0; i<tabBarItems.count; i++) {
		ORTabBarItem *tabBarItem = [tabBarItems objectAtIndex:i];
		
		// assert tabbar item name.
		NSString *expectedTabBarItemName = [expectedTabBarItemsName objectAtIndex:i];
		XCTAssertTrue([tabBarItem.label.text isEqualToString:expectedTabBarItemName], @"expected %@, but %@", expectedTabBarItemName, tabBarItem.label.text);
		NSLog(@"tabbarItemName is %@", tabBarItem.label.text);
		NSLog(@"expectedTabbarItemName is %@", expectedTabBarItemName);
		/*
		// assert tabbar item navigate
		ORNavigation *navigate = tabBarItem.navigation;
		BOOL expectedIsPreviousScreen = YES;
		BOOL expectedIsNextScreen = YES;
		BOOL expectedIsSetting = YES;
		
		BOOL isPreviousScreen = navigate.isPreviousScreen;
		BOOL isNextScreen = navigate.isNextScreen;
		BOOL isSetting = navigate.isSetting;
		if (i % 3 == 0) {
			STAssertTrue(isPreviousScreen == expectedIsPreviousScreen, @"expected %d, but %d", expectedIsPreviousScreen, isPreviousScreen);
		} else if (i % 3 == 1) {
			STAssertTrue(isNextScreen == expectedIsNextScreen, @"expected %d, but %d", expectedIsNextScreen, isNextScreen);
		} else if (i % 3 == 2) {
			STAssertTrue(isSetting == expectedIsSetting, @"expected %d, but %d", expectedIsSetting, isSetting);
		}
		NSLog(@"IsPreviousScreen is %d", isPreviousScreen);
		NSLog(@"isNextScreen is %d", isNextScreen);
		NSLog(@"isSetting is %d", isSetting);
		*/
		// assert tabbar item image
		NSString *expectedTabBarItemImageSrc = [expectedTabBarItemsImageSrc objectAtIndex:i];
		XCTAssertTrue([tabBarItem.image.src isEqualToString:expectedTabBarItemImageSrc], @"expected %@, but %@", expectedTabBarItemImageSrc, tabBarItem.image.src);
		NSLog(@"tabBarItemImage src is %@", [[tabBarItem image] src]);
		NSLog(@"expectedTabBarItemsImage src is %@", expectedTabBarItemImageSrc);
	}
	// End assert tabbar.
	
	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	NSLog(@"Has %lu grounp(s).", (unsigned long)[groups count]);
	int background_index = 1;
	int image_index = 0;
	int state_index = 0;
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	for (ORGroup *group in groups) {
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			/*
			NSLog(@"Begin test background of screen %@", [screen name]);
			// relative position
			STAssertTrue(![[screen background] isBackgroundImageAbsolutePosition], @"expected %d, but %d", NO, [[screen background] isBackgroundImageAbsolutePosition]);
			NSLog(@"isBackgroundImageAbsolutePosition of screen background is %d", [[screen background] isBackgroundImageAbsolutePosition]);
			
			NSString *backgroundImageRelativePosition = [[screen background] backgroundImageRelativePosition];
			NSString *expectedBackgroundImageRelativePosition;
			if (background_index%2 != 0) {
				expectedBackgroundImageRelativePosition = BG_IMAGE_RELATIVE_POSITION_LEFT;
			} else {
				expectedBackgroundImageRelativePosition = BG_IMAGE_RELATIVE_POSITION_RIGHT;
			}
			STAssertTrue([backgroundImageRelativePosition isEqualToString:expectedBackgroundImageRelativePosition], @"expected %@, but %@", expectedBackgroundImageRelativePosition, backgroundImageRelativePosition);
			NSLog(@"relative position of background image is %@", backgroundImageRelativePosition);
			
			// fillscreen
			BOOL fillScreen = [[screen background] fillScreen];
			BOOL expectedFillScreen = NO;
			STAssertTrue(fillScreen == expectedFillScreen, @"expected %d, but %d", expectedFillScreen, fillScreen);
			NSLog(@"fillScreen of background image is %d", fillScreen);
			
			// background image src
			NSString *backgroundImageSrc = [[[screen background] backgroundImage] src];
			NSString *expectedBackgroundImageSrc = [[NSString alloc] initWithFormat:@"basement%d.png", background_index];
			STAssertTrue([expectedBackgroundImageSrc isEqualToString:backgroundImageSrc], @"expected %@, but %@", expectedBackgroundImageSrc, backgroundImageSrc);
			NSLog(@"background image src of background is %@", backgroundImageSrc);
			
			NSLog(@"End test background of screen %@", [screen name]);			
			background_index++;
			*/
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORGridLayoutContainer class]]){					
					NSLog(@"layout is grid ");
					ORGridLayoutContainer *grid =(ORGridLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu",(long)grid.left, (long)grid.top,(unsigned long)grid.width,(unsigned long)grid.height];
					NSString *expectedAttrs = @"20 20 300 400";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					for (ORGridCell *cell in grid.cells) {
						[cells addObject:cell];
						if ([cell.widget isKindOfClass:[ORImage class]]) {
							ORImage *theImage = (ORImage *)cell.widget;
							ORObjectIdentifier *expectedId = [[ORObjectIdentifier alloc] initWithIntegerId:(59 + image_index++)];
							XCTAssertEqualObjects(expectedId, theImage.identifier, @"expected %@, but %@", expectedId, theImage.identifier);
							NSString *imageSrc = [[NSString alloc] initWithFormat:@"%c.png", (char)97 + state_index++];					
							XCTAssertTrue([theImage.src isEqualToString:imageSrc],@"expected %@, but %@", imageSrc, theImage.src);
						}	
					}
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
    /*
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
     */
	
	//check groups
    /*
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
     */

	NSLog(@"End testParsePanelTabbarXML");
}

// panel_local_tabbar.xml test
- (void) testParsePanelLocalTabbarXML {
	NSLog(@"Begin testParsePanelTabbarXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_local_tabbar"]];
    Definition *definition = [parser parseDefinitionFromXML:data];

	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;
	NSLog(@"Has %lu grounp(s).", (unsigned long)[groups count]);
	int background_index = 1;
	int image_index = 0;
	int state_index = 0;
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	for (ORGroup *group in groups) {
		// Begin assert tabbar
		ORTabBar *localTabBar = group.tabBar;
		NSLog(@"LocalTabbar of grounp '%@' is : %@", group.name, localTabBar);
		NSMutableArray *expectedLocalTabBarItemsName = [NSMutableArray arrayWithObjects:@"previous", @"next", @"setting", nil];
		NSMutableArray *expectedLocalTabBarItemsImageSrc = [NSMutableArray arrayWithObjects:@"previous.png", @"next.png", @"setting.png", nil];
		NSArray *localTabBarItems = localTabBar.items;
		NSLog(@"LocalTabBar items count of group '%@' is : %lu", group.name, (unsigned long)localTabBarItems.count);
		for (int i=0; i<localTabBarItems.count; i++) {
			ORTabBarItem *localTabBarItem = [localTabBarItems objectAtIndex:i];
			
			// assert tabbar item name.
			NSString *expectedLocalTabBarItemName = [expectedLocalTabBarItemsName objectAtIndex:i];
			XCTAssertTrue([localTabBarItem.label.text isEqualToString:expectedLocalTabBarItemName], @"expected %@, but %@", expectedLocalTabBarItemName, localTabBarItem.label.text);
			NSLog(@"localTabbarItemName is %@", localTabBarItem.label.text);
			NSLog(@"expectedLocalTabbarItemName is %@", expectedLocalTabBarItemName);
		
/*
			// assert tabbar item navigate
			ORNavigation *navigate = localTabBarItem.navigation;
			BOOL expectedIsPreviousScreen = YES;
			BOOL expectedIsNextScreen = YES;
			BOOL expectedIsSetting = YES;

			BOOL isPreviousScreen = navigate.isPreviousScreen;
			BOOL isNextScreen = navigate.isNextScreen;
			BOOL isSetting = navigate.isSetting;
			if (i % 3 == 0) {
				STAssertTrue(isPreviousScreen == expectedIsPreviousScreen, @"expected %d, but %d", expectedIsPreviousScreen, isPreviousScreen);
			} else if (i % 3 == 1) {
				STAssertTrue(isNextScreen == expectedIsNextScreen, @"expected %d, but %d", expectedIsNextScreen, isNextScreen);
			} else if (i % 3 == 2) {
				STAssertTrue(isSetting == expectedIsSetting, @"expected %d, but %d", expectedIsSetting, isSetting);
			}
			NSLog(@"IsPreviousScreen of local TabBarItem '%@' navigate is %d", localTabBarItem.tabBarItemName, isPreviousScreen);
			NSLog(@"isNextScreen of local TabBarItem '%@' navigate is %d", localTabBarItem.tabBarItemName, isNextScreen);
			NSLog(@"isSetting of local TabBarItem '%@' navigate is %d", localTabBarItem.tabBarItemName, isSetting);
	*/
			// assert tabbar item image
			NSString *expectedLocalTabBarItemImageSrc = [expectedLocalTabBarItemsImageSrc objectAtIndex:i];
			XCTAssertTrue([localTabBarItem.image.src isEqualToString:expectedLocalTabBarItemImageSrc], @"expected %@, but %@", expectedLocalTabBarItemImageSrc, localTabBarItem.image.src);
			NSLog(@"localTabBarItemImage src is %@", [[localTabBarItem image] src]);
			NSLog(@"expectedLocalTabBarItemsImage src is %@", expectedLocalTabBarItemImageSrc);
		}
		// End assert tabbar
		
		NSLog(@"group %@ has %lu screen", group.name,(unsigned long)group.screens.count);
		for (ORScreen *screen in group.screens) {
			/*
			NSLog(@"Begin test background of screen %@", [screen name]);
			// relative position
			STAssertTrue(![[screen background] isBackgroundImageAbsolutePosition], @"expected %d, but %d", NO, [[screen background] isBackgroundImageAbsolutePosition]);
			NSLog(@"isBackgroundImageAbsolutePosition of screen background is %d", [[screen background] isBackgroundImageAbsolutePosition]);
			
			NSString *backgroundImageRelativePosition = [[screen background] backgroundImageRelativePosition];
			NSString *expectedBackgroundImageRelativePosition;
			if (background_index%2 != 0) {
				expectedBackgroundImageRelativePosition = BG_IMAGE_RELATIVE_POSITION_LEFT;
			} else {
				expectedBackgroundImageRelativePosition = BG_IMAGE_RELATIVE_POSITION_RIGHT;
			}
			STAssertTrue([backgroundImageRelativePosition isEqualToString:expectedBackgroundImageRelativePosition], @"expected %@, but %@", expectedBackgroundImageRelativePosition, backgroundImageRelativePosition);
			NSLog(@"relative position of background image is %@", backgroundImageRelativePosition);
			
			// fillscreen
			BOOL fillScreen = [[screen background] fillScreen];
			BOOL expectedFillScreen = NO;
			STAssertTrue(fillScreen == expectedFillScreen, @"expected %d, but %d", expectedFillScreen, fillScreen);
			NSLog(@"fillScreen of background image is %d", fillScreen);
			
			// background image src
			NSString *backgroundImageSrc = [[[screen background] backgroundImage] src];
			NSString *expectedBackgroundImageSrc = [[NSString alloc] initWithFormat:@"basement%d.png", background_index];
			STAssertTrue([expectedBackgroundImageSrc isEqualToString:backgroundImageSrc], @"expected %@, but %@", expectedBackgroundImageSrc, backgroundImageSrc);
			NSLog(@"background image src of background is %@", backgroundImageSrc);
			
			NSLog(@"End test background of screen %@", [screen name]);			
			background_index++;
			*/
			NSLog(@"screen %@ has %lu layout", screen.name, (unsigned long)screen.layouts.count);
			for (ORLayoutContainer *layout in screen.layouts) {
				if([layout isKindOfClass:[ORGridLayoutContainer class]]){					
					NSLog(@"layout is grid ");
					ORGridLayoutContainer *grid =(ORGridLayoutContainer *)layout;
					NSString *layoutAttrs = [[NSMutableString alloc] initWithFormat:@"%ld %ld %lu %lu", (long)grid.left,(long)grid.top,(unsigned long)grid.width,(unsigned long)grid.height];
					NSString *expectedAttrs = @"20 20 300 400";
					XCTAssertTrue([expectedAttrs isEqualToString:layoutAttrs],@"expected %@, but %@",expectedAttrs,layoutAttrs);
					
					for (ORGridCell *cell in grid.cells) {
						[cells addObject:cell];
						if ([cell.widget isKindOfClass:[ORImage class]]) {
							ORImage *theImage = (ORImage *)cell.widget;
							ORObjectIdentifier *expectedId = [[ORObjectIdentifier alloc] initWithIntegerId:(59 + image_index++)];
							XCTAssertEqualObjects(expectedId, theImage.identifier, @"expected %@, but %@", expectedId, theImage.identifier);
							NSString *imageSrc = [[NSString alloc] initWithFormat:@"%c.png", (char)97 + state_index++];					
							XCTAssertTrue([theImage.src isEqualToString:imageSrc],@"expected %@, but %@", imageSrc, theImage.src);
						}	
					}
				}				
			}
		}
	}
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);
	NSLog(@"xml parse done");
	
	NSMutableArray *screenNames = [NSMutableArray arrayWithObjects:@"basement",@"floor",nil];
	NSMutableArray *groupNames = [NSMutableArray arrayWithObjects:@"All rooms",@"living room",nil];
	
	//check screens
    /*
	for (int i=0;i<screenNames.count;i++) {
		STAssertTrue([[screenNames objectAtIndex:i] isEqualToString:[[screens objectAtIndex:i] name]],@"expected %@, but %@",[screenNames objectAtIndex:i],[[screens objectAtIndex:i] name]);
		STAssertTrue(i+5 == [[screens objectAtIndex:i] screenId],@"expected %d, but %d",i+5,[[screens objectAtIndex:i] screenId]);
	}
     */
	
	//check groups
    /*
	for (int i=0;i<groupNames.count;i++) {
		STAssertTrue([[groupNames objectAtIndex:i] isEqualToString:[[groups objectAtIndex:i] name]],@"expected %@, but %@",[groupNames objectAtIndex:i],[[groups objectAtIndex:i] name]);
		STAssertTrue(i+1 == [[groups objectAtIndex:i] groupId],@"expected %d, but %d",i+1,[[groups objectAtIndex:i] groupId]);
	}
     */
	
	NSLog(@"End testParsePanelTabbarXML");
}


// panel_portrait_landscape.xml test
- (void) testParsePanelPortraitLandscapeXML {
	NSLog(@"Begin testParsePanelPortraitLandscapeXML");
    PanelDefinitionParser *parser = [[PanelDefinitionParser alloc] init];
    NSData *data = [[NSData alloc] initWithContentsOfFile:[self pathForXMLFile:@"panel_portrait_landscape"]];
    Definition *definition = [parser parseDefinitionFromXML:data];

	NSMutableArray *groups = definition.groups;
	NSMutableArray *screens = definition.screens;

    /*
	int screen_index = 0;
	for (Group *group in groups) {
		NSLog(@"group %@ has %d screen", group.name,group.screens.count);
		for (ORScreen *screen in group.screens) {
			STAssertTrue([@"Starting Screen" isEqualToString:screen.name], @"expected 'Starting Screen' but %@", screen.name);
			if (screen_index == 0) {
				STAssertTrue(screen.screenId == 1, @"expected 1 but %d", screen.screenId);
				STAssertTrue(screen.landscape == NO, @"expected NO but %d", screen.landscape);
				STAssertTrue(screen.inverseScreenId == 0, @"expected 0 but %d", screen.inverseScreenId);
			} else if (screen_index == 1) {
				STAssertTrue(screen.screenId == 21, @"expected 21 but %d", screen.screenId);
				STAssertTrue(screen.landscape == NO, @"expected NO but %d", screen.landscape);
				STAssertTrue(screen.inverseScreenId == 23, @"expected 23 but %d", screen.inverseScreenId);
			} else if (screen_index == 2) {
				STAssertTrue(screen.screenId == 23, @"expected 23 but %d", screen.screenId);
				STAssertTrue(screen.landscape == YES, @"expected YES but %d", screen.landscape);
				STAssertTrue(screen.inverseScreenId == 21, @"expected 21 but %d", screen.inverseScreenId);
			}
			screen_index++;
		}
		STAssertTrue([group getPortraitScreens].count	== 2, @"expected 2 but %d", [group getPortraitScreens].count);
		STAssertTrue([group getLandscapeScreens].count == 1, @"expected 1 but %d", [group getLandscapeScreens].count);
	}
     */
	
	NSLog(@"groups count = %lu",(unsigned long)[groups count]);
	NSLog(@"screens count = %lu",(unsigned long)[screens count]);

	NSLog(@"xml parse done");
}

@end
