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

#import "ORConsoleAuthenticationManager.h"
#import "ORControllerConfig.h"
#import <ORControllerClient/ORUserPasswordCredential.h>
#import "AppDelegate.h"
#import "DefaultViewController.h"

@interface ORConsoleAuthenticationManager ()

@property (nonatomic, strong) ORControllerConfig *controller;

@property (atomic) BOOL gotLogin;
@property (atomic, strong) NSCondition *loginCondition;


//@property (atomic, strong) NSObject <ORCredential> *_credentials;

@end

@implementation ORConsoleAuthenticationManager

- (instancetype)initWithController:(ORControllerConfig *)aController
{
    self = [super init];
    if (self) {
        self.controller = aController;
    }
    return self;
}

#pragma mark - ORAuthenticationManager

- (NSObject <ORCredential> *)credential
{
    if (!self.controller.userName || !self.controller.password) {
        
        
        
        
        
        self.gotLogin = NO;
        self.loginCondition = [[NSCondition alloc] init];
        
        // Make sure presenting the login panel is done on the main thread,
        // as this method call is done on a background thread
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            DefaultViewController *vc = delegate.defaultViewController;
            [vc presentLoginViewWithDelegate:self forController:self.controller];
        });
        
        // As this code is executing in the background, it's safe to block here for some time
        [self.loginCondition lock];
        if (!self.gotLogin) {
            [self.loginCondition wait];
        }
        [self.loginCondition unlock];
        self.loginCondition = nil;
    }
    // TODO: if we don't have username/password yet, must present UI to user for input
    // Also see how to handle fact that username / password we have is the wrong one
    // what do we need to keep to be able to trace that
    
    return [[ORUserPasswordCredential alloc] initWithUsername:self.controller.userName password:self.controller.password];
}

- (BOOL)acceptServer:(NSURLProtectionSpace *)protectionSpace
{
    // TODO: basic validation of certificate
    
    return YES;
}

- (void)loginViewControllerDidCancelLogin:(LoginViewController *)controller
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    DefaultViewController *vc = delegate.defaultViewController;

    [vc dismissViewControllerAnimated:YES completion:^{
        [self.loginCondition lock];
        self.gotLogin = YES;
//        self._credentials = nil;
        [self.loginCondition signal];
        [self.loginCondition unlock];
    }];
}

- (void)loginViewController:(LoginViewController *)controller didProvideUserName:(NSString *)username password:(NSString *)password
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    DefaultViewController *vc = delegate.defaultViewController;

    UIViewController *mainController = vc.presentedViewController.presentedViewController ? vc.presentedViewController.presentedViewController : vc.presentedViewController;

    [mainController dismissViewControllerAnimated:YES completion:^{
        [self.loginCondition lock];
//        self._credentials = [[ORUserPasswordCredential alloc] initWithUsername:username password:password];
        self.controller.userName = username;
        self.controller.password = password;
        self.gotLogin = YES;
        [self.loginCondition signal];
        [self.loginCondition unlock];
    }];
}

@end