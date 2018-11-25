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
#import "LoginViewController.h"
#import "ORControllerClient/Definition.h"
#import "ViewHelper.h"
#import "NotificationConstant.h"
#import "ORControllerConfig.h"

@interface LoginViewController ()

- (void)goBack:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) NSObject <LoginViewControllerDelegate> *delegate;
@property (nonatomic, strong, readwrite) id context;

@property (nonatomic, weak) ORControllerConfig *controller;
@property (strong, nonatomic) IBOutlet UITableViewCell *userNameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *signInButtonCell;
@end

@implementation LoginViewController

- (id)initWithController:(ORControllerConfig *)aController delegate:(NSObject <LoginViewControllerDelegate> *)aDelegate context:(id)aContext
{
    self = [super initWithNibName:@"LoginViewController" bundle:nil];
    if (self) {
		[self setTitle:@"Sign in"];
        self.delegate = aDelegate;
        self.context = aContext;
        self.controller = aController;
	}
	return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.controller = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideLoading object:nil];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
}

// Back to the view where loginView was triggered from.
- (void)goBack:(id)sender
{
    [self.delegate loginViewControllerDidCancelLogin:self];
}

// Send sign in request to remote controller server by loginViewController's delegate.
- (IBAction)signin:(id)sender
{
	if (self.usernameField.text == nil || self.passwordField.text == nil ||
			[@"" isEqualToString:self.usernameField.text] || [@"" isEqualToString:self.passwordField.text]) {
		[ViewHelper showAlertViewWithTitle:@"" Message:@"No username or password entered."];
		return;
	}
    
    [self.delegate loginViewController:self didProvideUserName:self.usernameField.text password:self.passwordField.text];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 2;
	} else if (section == 1) {
		return 1;
	}
	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.usernameField becomeFirstResponder];
            self.usernameField.text = self.controller.userName;
            return self.userNameCell;
        } else if (indexPath.row == 1) {
            return self.passwordCell;
        }
	} else if (indexPath.section == 1) {
        return self.signInButtonCell;
	}
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[[cell textLabel] setBackgroundColor:[UIColor clearColor]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{	
	if ([@"" isEqualToString:self.usernameField.text]) {
		[self.usernameField becomeFirstResponder];
		return YES;
	} else {
		[self.passwordField becomeFirstResponder];		
	}
	
	if ([@"" isEqualToString:self.passwordField.text]) {
		[self.passwordField becomeFirstResponder];
		return YES;
	} else {
		[self.usernameField becomeFirstResponder];
	}
	
	[self signin:nil];

	return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return @"Sign in using your Controller username and password";
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 1) {
		return @"Commands and updates from Controller are secured. This requires user authentication.";
	}
	return nil;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

@end