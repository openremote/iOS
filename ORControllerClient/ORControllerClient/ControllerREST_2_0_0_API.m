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

#import "ControllerREST_2_0_0_API.h"
#import "PanelIdentityListResponseHandler_2_0_0.h"
#import "PanelLayoutResponseHandler_2_0_0.h"
#import "SensorValuesResponseHandler_2_0_0.h"
#import "ControlResponseHandler_2_0_0.h"
#import "RetrieveResourceResponseHandler.h"
#import "ORRESTCall_Private.h"
#import "ORObjectIdentifier.h"
#import "ORWidget.h"
#import "DeviceListResponseHandler_2_0_0.h"
#import "ORDevice.h"
#import "DeviceResponseHandler_2_0_0.h"
#import "ORDeviceCommand.h"
#import "ORDeviceCommandResponseHandler_2_0_0.h"
#import "NSStringAdditions.h"

@interface ControllerREST_2_0_0_API ()

- (ORRESTCall *)callForRequest:(NSURLRequest *)request delegate:(ORResponseHandler *)handler;

@end

@implementation ControllerREST_2_0_0_API

// Encapsulate delegate in ORDataCapturingNSURLConnectionDelegate before passing to created connection
// Handler is mandatory, otherwise authenticationManager can't be set and calls over HTTPS
// or to a secured controller won't work.
- (ORRESTCall *)callForRequest:(NSURLRequest *)request delegate:(ORResponseHandler *)handler
{    
    handler.authenticationManager = self.authenticationManager;
    ORRESTCall *call = [[ORRESTCall alloc] initWithRequest:request handler:handler];
    [call start];
//    NSLog(@"Started call for request %@", request);
    return call;
}

// TODO: these methods might still return some form of Operation object
// can be used to cancel operation -> handlers not called ??? or errorHandler called with special Cancelled error
// cancel is important e.g. for panel layout, as it fetches all the images
// can also be used to check operation status

- (ORRESTCall *)requestPanelIdentityListAtBaseURL:(NSURL *)baseURL
                       withSuccessHandler:(void (^)(NSArray *))successHandler
                             errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[baseURL URLByAppendingPathComponent:@"/rest/panels"]];
    
// TODO    [CredentialUtil addCredentialToNSMutableURLRequest:request withUserName:userName password:password];

    // TODO: check for nil return value -> error
    // TODO: should someone keep the connection pointer and "nilify" when done ?
    return [self callForRequest:request delegate:[[PanelIdentityListResponseHandler_2_0_0 alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)requestPanelLayoutWithLogicalName:(NSString *)panelLogicalName
                                atBaseURL:(NSURL *)baseURL
                       withSuccessHandler:(void (^)(Definition *))successHandler
                             errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[baseURL URLByAppendingPathComponent:@"/rest/panel/"]
                                           URLByAppendingPathComponent:panelLogicalName]];
    
    // TODO: same as above method
    // TODO: how about caching and resources ??? These should not be at this level, this is pure REST API facade
    return [self callForRequest:request delegate:[[PanelLayoutResponseHandler_2_0_0 alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)retrieveResourceNamed:(NSString *)resourceName
                            atBaseURL:(NSURL *)baseURL
                   withSuccessHandler:(void (^)(NSData *))successHandler
                         errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[baseURL URLByAppendingPathComponent:@"/resources"]
                                                                        URLByAppendingPathComponent:resourceName]];
    return [self callForRequest:request delegate:[[RetrieveResourceResponseHandler alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)statusForSensorIds:(NSSet *)sensorIds
               atBaseURL:(NSURL *)baseURL
      withSuccessHandler:(void (^)(NSDictionary *))successHandler
            errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[baseURL URLByAppendingPathComponent:@"/rest/status/"]
                                                                        URLByAppendingPathComponent:[[sensorIds allObjects] componentsJoinedByString:@","]]];
    
    return [self callForRequest:request delegate:[[SensorValuesResponseHandler_2_0_0 alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)pollSensorIds:(NSSet *)sensorIds fromDeviceWithIdentifier:(NSString *)deviceIdentifier
          atBaseURL:(NSURL *)baseURL
 withSuccessHandler:(void (^)(NSDictionary *))successHandler
       errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[[baseURL URLByAppendingPathComponent:@"/rest/polling/"]
                                                                        URLByAppendingPathComponent:deviceIdentifier]
                                                                        URLByAppendingPathComponent:[[sensorIds allObjects] componentsJoinedByString:@","]]];

    return [self callForRequest:request delegate:[[SensorValuesResponseHandler_2_0_0 alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)statusForSensorIdentifiers:(NSSet *)sensorIdentifiers
                                 atBaseURL:(NSURL *)baseURL
                        withSuccessHandler:(void (^)(NSDictionary *))successHandler
                              errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[baseURL URLByAppendingPathComponent:@"/rest/status/"]
                                                                        URLByAppendingPathComponent:[[[sensorIdentifiers allObjects] valueForKey:@"stringValue"] componentsJoinedByString:@","]]];
    
    return [self callForRequest:request delegate:[[SensorValuesResponseHandler_2_0_0 alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)pollSensorIdentifiers:(NSSet *)sensorIdentifiers fromDeviceWithIdentifier:(NSString *)deviceIdentifier
                            atBaseURL:(NSURL *)baseURL
                   withSuccessHandler:(void (^)(NSDictionary *))successHandler
                         errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[[baseURL URLByAppendingPathComponent:@"/rest/polling/"]
                                                                         URLByAppendingPathComponent:deviceIdentifier]
                                                                        URLByAppendingPathComponent:[[[sensorIdentifiers allObjects] valueForKey:@"stringValue"] componentsJoinedByString:@","]]];
    
    return [self callForRequest:request delegate:[[SensorValuesResponseHandler_2_0_0 alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)controlForWidget:(ORWidget *)widget // TODO: should we pass widget or just identifier
                          action:(NSString *)action // TODO: should this be given as param or infered from widget or ...
                       atBaseURL:(NSURL *)baseURL
              withSuccessHandler:(void (^)(void))successHandler // TODO: required ? anything meaningful to return ?
                    errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[[baseURL URLByAppendingPathComponent:@"/rest/control/"]
                                                                         URLByAppendingPathComponent:[widget.identifier stringValue]]
                                                                        URLByAppendingPathComponent:action]];
    [request setHTTPMethod:@"POST"];
    return [self callForRequest:request delegate:[[ControlResponseHandler_2_0_0 alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)requestDevicesListAtBaseURL:(NSURL *)baseURL withSuccessHandler:(void (^)(NSArray *))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[baseURL URLByAppendingPathComponent:@"/rest/devices"]];

// TODO    [CredentialUtil addCredentialToNSMutableURLRequest:request withUserName:userName password:password];

    // TODO: check for nil return value -> error
    // TODO: should someone keep the connection pointer and "nilify" when done ?
    return [self callForRequest:request delegate:[[DeviceListResponseHandler_2_0_0 alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)requestDevice:(ORDevice *)device baseURL:(NSURL *)baseURL withSuccessHandler:(void (^)(ORDevice *))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[baseURL URLByAppendingPathComponent:[@"/rest/devices" stringByAppendingPathComponent:device.name]]];

// TODO    [CredentialUtil addCredentialToNSMutableURLRequest:request withUserName:userName password:password];

    // TODO: check for nil return value -> error
    // TODO: should someone keep the connection pointer and "nilify" when done ?
    return [self callForRequest:request delegate:[[DeviceResponseHandler_2_0_0 alloc] initWithDevice:device successHandler:successHandler errorHandler:errorHandler]];
}

- (ORRESTCall *)executeCommand:(ORDeviceCommand *)command parameter:(NSString *)parameter baseURL:(NSURL *)baseURL withSuccessHandler:(void (^)())successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    NSString *urlString = [NSString stringWithFormat:@"/rest/devices/%@/commands?name=%@", command.device.name, command.name];
    NSURL *url = [NSURL URLWithString:[[baseURL absoluteString] stringByAppendingString:urlString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    if (parameter) {
        request.HTTPBody = [[NSString stringWithFormat:@"<parameter>%@</parameter>", [parameter escapeXmlEntities]] dataUsingEncoding:NSUTF8StringEncoding];
    }

// TODO    [CredentialUtil addCredentialToNSMutableURLRequest:request withUserName:userName password:password];

    // TODO: check for nil return value -> error
    // TODO: should someone keep the connection pointer and "nilify" when done ?
    return [self callForRequest:request delegate:[[ORDeviceCommandResponseHandler_2_0_0 alloc] initWithSuccessHandler:successHandler errorHandler:errorHandler]];
}
@end
