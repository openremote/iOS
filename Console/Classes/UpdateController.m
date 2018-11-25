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

/*
  * For the update behavior.  
  * If you need know the update result and do something, you must set delegate and implement three delegate methods
  * - (void)didUpdate;
  * - (void)didUseLocalCache:(NSString *)errorMessage;
  * - (void)didUpdateFail:(NSString *)errorMessage;
  */
#import "UpdateController.h"
#import "AppSettingsDefinition.h"
#import "CheckNetwork.h"
#import "CheckNetworkException.h"
#import "ORControllerClient/Definition.h"
#import "NotificationConstant.h"
#import "StringUtils.h"
#import "ServerDefinition.h"
#import "DirectoryDefinition.h"
#import "RoundRobinException.h"
#import "CredentialUtil.h"
#import "ORConsoleSettingsManager.h"
#import "ORConsoleSettings.h"
#import "ORControllerConfig.h"
#import "ORGroupMember.h"
#import "DefinitionManager.h"

//Define the default max retry times. It should be set by user in later version.
#define MAX_RETRY_TIMES 0

#define DEFAULT_TIMEOUT_DURATION 60

@interface UpdateController ()

@property (nonatomic, weak) DefinitionManager *definitionManager;
@property (nonatomic, strong) ORConsoleSettings *settings;

- (void)checkNetworkAndUpdateUsingTimeout:(NSTimeInterval)timeoutInterval;
- (void)findServer;
- (void)updateFailOrUseLocalCache:(NSString *)errorMessage;
- (void)didUpdateFail:(NSString *)errorMessage;

@end

@implementation UpdateController

- (id)initWithSettings:(ORConsoleSettings *)theSettings definitionManager:(DefinitionManager *)aDefinitionManager delegate:(NSObject <UpdateControllerDelegate> *)aDelegate
{
    self = [super init];
    if (self) {
        self.settings = theSettings;
        self.delegate = aDelegate;
        self.definitionManager = aDefinitionManager;
        
        // TODO: should propably not be done here
        self.definitionManager.controller = self.settings.selectedController;
        
        retryTimes = 1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdate) name:DefinitionUpdateDidFinishNotification object:nil];
        
    }
    return self;
}

- (void)checkConfigAndUpdate
{
    [self checkConfigAndUpdateUsingTimeout:DEFAULT_TIMEOUT_DURATION];
}

// For lack of better name
// For now just extract behaviour to startup application
- (void)startup
{
    NSLog(@"UpdateController.startup");
    
    ORControllerConfig *selectedController = self.settings.selectedController;
    
    NSLog(@"Selected controller is %@", selectedController);
    
    if (selectedController) {
        
        if (selectedController.selectedPanelIdentity) {
            NSLog(@"Have all the information to load UI, starting update process");
            
            if (![self.definitionManager loadDefinitionFromCache]) {
                // TODO: if there is something in cache, it is used -> never updated -> how to achieve update
                
                [self.definitionManager update];
            }
            
            return;
        }
        
        // First try to use local cache so the user can directly interact with the UI, and trigger the check for update after that
//        [self useLocalCache];
        
        // TODO: should check if there is cached information available
        
        
        [self.delegate didUpdate];
        
        
        // Delay so that loading message is displayed
//        [self performSelector:@selector(checkConfigAndUpdate) withObject:nil afterDelay:0.0];
        
        
        [self refreshControllerInformation];
        
        

        

    } else {
        if ([self.settings.controllers count] == 1) {
            self.settings.selectedController = [self.settings.controllers lastObject];
            
            
            // TODO: next step of process is to contact controller
            // In this case, as we don't have anything to display, we can display a panel to the user indicating we're contacting the controller, plus option to cancel
            
            // At any point, if user cancel and we don't have enough information -> display message and allow him to go to settigns
            
            
            
            // TODO REMOVE !!!!
            // This does prevent console to "block" at this stage of development, but is not the full solution
            // MUST WORK ON THIS TO HAVE CLEAN SOLUTION
            [self.delegate didUpdate];
            
        } else if ([self.settings.controllers count] == 0) {
            // Launch auto-discovery
            
            // TODO: should notify user of process and allow to cancel
            // if cancel -> Settings
        } else {
            // Nothing automatic we can do, display settings screen but notify user first
            
            
            // TODO: for now it just displays the error page
            [self.delegate didUpdate];
            
        }
    }
}


/**
 * Contacts the controller and gather up to date information:
 * - group members
 * - capabilities
 * - panels
 * - update of selected panel
 */
- (void)refreshControllerInformation
{
    ORControllerConfig *controller = self.settings.selectedController;
    [controller fetchGroupMembers];
    
    [controller fetchCapabilities];
    
    [controller fetchPanels];

    
    // TODO: somehow when a command / status polling is send to controller, it should wait for controller to be ready -> that is group members and capabilities fetched
    // Maybe have a notification posted when controller is ready -> use that to start polling
    // For command sending, might have a popup to indicate that controller is not yet available
    
    // TODO: panels and update
}




// Read Application settings from appSettings.plist.
// If there have an defined server url. It will call checkNetworkAndUpdate method
// else if auto discovery is enable it will try to find another server url using auto discovery,
// else it will check local cache or call didUpdateFail method.
- (void)checkConfigAndUpdateUsingTimeout:(NSTimeInterval)timeoutInterval {

    
    /*
     * EBR : proposal for startup sequence
     * Is there a selected controller ?
     *   YES 1.1 fetch group members (in background)
     *       1.2 Is there a selected panel ?
     *         YES 1.2.1 Is there a cache for the panel definition ?
     *           YES 1.2.1.1.1 Load panel definition
     *               1.2.1.1.1 Display panel
     *           NO 1.2.1.2 Try to load panel definition from controller, progress bar displayed to user, cancel possibility -> go to Settings on cancel
     *                      Note that you need to have the group members resolved to do this
     *         NO 1.2.2 Display pop-up to user to select panel, then same as 1.1.2.2.1
     *   NO 2. Go to Settings
     *
     *
     *
     * Note: 1.2.1.2 Should also be used when exiting from the Settings page
     */
    
    // TODO EBR: On start-up, definition is nil as it's never been loaded from controller
    // Should have this loaded from cache if present -> !time to parse, if too big, have some lazy loading
	if (self.settings.selectedController.definition.groups.count > 0) {
        
        // Should not display loading indicator if the UI is already displayed
        
		[[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowLoading object:nil];
	}
	NSLog(@"check config");

    // If there is a selected controller (auto-discovered or configured), try to use it
	if (self.settings.selectedController) {
		[self checkNetworkAndUpdateUsingTimeout:timeoutInterval];
	} else {
        
        
        // TODO: this part should not be here
        
		NSLog(@"No selected controller found in configuration");
		if (self.settings.autoDiscovery) {
			[self findServer];
		} else {
			[self updateFailOrUseLocalCache:@"Can't find server url configuration. You can turn on auto-discovery or specify a server url in settings."];
		}
	}
}

// Try to find a server using auto discovery mechanism. 
- (void)findServer {
	NSLog(@"findServer");
	NSLog(@"retry time %d <= %d", retryTimes, MAX_RETRY_TIMES);
    
	if (retryTimes <= MAX_RETRY_TIMES) {		
		retryTimes++;
		if (serverAutoDiscoveryController) {
			serverAutoDiscoveryController = nil;
		}
		//ServerAutoDiscoveryController have  tow delegate methods
		// - (void)onFindServer:(NSString *)serverUrl;
		// - (void)onFindServerFail:(NSString *)errorMessage;
		serverAutoDiscoveryController = [[ServerAutoDiscoveryController alloc] initWithConsoleSettings:self.settings delegate:self];
	} else {
		[self updateFailOrUseLocalCache:@"Can't find OpenRemote controller automatically."];
	}	
}

// Check if network is available. If network is available, then update client.
- (void)checkNetworkAndUpdateUsingTimeout:(NSTimeInterval)timeoutInterval {
	NSLog(@"checkNetworkAndUpdate");
	@try {
		// this method will throw CheckNetworkException if the check failed.
		[CheckNetwork checkAllForController:self.settings.selectedController timeout:timeoutInterval];

		// TODO: check what we really want to do 
//		[self getRoundRobinGroupMembers];

		//Add an Observer to listern Definition's update behavior
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdate) name:DefinitionUpdateDidFinishNotification object:nil];
		// If all the check success, it will call Definition's update method to update resouces.
        
        [self.definitionManager update];
	}
	@catch (CheckNetworkException *e) {
		NSLog(@"CheckNetworkException occured %@",e.message);
		if (retryTimes <= MAX_RETRY_TIMES) {
			NSLog(@"retry time %d <= %d", retryTimes, MAX_RETRY_TIMES);
			retryTimes++;			
			[self checkNetworkAndUpdateUsingTimeout:timeoutInterval];
		} else {
			[self updateFailOrUseLocalCache:e.message];
		}
		
	}	
}

// Use local cache if update fail and local cache exists.
- (void)updateFailOrUseLocalCache:(NSString *)errorMessage {
	NSLog(@"updateFailOrUseLocalCache");
    [self didUpdateFail:errorMessage];
}

#pragma mark call the delegate method which the the delegate implemented.
- (void)didUpdate {
    NSLog(@">>UpdateController.didUpdate");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DefinitionUpdateDidFinishNotification object:nil];
    NSLog(@"theDelegate %@", delegate);
	if (delegate && [delegate respondsToSelector:@selector(didUpdate)]) {
		[delegate performSelector:@selector(didUpdate)];
	}
}

- (void)didUpdateFail:(NSString *)errorMessage {
	NSLog(@"didUpdateFail");
	if (delegate && [delegate respondsToSelector:@selector(didUpdateFail:)]) {
		[delegate performSelector:@selector(didUpdateFail:) withObject:errorMessage];
	}
}

#pragma mark delegate method of ServerAutoDiscoveryController
- (void)onFindServer:(ORControllerConfig *)aController {
	NSLog(@"onFindServer %@", aController.primaryURL);
	[self checkNetworkAndUpdateUsingTimeout:DEFAULT_TIMEOUT_DURATION];
}

- (void)onFindServerFail:(NSString *)errorMessage {
	NSLog(@"onFindServerFail %@",errorMessage);
		[self findServer];
}

-(void)dealloc
{
    serverAutoDiscoveryController = nil;
    [self removeObserver:self forKeyPath:@"imageCache"];
}

@synthesize delegate;

@end