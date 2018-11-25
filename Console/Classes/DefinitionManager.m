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
#import "DefinitionManager.h"
#import "ServerDefinition.h"
#import "DirectoryDefinition.h"
#import "StringUtils.h"
#import "ViewHelper.h"
#import "NotificationConstant.h"
#import "CheckNetwork.h"
#import "ORControllerClient/PanelDefinitionParser.h"
#import "ORControllerConfig.h"
#import "ORControllerClient/Definition.h"
#import "ORControllerClient/ORController.h"
#import "ImageCache.h"
#import "ORConsoleApp.h"

@interface DefinitionManager ()

- (void)postNotificationToMainThread:(NSString *)notificationName;
- (void)changeLoadingMessage:(NSString *)msg;

@property (nonatomic, strong) ORConsoleApp *console;

@end

@implementation DefinitionManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // TODO: not sure this is the place to build this
        self.console = [[ORConsoleApp alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.controller = nil;
    self.imageCache = nil;
}

- (void)update {
    if (isUpdating) {
		return;
	}
	isUpdating = YES;


    NSLog(@"===Before connect");
    [self.controller.controller connectWithSuccessHandler:^{
        [self.controller.controller requestPanelUILayout:self.controller.selectedPanelIdentity successHandler:^(Definition *definition) {
            self.controller.definition = definition;
            definition.console = self.console;

            self.imageCache.loader = self.controller;
            
            [self postNotificationToMainThread:DefinitionUpdateDidFinishNotification];
        } errorHandler:^(NSError *error) {
            // TODO
//            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideLoading object:nil];
            [self postNotificationToMainThread:DefinitionUpdateDidFinishNotification];
            [self connection:nil didFailWithError:error];
        }];
    } errorHandler:^(NSError *error) {
        // TODO
//        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideLoading object:nil];
        [self postNotificationToMainThread:DefinitionUpdateDidFinishNotification];
        [self connection:nil didFailWithError:error];
    }];
    NSLog(@"===After connect call");
    // TODO - EBR : check what needs to be added to queue e.g. updateOperation is not here
    // updateOperation added to queue in parseXMLData method, why ?
}

- (void)changeLoadingMessage:(NSString *)msg {
	if (loading) {
		//[loading setText:msg];
	}
}

//		for (NSString *imageName in self.controller.definition.imageNames) {
//			if (imageName) {
//				[self addDownloadImageOperationWithImageName:imageName];
//			}				
//		}

//Shows alertView when url connection failtrue
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR OCCUR" message:error.localizedDescription  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

#pragma mark post notification 
//post the notification to Main thread
- (void) postNotificationToMainThread:(NSString *)notificationName {
	NSLog(@"start post notification to main thread");
	[self performSelectorOnMainThread:@selector(postNotification:) withObject:notificationName waitUntilDone:NO];
	
	isUpdating = NO;
}

//create a NSNotification and add it to NSNotificationQueue
- (void) postNotification:(NSString *)notificationName {
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self ];
	NSLog(@"post nofication done");
}





#pragma mark -

- (void)saveDefinitionToCache
{
    // TODO: handle error
    [NSKeyedArchiver archiveRootObject:self.controller.definition toFile:[self definitionCacheFilePath]];
}

- (BOOL)loadDefinitionFromCache
{
    if (!self.controller) {
        return NO;
    }
    
    if (!self.controller.selectedPanelIdentity) {
        return NO;
    }

    Definition *definition = [NSKeyedUnarchiver unarchiveObjectWithFile:[self definitionCacheFilePath]];

    if (definition) {
      self.controller.definition = definition;
      definition.console = self.console;
        self.imageCache.loader = self.controller;

        [self.controller.controller attachPanelDefinition:definition];
        
        [self postNotificationToMainThread:DefinitionUpdateDidFinishNotification];

      return YES;
    }
    return NO;
}

- (NSString *)definitionCacheFilePath
{
    // TODO: the name should really be based on the controller identity, but this is a concept we don't fully have yet
    NSString *definitionCacheFileName = [NSString stringWithFormat:@"Definition_%@_%@_%@", [[self.controller.objectID URIRepresentation] host],
                                         [[[self.controller.objectID URIRepresentation] path] stringByReplacingOccurrencesOfString:@"/" withString:@"_"], self.controller.selectedPanelIdentity];
    return [[DirectoryDefinition cacheFolder] stringByAppendingPathComponent:definitionCacheFileName];
}

@synthesize isUpdating, loading;

@end