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

#import "ORResponseHandler.h"
#import "ORResponseHandler_Private.h"
#import "ORControllerRESTAPI.h"
#import "ORRESTErrorParser.h"
#import "ORRESTError.h"
#import "ORAuthenticationManager.h"
#import "ORCredential.h"

@implementation ORResponseHandler

- (void)processValidResponseData:(NSData *)receivedData
{
	[self doesNotRecognizeSelector:_cmd];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection receivedData:(NSData *)receivedData
{
    if (self._errorCode) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
        if (STATUS_CODE_OR_SPECIFIC(self._errorCode)) {
            // OR specific errors code to provide an error message as the returned XML data
            ORRESTErrorParser *errorParser = [[ORRESTErrorParser alloc] initWithData:receivedData];
            ORRESTError *receivedError = [errorParser parseRESTError];
            
            userInfo[NSLocalizedDescriptionKey] = receivedError.message;
        } else {
            userInfo[NSLocalizedDescriptionKey] = @"Generic HTTP error";
        }
        NSURL *url = [[connection currentRequest] URL];
        userInfo[NSURLErrorFailingURLErrorKey] = url;
        userInfo[NSURLErrorFailingURLStringErrorKey] = [url absoluteString];

        if (self._errorHandler) {
            self._errorHandler([NSError errorWithDomain:kORClientErrorDomain code:self._errorCode userInfo:userInfo]);
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
            [self processValidResponseData:receivedData];
        });
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self._errorCode = 0;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger responseCode = [((NSHTTPURLResponse *)response) statusCode];
        if (responseCode != 200 && responseCode != 204) {
            self._errorCode = responseCode;
        }
    } else {
        // Handle as error, as this handler is only used for HTTP(S) communication
        
        
        // TODO
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Framework reported error, just pass upwards
    self._errorHandler(error);
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (!self.authenticationManager) {
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        return;
    }

    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    
    if ([NSURLAuthenticationMethodServerTrust isEqualToString:[protectionSpace authenticationMethod]]
        && [NSURLProtectionSpaceHTTPS isEqualToString:[protectionSpace protocol]]) {

        // Validating connection over HTTPS, ask authentication manager to accept (or not) server
        // Make sure that call is done on thread other than main
        // This allows authentication manager to block while getting credentials from user
        dispatch_async(dispatch_queue_create("org.openremote.handler.authentication", NULL), ^{
            if ([self.authenticationManager acceptServer:protectionSpace]) {
                NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
            } else {
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        });
    } else if ([NSURLAuthenticationMethodHTTPBasic isEqualToString:[protectionSpace authenticationMethod]]) {
        // Make sure request of credentials is done on thread other than main
        // This allows authentication manager to block while getting credentials from user
        dispatch_async(dispatch_queue_create("org.openremote.handler.authentication", NULL), ^{
            NSObject <ORCredential> *credential = self.authenticationManager.credential;
            if (credential) {
                [[challenge sender] useCredential:[credential URLCredential] forAuthenticationChallenge:challenge];
            } else {
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        });
    } else {
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
    // Note : Empty implementation of this -> no 401 reported -> must call continueWithoutCred...
    // Will it eventually time out or can this be kept pending for a while ? seems no timeout
}

@end
