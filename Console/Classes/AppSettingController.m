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
#import "AppSettingController.h"
#import "DirectoryDefinition.h"
#import "ServerAutoDiscoveryController.h"
#import "AppSettingsDefinition.h"
#import "ViewHelper.h"
#import "UpdateController.h"
#import "NotificationConstant.h"
#import "CheckNetworkException.h"
#import "ORConsoleSettingsManager.h"
#import "ORConsoleSettings.h"
#import "ORControllerConfig.h"
#import "ORControllerProxy.h"
#import "ORControllerGroupMembersFetchStatusIconProvider.h"
#import "TableViewCellWithSelectionAndIndicator.h"
#import "ImageCache.h"
#import "UIDevice+ORAdditions.h"
#import "PanelMatcher.h"

@interface AppSettingController ()

// Indicates if a login window must be presented to user for entering credentials when a controller says authentication is required
@property (nonatomic, assign) BOOL askUserForCredentials;

@property (nonatomic, strong) NSIndexPath *currentSelectedServerIndex;

@property (nonatomic, weak) ORConsoleSettingsManager *settingsManager;

@property (nonatomic, strong) AppSettingsDefinition *settingsDefinition;

@property (nonatomic, weak) DefinitionManager *definitionManager;

- (void)autoDiscoverChanged:(id)sender;
- (void)saveSettings;
- (void)updatePanelIdentityView;
- (BOOL)isAutoDiscoverySection:(NSIndexPath *)indexPath;
- (BOOL)isControllerRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isAddCustomServerRow:(NSIndexPath *)indexPath;
- (void)cancelView:(id)sender;

- (void)autodiscoverControllersIfRequired;
- (void)fetchGroupMembersForAllControllers;
- (void)cancelFetchGroupMembers;

@end

// The section of table cell where autoDiscoverySwitch is in.
#define AUTO_DISCOVERY_SWITCH_SECTION 0

//auto discovery & customized controller server url are treat as one section
#define CONTROLLER_URLS_SECTION 1

// The section of table cell where selected panel identity is in.
#define PANEL_IDENTITY_SECTION 2

@implementation AppSettingController

- (id)initWithSettingsManager:(ORConsoleSettingsManager *)aSettingsManager definitionManager:(DefinitionManager *)aDefinitionManager
{
    self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
        self.settingsManager = aSettingsManager;
        self.definitionManager = aDefinitionManager;
        
        self.settingsDefinition = [[AppSettingsDefinition alloc] init];

		[self setTitle:@"Settings"];
		isEditing = NO;
        
		done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveSettings)];		
		cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelView:)];
	}
	return self;
}

- (void)dealloc
{
    self.imageCache = nil;
}

// Show spinner after title of "Choose Controller" while auto discovery running.
- (void)showSpinner {
	spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(210, 113, 44, 44)];
	[spinner startAnimating];
	spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
															UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	[spinner sizeToFit];
	
	[self.view addSubview:spinner];
}

// Hide spinner
- (void)forceHideSpinner:(BOOL)force {
	if (spinner && ([self.settingsManager.consoleSettings.controllers count] > 0 || force)) {
		[spinner removeFromSuperview];
		spinner = nil;
	}
}

- (void)populateLoginView:(NSNotification *)notification
{
    if ([notification.userInfo objectForKey:kAuthenticationRequiredControllerRequest]) {
        [self presentLoginRequestWithContext:[notification.userInfo objectForKey:kAuthenticationRequiredControllerRequest]];
    } else {
        [self presentLoginRequestWithContext:[notification object]];
    }
}

- (void)presentLoginRequestWithContext:(id)context
{
	LoginViewController *loginController = [[LoginViewController alloc] initWithController:self.settingsManager.consoleSettings.selectedController
                                                                                  delegate:self
                                                                                   context:context];
	UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginController];
	[self presentViewController:loginNavController animated:NO completion:nil];
}

// Check if the section parameter indexPath specified is auto discovery section.
- (BOOL)isAutoDiscoverySection:(NSIndexPath *)indexPath {
	return indexPath.section == AUTO_DISCOVERY_SWITCH_SECTION;
}

/**
 * Indicates if the row at the given index path represents a controller entry,
 * i.e. is in the controllers section and is not the "Add" entry.
 */
- (BOOL)isControllerRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == CONTROLLER_URLS_SECTION && indexPath.row < [self.settingsManager.consoleSettings.controllers count]);
}

/**
 * Indicates if the row at the given index path is the "Add" controller one.
 */
- (BOOL)isAddCustomServerRow:(NSIndexPath *)indexPath
{
	return (indexPath.row >= [self.settingsManager.consoleSettings.controllers count] && indexPath.section == CONTROLLER_URLS_SECTION);
}

- (void)autoDiscoverChanged:(id)sender
{
    self.settingsManager.consoleSettings.autoDiscovery = ((UISwitch *)sender).on;

    // Irrelevant of the choice, first cancel the current auto-discovery process
    if (autoDiscoverController) {
        [autoDiscoverController setDelegate:nil];
         // This will cancel connections if any
        autoDiscoverController = nil;
    }

    [self autodiscoverControllersIfRequired];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *footerView  = [[UIView alloc] init];
    footerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 70);
    
    UIButton *clearImageCacheButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearImageCacheButton setTitle:@"Clear image cache" forState:UIControlStateNormal];
    [clearImageCacheButton sizeToFit];
    [clearImageCacheButton addTarget:self action:@selector(clearImageCache) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:clearImageCacheButton];
    clearImageCacheButton.center = CGPointMake(footerView.center.x, footerView.frame.origin.y + clearImageCacheButton.frame.size.height / 2);
    clearImageCacheButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    versionLabel.text = [NSString stringWithFormat:@"OpenRemote iOS Console version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    versionLabel.textColor = [UIColor darkGrayColor];
    versionLabel.backgroundColor = [UIColor clearColor];
    [versionLabel sizeToFit];
    [footerView addSubview:versionLabel];
    versionLabel.center = CGPointMake(footerView.center.x, footerView.frame.origin.y + footerView.frame.size.height - (versionLabel.frame.size.height / 2));
    versionLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.tableView.tableFooterView = footerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateLoginView:) name:NotificationPopulateCredentialView object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerGroupMembersFetchStatusChanged:) name:kORControllerGroupMembersFetchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerGroupMembersFetchStatusChanged:) name:kORControllerGroupMembersFetchFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerGroupMembersFetchSucceeded:) name:kORControllerGroupMembersFetchSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerGroupMembersFetchRequiresAuthentication:) name:kORControllerGroupMembersFetchRequiresAuthenticationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerPanelIdentitiesFetchStatusChanged:) name:kORControllerPanelIdentitiesFetchStatusChange object:nil];

    self.navigationItem.rightBarButtonItem = done;
	self.navigationItem.leftBarButtonItem = cancel;
    
    [self.tableView reloadData]; // IPHONE-107, should not be required otherwise
}

- (void)viewWillDisappear:(BOOL)animated
{
    autoDiscoverController = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self autodiscoverControllersIfRequired];
    [self fetchGroupMembersForAllControllers];
    [self updatePanelIdentityView];
    [super viewDidAppear:animated];
}

// Updates panel identity view, but not persists identity data into appSettings.plist.
- (void)updatePanelIdentityView {
	UITableView *tv = (UITableView *)self.view;
	UITableViewCell *identityCell = [tv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:PANEL_IDENTITY_SECTION]];
	identityCell.textLabel.text = @"None";
    
    // !!! Panels won't fetch until capabilities are, this can cause issues of message blocked in queue
    [self.settingsManager.consoleSettings.selectedController fetchPanels];
    
    // TODO EBR : this might need to be cancelled some time
}

// Cancle(Dismiss) appSettings view.
- (void)cancelView:(id)sender
{
    [self.settingsManager cancelConsoleSettingsChanges];
	[self dismissViewControllerAnimated:YES completion:NULL];
}

// Persists settings info into appSettings.plist .
- (void)saveSettings {
	if ([self.settingsManager.consoleSettings.controllers count] == 0) {
		[ViewHelper showAlertViewWithTitle:@"Warning" Message:@"No Controller. Please configure Controller URL manually."];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowLoading object:nil];
		done.enabled = NO;
		cancel.enabled = NO;
		
        [self.settingsManager saveConsoleSettings];

		if (updateController) {
			updateController = nil;
		}
        updateController = [[UpdateController alloc] initWithSettings:self.settingsManager.consoleSettings definitionManager:self.definitionManager delegate:self];
        updateController.imageCache = self.imageCache;
        
        // Ensure that progress indicator appears immediately but code still executed on main thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [updateController checkConfigAndUpdate];
            });
        });
	}
}

#pragma mark Delegate method of ServerAutoDiscoveryController

- (void)onFindServer:(ORControllerConfig *)aController {
    // TODO: check what happens when multiple controllers are discovered
    
    // TODO: aController has already been added to the ORConsoleSettings collection of controller by the ServerAutoDiscoveryController but the MOC hasn't been saved. Is this OK ? Should we add here ? I think not
    [aController fetchGroupMembers];

    [self.tableView reloadData];
	// TODO: Disabled for now, see IPHONE-111 [self forceHideSpinner:NO];
}

- (void)onFindServerFail:(NSString *)errorMessage {
    // TODO: check when this is reported
    // TODO: there should be a way to get notified when the auto-discovery process is finished, not an error if nothing is found
    
	// TODO: Disabled for now, see IPHONE-111 [self forceHideSpinner:YES];
	[ViewHelper showAlertViewWithTitle:@"Auto Discovery" Message:errorMessage];	
}

#pragma mark Delegate method of UpdateController

- (void)didUpdate {
	//[self dismissViewControllerAnimated:YES completion:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:NotificationRefreshGroupsView object:nil];
}

- (void)didUseLocalCache:(NSString *)errorMessage {
	[self dismissViewControllerAnimated:NO completion:nil];
	if ([errorMessage isEqualToString:@"401"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NotificationPopulateCredentialView object:nil];
	} else {
		[ViewHelper showAlertViewWithTitle:@"Use Local Cache" Message:errorMessage];
	}
}

- (void)didUpdateFail:(NSString *)errorMessage {
	[self dismissViewControllerAnimated:NO completion:nil];
	if ([errorMessage isEqualToString:@"401"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NotificationPopulateCredentialView object:nil];
	} else {
		[ViewHelper showAlertViewWithTitle:@"Update Failed" Message:errorMessage];
	}
}

#pragma mark - ORController group members fetch notifications

- (void)orControllerGroupMembersFetchStatusChanged:(NSNotification *)notification
{
// IPHONE-107    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[settingsManager.consoleSettings.controllers indexOfObject:[notification object]] inSection:CONTROLLER_URLS_SECTION]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
}

- (void)orControllerGroupMembersFetchSucceeded:(NSNotification *)notification
{
    // IPHONE-107    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[settingsManager.consoleSettings.controllers indexOfObject:[notification object]] inSection:CONTROLLER_URLS_SECTION]] withRowAnimation:UITableViewRowAnimationNone];

    NSLog(@"controllers %lu", (unsigned long)[self.settingsManager.consoleSettings.controllers count]);
    if (!self.settingsManager.consoleSettings.selectedController && [self.settingsManager.consoleSettings.controllers count] == 1) {
        self.settingsManager.consoleSettings.selectedController = [notification object];
    }
 
    [self.tableView reloadData];
}

- (void)orControllerGroupMembersFetchRequiresAuthentication:(NSNotification *)notification
{
    [self orControllerGroupMembersFetchStatusChanged:notification];
    if (self.askUserForCredentials) {
        [self populateLoginView:notification];
    }
//    self.askUserForCredentials = NO;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.settingsDefinition.settingsDefinition count] - 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == CONTROLLER_URLS_SECTION) {
//        NSLog(@"Number of rows in table view controller section %d", [settingsManager.consoleSettings.controllers count] + 1);
		return [self.settingsManager.consoleSettings.controllers count] + 1; // custom URLs need extra cell 'Add url >'
	}
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return [self.settingsDefinition getSectionFooterWithIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	if(section >= PANEL_IDENTITY_SECTION) {
		section++;
	} 
	return [self.settingsDefinition getSectionHeaderWithIndex:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *switchCellIdentifier = @"switchCell";
	static NSString *serverCellIdentifier = @"serverCell";
	static NSString *panelCellIdentifier = @"panelCell";
	
	UITableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:switchCellIdentifier];
	TableViewCellWithSelectionAndIndicator *serverCell = (TableViewCellWithSelectionAndIndicator *)[tableView dequeueReusableCellWithIdentifier:serverCellIdentifier];
	UITableViewCell *panelCell = [tableView dequeueReusableCellWithIdentifier:panelCellIdentifier];
	
	if (switchCell == nil) {
		switchCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switchCellIdentifier];
		switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
		UISwitch *switchView = [[UISwitch alloc]init];
		switchCell.accessoryView = switchView;
	}
	if (serverCell == nil) {
		serverCell = [[TableViewCellWithSelectionAndIndicator alloc] initWithReuseIdentifier:serverCellIdentifier];
	}
	if (panelCell == nil) {
		panelCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:panelCellIdentifier];
	}
	
	if ([self isAutoDiscoverySection:indexPath]) {
		switchCell.textLabel.text = [[self.settingsDefinition getAutoDiscoveryDic] objectForKey:@"name"];
		UISwitch *switchView = (UISwitch *)switchCell.accessoryView;
		[switchView setOn:self.settingsManager.consoleSettings.autoDiscovery];
		[switchView addTarget:self action:@selector(autoDiscoverChanged:) forControlEvents:UIControlEventValueChanged];
		return switchCell;
	} else if (indexPath.section == CONTROLLER_URLS_SECTION) {
		if ([self isAddCustomServerRow:indexPath]) {
			serverCell.textLabel.text = @"Add New Controller...";
			serverCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			serverCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            serverCell.entrySelected = NO;
            serverCell.indicatorView = nil;
		} else {
            ORControllerConfig *controller = (ORControllerConfig *)[self.settingsManager.consoleSettings.controllers objectAtIndex:indexPath.row];
			serverCell.textLabel.text = controller.primaryURL;
			serverCell.selectionStyle = UITableViewCellSelectionStyleNone;
            serverCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

			if (controller == self.settingsManager.consoleSettings.selectedController) {
				self.currentSelectedServerIndex = indexPath;
                serverCell.entrySelected = YES;
			} else {
                serverCell.entrySelected = NO;
			}
            serverCell.indicatorView = [ORControllerGroupMembersFetchStatusIconProvider viewForGroupMembersFetchStatus:controller.groupMembersFetchStatus];
		}
		return serverCell;
	} else if (indexPath.section == PANEL_IDENTITY_SECTION) {
		panelCell.textLabel.text = self.settingsManager.consoleSettings.selectedController.selectedPanelIdentityDisplayString;
		panelCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		panelCell.selectionStyle = UITableViewCellSelectionStyleBlue;
		return panelCell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == CONTROLLER_URLS_SECTION) {
        ControllerDetailViewController *cdvc = [[ControllerDetailViewController alloc] initWithController:((ORControllerConfig *) self.settingsManager.consoleSettings.controllers[indexPath.row])];
        cdvc.delegate = self;
        cdvc.creating = NO;
		[[self navigationController] pushViewController:cdvc animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self isControllerRowAtIndexPath:indexPath]?UITableViewCellEditingStyleDelete:UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.settingsManager.consoleSettings removeControllerAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self isControllerRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (indexPath.section == AUTO_DISCOVERY_SWITCH_SECTION) {
		return;
	} 
	
	if ([self isAddCustomServerRow:indexPath]) {
        ControllerDetailViewController *cdvc = [[ControllerDetailViewController alloc] initWithManagedObjectContext:self.settingsManager.managedObjectContext];
        cdvc.delegate = self;
        cdvc.creating = YES;
		[[self navigationController] pushViewController:cdvc animated:YES];
		return;
	} else if (indexPath.section == PANEL_IDENTITY_SECTION) {
		if (!self.settingsManager.consoleSettings.selectedController) {
			[ViewHelper showAlertViewWithTitle:@"Warning" Message:@"No Controller. Please configure Controller URL manually."];
			cell.selected = NO;
			return;
		}
		ChoosePanelViewController *choosePanelViewController = [[ChoosePanelViewController alloc]
                                                                initWithController:self.settingsManager.consoleSettings.selectedController];
        choosePanelViewController.delegate = self;
		[[self navigationController] pushViewController:choosePanelViewController animated:YES];
		return;
	}
	
	if (indexPath.section == CONTROLLER_URLS_SECTION) {        
		if (self.currentSelectedServerIndex) {
			UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.currentSelectedServerIndex];
            ((TableViewCellWithSelectionAndIndicator *)oldCell).entrySelected = NO;
 		}
        ((TableViewCellWithSelectionAndIndicator *)cell).entrySelected = YES;

        self.settingsManager.consoleSettings.selectedController = [self.settingsManager.consoleSettings.controllers objectAtIndex:indexPath.row];
        
        self.askUserForCredentials = YES;
        
        // TODO: might not be required if update of panel identities trigger this
        [self.settingsManager.consoleSettings.selectedController fetchGroupMembers];

		if (self.currentSelectedServerIndex && self.currentSelectedServerIndex.row != indexPath.row) {            
            // !!! Panels won't fetch until capabilities are, this can cause issues of message blocked in queue
            [self.settingsManager.consoleSettings.selectedController fetchCapabilities];
            
            // TODO: review how this gets updated
			[self updatePanelIdentityView];
		}
		self.currentSelectedServerIndex = indexPath;
	}
	
}

#pragma mark - ImageCache

- (void)clearImageCache
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Are you sure you want to clear image cache ?"
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:nil];
    [alert addButtonWithTitle:@"YES"];
    [alert show];
}

#pragma mark alert delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
        [self.imageCache forgetAllImages];
	} 
}

- (BOOL)shouldAutorotate {
	return YES;
}

#pragma mark ControllerDetailViewControllerDelegate implementation

- (void)didAddController:(ORControllerConfig *)controller
{
    [self.settingsManager.consoleSettings addController:controller];
    [self.navigationController popViewControllerAnimated:YES];
//IPHONE-107    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[settingsManager.consoleSettings.controllers count] - 1 inSection:CONTROLLER_URLS_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
    
    [controller fetchGroupMembers];
}

- (void)didEditController:(ORControllerConfig *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
//IPHONE-107 : was not there but if there is no reloadData in viewWillAppear, there should be a reload of the updated row here
    [controller fetchGroupMembers];
}

- (void)didDeleteController:(ORControllerConfig *)controller
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        NSUInteger controllerIndex = [self.settingsManager.consoleSettings.controllers indexOfObject:controller];
        [self.settingsManager.consoleSettings removeControllerAtIndex:controllerIndex];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:controllerIndex inSection:CONTROLLER_URLS_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [self.navigationController popViewControllerAnimated:YES];
    [CATransaction commit];
}

- (void)didFailToAddController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ChoosePanelViewControllerDelegate implementation

- (void)didSelectPanelIdentity:(NSString *)identity
{
    self.settingsManager.consoleSettings.selectedController.selectedPanelIdentity = identity;
    [self.navigationController popViewControllerAnimated:YES];    
}

#pragma mark Panel identities fetch notifications

- (void)orControllerPanelIdentitiesFetchStatusChanged:(NSNotification *)notification
{
    ORControllerConfig *controller = [notification object];
    
    if (controller.panelIdentitiesFetchStatus == FetchSucceeded) {
        NSArray *panels = controller.panelIdentities;

        // When a controller gets selected, the list of available panels is fetched.
        // If there is only one panel available, it is automatically selected.
        UITableViewCell *identityCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:PANEL_IDENTITY_SECTION]];
        if (panels.count == 1) {
            self.settingsManager.consoleSettings.selectedController.selectedPanelIdentity = panels[0];
            identityCell.textLabel.text = self.settingsManager.consoleSettings.selectedController.selectedPanelIdentity;
        } else {
            // If there are more than one panel, try to select one by matching the panel identity with the device
            NSArray<NSString *> *candidates = [PanelMatcher filterPanelIdentities:panels forDevicePrefix:[[UIDevice currentDevice] autoSelectPrefix]];
            if (candidates.count == 1) {
                self.settingsManager.consoleSettings.selectedController.selectedPanelIdentity = candidates[0];
                identityCell.textLabel.text = self.settingsManager.consoleSettings.selectedController.selectedPanelIdentity;
            } else if (![panels containsObject:self.settingsManager.consoleSettings.selectedController.selectedPanelIdentity]) {
                self.settingsManager.consoleSettings.selectedController.selectedPanelIdentity = nil;
                identityCell.textLabel.text = @"None";
            }
        }
    }
}

#pragma mark LoginViewControllerDelegate implementation

- (void)loginViewControllerDidCancelLogin:(LoginViewController *)controller
{
    // TODO: Is this still required ?
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationHideLoading object:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginViewController:(LoginViewController *)controller didProvideUserName:(NSString *)username password:(NSString *)password
{
    id context = controller.context;
    ORControllerConfig *orController;
    if ([context isMemberOfClass:[ControllerRequest class]]) {
        orController = ((ControllerRequest *)controller.context).controller;
    } else if ([context isMemberOfClass:[ORControllerConfig class]]) {
        orController = context;
    }
    if (!orController) {
        orController = self.settingsManager.consoleSettings.selectedController;
    }
    orController.userName = username;
	orController.password = password;
    
    // TODO: we might not want to save here, maybe have a method to set this and save in dedicated MOC
    [self.settingsManager saveConsoleSettings];
    
	[self dismissViewControllerAnimated:YES completion:nil];
    
    if ([context isMemberOfClass:[ControllerRequest class]]) {
        [(ControllerRequest *)controller.context retry];
    } else {
        // By default if we don't know where we're coming from, trigger a fetch group members

        // TODO: double check fetchGroupMember is the only source that can trigger this
        // No, it is not the only source:
        // - fetchPanels will trigger this
        // - UpdateController can trigger it
        
        // TODO: put appropriate info in context so that correct call can be performed
        
        // TODO: the controller should be passed back in the message
        [self.settingsManager.consoleSettings.selectedController fetchGroupMembers];
    }
}

#pragma mark -

/**
 * Launch an auto-discovery process in the background.
 * The process is only conducted if the consoleSettings.isAutoDiscovery is true.
 */
- (void)autodiscoverControllersIfRequired
{
    if (self.settingsManager.consoleSettings.autoDiscovery) {
        // TODO: Disabled for now, see IPHONE-111 [self showSpinner];

        if (autoDiscoverController) {
            [autoDiscoverController setDelegate:nil];
             // This will cancel connections if any
            autoDiscoverController = nil;
        }
		autoDiscoverController = [[ServerAutoDiscoveryController alloc] initWithConsoleSettings:self.settingsManager.consoleSettings delegate:self];
	}
}

- (void)fetchGroupMembersForAllControllers
{
    NSLog(@">>fetchGroupMembersForAllControllers -> settingsManager.consoleSettings.controllers: %lu", (unsigned long)[self.settingsManager.consoleSettings.controllers count]);
    [self.settingsManager.consoleSettings.controllers makeObjectsPerformSelector:@selector(fetchGroupMembers)];
}

- (void)cancelFetchGroupMembers
{
    [self.settingsManager.consoleSettings.controllers makeObjectsPerformSelector:@selector(cancelGroupMembersFetch)];
}

@synthesize askUserForCredentials;
@synthesize currentSelectedServerIndex;

@end
