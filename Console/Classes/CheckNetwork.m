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

#import "CheckNetwork.h"
#import "Reachability.h"
#import "ServerDefinition.h"
#import "CheckNetworkException.h"
#import "ControllerException.h"
#import "AppSettingsDefinition.h"
#import "CredentialUtil.h"
#import "ControllerException.h"
#import "NSString+ORAdditions.h"
#import "ORControllerConfig.h"
#import "ServerDefinition.h"

@interface CheckNetwork ()

/**
 * Check if the url of panel RESTful request if available. If it isn't, this method will throw CheckNetworkException.
 */
+ (void)checkPanelXmlForController:(ORControllerConfig *)controller timeout:(NSTimeInterval)timeoutInterval;

/**
 * Check if ip address of controller server is available. If it isn't, this method will throw CheckNetworkException.
 */
+ (void)checkIPAddressForController:(ORControllerConfig *)controller;

/**
 * Check if controller server's url is available. If it isn't, this method will throw CheckNetworkException.
 */
+ (void)checkControllerAvailable:(ORControllerConfig *)controller;

@end

@implementation CheckNetwork

+ (void)checkIPAddressForController:(ORControllerConfig *)controller {
    /*
     TODO EBR 6-Jul-2011
     Do not use this for now as this does not take mobile data connection into account
     Should review all the reachability code, also for "dynamic" changes in connection status
     
	@try {
		[CheckNetwork checkWhetherNetworkAvailable];
	}
	@catch (CheckNetworkException * e) {
		@throw e;
	}
     */
    
	// Extract host from server URL to use in reachability test
    NSString *host = [[ServerDefinition serverUrlForController:controller] hostOfURL];
    NSLog(@"Will check IP address %@", host);
    Reachability *reachability = nil;
//    if ([host isValidIPAddress]) {
//        reachability = [Reachability reachabilityWithAddress:host];
//    } else {
        reachability = [Reachability reachabilityWithHostName:host];
//    }

    NetworkStatus remoteHostReachability = [reachability currentReachabilityStatus];
	if (remoteHostReachability == NotReachable) {
		NSLog(@"checkIPAddress status is %ld", (long)remoteHostReachability);
		@throw [CheckNetworkException exceptionWithTitle:@"Check controller ip address Fail" message:@"Your server address is wrong, please check your settings"];
	}
}

+ (void)checkControllerAvailable:(ORControllerConfig *)controller {
	@try {
		[CheckNetwork checkIPAddressForController:controller];
	}
	@catch (CheckNetworkException * e) {
		@throw e;
	}
	
    /*
	NSError *error = nil;
	NSHTTPURLResponse *resp = nil;
	NSURL *url = [NSURL URLWithString:[ServerDefinition serverUrl]]; 
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT_INTERVAL];
    ORController *activeController = [ORConsoleSettingsManager sharedORConsoleSettingsManager].consoleSettings.selectedController;
	[CredentialUtil addCredentialToNSMutableURLRequest:request forController:activeController];

    
    URLConnectionHelper *connectionHelper = [[URLConnectionHelper alloc] init];
    
    
    // TODO EBR : Using this call is an issue if this is called from main thread, we're blocking everything !!!
    // Must a least of alternative ways to check for controller (async)
	[connectionHelper sendSynchronousRequest:request returningResponse:&resp error:&error];
	NSLog(@"%@", [ServerDefinition serverUrl]);
	[request release];
    [connectionHelper release];
	if (error ) {
		NSLog(@"checkControllerAvailable failed %@",[error localizedDescription]);
		@throw [CheckNetworkException exceptionWithTitle:@"Controller Not Started" 
													  message:@"Could not find OpenRemote Controller. It may not be running or the connection URL in Settings is invalid."];
	} else if ([resp statusCode] != 200) {	
		NSLog(@"checkControllerAvailable statusCode %d",[resp statusCode] );
		@throw [CheckNetworkException exceptionWithTitle:@"OpenRemote Controller Not Found" 
													  message:@"OpenRemote Controller not found on the configured URL. See 'Settings' to reconfigure. "];
	}
     */
}

+ (void)checkPanelXmlForController:(ORControllerConfig *)controller timeout:(NSTimeInterval)timeoutInterval
{
	@try {
		[CheckNetwork checkControllerAvailable:controller];
	}
	@catch (NSException * e) {
		@throw e;
	}

    
    // TODO: this should be encapsulated in communication objects as other calls
    
	NSHTTPURLResponse *resp = nil;
	NSError *error = nil;
	NSURL *url = [NSURL URLWithString:[[ServerDefinition panelXmlRESTUrlForController:controller]
                                            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]; 
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeoutInterval];
    ORControllerConfig *activeController = controller;
	[CredentialUtil addCredentialToNSMutableURLRequest:request forController:activeController];
    [request setHTTPMethod:@"HEAD"];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
    
	if ([resp statusCode] != 200 ){
		NSLog(@"CheckNetworkException statusCode=%ld, errorCode=%ld, %@, %@", (long)[resp statusCode], (long)[error code], url,[error localizedDescription]);
		
		if ([resp statusCode] == UNAUTHORIZED) {			
			@throw [CheckNetworkException exceptionWithTitle:@"" message:@"401"];
		} else {
			@throw [CheckNetworkException exceptionWithTitle:@"" message:[ControllerException controller:controller exceptionMessageOfCode:[resp statusCode]]];
		} 
		
	}
}

+ (void)checkAllForController:(ORControllerConfig *)controller timeout:(NSTimeInterval)timeoutInterval
{
	@try {
		[CheckNetwork checkPanelXmlForController:controller timeout:timeoutInterval];
	}
	@catch (NSException * e) {
		@throw e;
	}
}

@end
