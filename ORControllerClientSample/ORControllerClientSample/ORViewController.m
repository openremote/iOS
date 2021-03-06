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

#import <ORControllerClient/ORController.h>
#import "ORViewController.h"
#import "ORViewController_Private.h"
#import "LoginViewController.h"
#import "ORControllerClient/ORControllerAddress.h"
#import "ORControllerClient/ORControllerInfo.h"
#import "ORControllerClient/ORController.h"
#import "ORControllerClient/Definition.h"
#import "ORControllerClient/ORUserPasswordCredential.h"
#import "ORControllerPickerViewController.h"

#define CONTROLLER_ADDRESS @"http://localhost:8080/controller"
//#define CONTROLLER_ADDRESS @"https://localhost:8443/controller"

@interface ORViewController () <ORControllerPickerViewControllerDelegate>


@property (atomic) BOOL gotLogin;
@property (atomic, strong) NSObject <ORCredential> *_credentials;
@property (atomic, strong) NSCondition *loginCondition;

@property (atomic) BOOL didAcceptCertificate;
@property (atomic, strong) NSCondition *certificateCondition;

@property (nonatomic, strong) NSString *controllerAddress;

@end

@implementation ORViewController

- (void)viewDidLoad
{
    self.controllerAddress = CONTROLLER_ADDRESS;
    self.title = self.controllerAddress;
    self.toolbarItems = @[[[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startPolling)],
    [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStylePlain target:self action:@selector(stopPolling)]];
    self.navigationController.toolbarHidden = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(pickController:)];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isMovingToParentViewController) {
        // Appearing because we're coming form top level menu, create an ORB
        [self createOrb];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController) {
        // Disappearing because we're going back to top level menu, get rid of ORB
        [self stopPolling];
        self.orb = nil;
    }
    [super viewDidDisappear:animated];
}

- (void)pickController:(id)sender
{
    [self stopPolling];

    ORControllerPickerViewController *vc = [[ORControllerPickerViewController alloc] init];
    vc.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // We're not guaranteed that the value we observe is set on the main thread,
    // so ensure we're updating our UI on the main thread here
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (void)createOrb
{
    ORControllerAddress *address = [[ORControllerAddress alloc] initWithPrimaryURL:[NSURL URLWithString:self.controllerAddress]];
    self.orb = [[ORController alloc] initWithControllerAddress:address];
    
    // We set ourself as the authenticationManager, we'll provide the credential by asking the user
    // for a username / password
    self.orb.authenticationManager = self;
}

- (void)startPolling
{
}

- (void)stopPolling
{
    [self.orb disconnect];
}

#pragma mark - ORControllerPickerViewController delegate implementation

- (void)controllerPicker:(ORControllerPickerViewController *)picker didPickController:(ORControllerInfo *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.controllerAddress = [controller.address.primaryURL description];
        self.title = self.controllerAddress;
        [self createOrb];
    }];
}

- (void)controllerPickerDidCancelPick:(ORControllerPickerViewController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ORAuthenticationManager implementation

- (NSObject <ORCredential> *)credential
{
    self.gotLogin = NO;
    self.loginCondition = [[NSCondition alloc] init];
    
    // "Dummy" implementation for this sample code as no caching is performed.
    // Any time a credential is required, we'll ask the user
    
    // Make sure presenting the login panel is done on the main thread,
    // as this method call is done on a background thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:[[LoginViewController alloc] initWithDelegate:self] animated:YES completion:NULL];
    });
    
    // As this code is executing in the background, it's safe to block here for some time
    [self.loginCondition lock];
    if (!self.gotLogin) {
        [self.loginCondition wait];
    }
    [self.loginCondition unlock];
    self.loginCondition = nil;
    
    return self._credentials;
}

- (BOOL)acceptServer:(NSURLProtectionSpace *)protectionSpace
{
    self.didAcceptCertificate = NO;
    self.certificateCondition = [[NSCondition alloc] init];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Invalid certificate"
                                    message:[NSString stringWithFormat:@"Certificate for host '%@' can not be validated, do you want to proceed with the connection ?", protectionSpace.host]
                                   delegate:self
                          cancelButtonTitle:@"No"
                          otherButtonTitles:@"Yes", nil] show];
    });

    [self.certificateCondition lock];
    [self.certificateCondition wait];
    [self.certificateCondition unlock];
    self.certificateCondition = nil;
    
    return self.didAcceptCertificate;
}

#pragma mark - LoginViewController delegate implementation

- (void)loginViewControllerDidCancelLogin:(LoginViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.loginCondition lock];
        self.gotLogin = YES;
        self._credentials = nil;
        [self.loginCondition signal];
        [self.loginCondition unlock];
    }];
}

- (void)loginViewController:(LoginViewController *)controller didProvideUserName:(NSString *)username password:(NSString *)password
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.loginCondition lock];
        self._credentials = [[ORUserPasswordCredential alloc] initWithUsername:username password:password];
        self.gotLogin = YES;
        [self.loginCondition signal];
        [self.loginCondition unlock];
    }];
}

#pragma mark - Alert (certificate accept) delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.certificateCondition lock];
    self.didAcceptCertificate = (buttonIndex == 1);
    [self.certificateCondition signal];
    [self.certificateCondition unlock];
}

@end
