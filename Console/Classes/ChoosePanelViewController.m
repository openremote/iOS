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
#import "ChoosePanelViewController.h"
#import "ServerDefinition.h"
#import "AppSettingsDefinition.h"
#import "ControllerException.h"
#import "CredentialUtil.h"
#import "ORControllerClient/Definition.h"
#import "NotificationConstant.h"
#import "ORConsoleSettingsManager.h"
#import "ORConsoleSettings.h"
#import "ORControllerConfig.h"
#import "ORControllerProxy.h"
#import "ViewHelper.h"

@interface ChoosePanelViewController ()

@property (nonatomic, strong) NSArray *panels;
@property (nonatomic, strong) NSString *chosenPanel;
@property (nonatomic, weak) ORControllerConfig *controller;
- (void)requestPanelList;

@end

@implementation ChoosePanelViewController

- (id)initWithController:(ORControllerConfig *)aController
{
    self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		[self setTitle:@"Panel List"];
        self.controller = aController;
		self.chosenPanel = self.controller.selectedPanelIdentityDisplayString;
		[self requestPanelList];
	}
	return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateLoginView:) name:NotificationPopulateCredentialView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerPanelIdentitiesFetchStatusChanged:) name:kORControllerPanelIdentitiesFetchStatusChange object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

// Load panel list from remote controller server.
- (void)requestPanelList {
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowLoading object:nil];
    [self.controller fetchPanels];
    
    // TODO EBR : cancel fetch when user going back
}

#pragma mark Table view methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
		return @"Choose Your Panel Identity:";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	return @"UI differs according to different panel identity.";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.panels.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *panelCellIdentifier = @"panelCell";
	UITableViewCell *panelCell = [tableView dequeueReusableCellWithIdentifier:panelCellIdentifier];
	
	if (panelCell == nil) {
		panelCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:panelCellIdentifier];
	}
	
	panelCell.textLabel.text = [self.panels objectAtIndex:indexPath.row];
	panelCell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if ([panelCell.textLabel.text isEqualToString:self.chosenPanel]) {
		panelCell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	return panelCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.delegate didSelectPanelIdentity:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
}

- (void)presentLoginRequestForControllerRequest:(ControllerRequest *)controllerRequest
{
	LoginViewController *loginController = [[LoginViewController alloc] initWithController:self.controller delegate:self context:controllerRequest];
	UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginController];
	[self presentViewController:loginNavController animated:YES completion:nil];
}

- (void)loginViewControllerDidCancelLogin:(LoginViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginViewController:(LoginViewController *)controller didProvideUserName:(NSString *)username password:(NSString *)password
{
    ORControllerConfig *orController = ((ControllerRequest *)controller.context).controller;
    if (!orController) {
        orController = self.controller;
    }
    orController.userName = username;
	orController.password = password;
    
    // TODO: we used to save here, is it OK not to, maybe need to save in dedicated MOC
    // [[ORConsoleSettingsManager sharedORConsoleSettingsManager] saveConsoleSettings];
    
	[self dismissViewControllerAnimated:YES completion:nil];
    
    [(ControllerRequest *)controller.context retry];
}

- (void)updateTableView {
	NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
	for (int j = 0; j < [self.panels count]; j++) {
		[insertIndexPaths addObject:[NSIndexPath indexPathForRow:j inSection:0]];
	}

	[self.tableView beginUpdates];
	[self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
	[self.tableView endUpdates];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideLoading object:nil];
}

- (BOOL)shouldAutorotate {
	return YES;
}

#pragma mark notifications handling

- (void)orControllerPanelIdentitiesFetchStatusChanged:(NSNotification *)notification
{
    ORControllerConfig *controller = [notification object];
    
    if (controller.panelIdentitiesFetchStatus == FetchSucceeded) {        
        self.panels = controller.panelIdentities;
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideLoading object:nil];
        [self updateTableView];
    } else if (controller.panelIdentitiesFetchStatus == FetchFailed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideLoading object:nil];
        [ViewHelper showAlertViewWithTitle:@"Panel List Error" Message:@"Impossible to get list of panels from controller"];
    }
}

- (void)populateLoginView:(NSNotification *)notification
{
    [self presentLoginRequestForControllerRequest:[notification.userInfo objectForKey:kAuthenticationRequiredControllerRequest]];
}

@synthesize delegate;
@synthesize panels;

@end