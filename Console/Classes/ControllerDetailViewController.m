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

#import "ControllerDetailViewController.h"
#import "ORControllerConfig.h"
#import "ORGroupMember.h"
#import "TextFieldCell.h"
#import "StyleValue1TextEntryCell.h"
#import "ORControllerGroupMembersFetchStatusIconProvider.h"
#import "NSURLHelper.h"
#import "ORTableViewSectionDefinition.h"
#import "UITableViewHelper.h"
#import "Capabilities.h"

#define kControllerUrlCellIdentifier @"kControllerUrlCellIdentifier"
#define kGroupMemberCellIdentifier @"kGroupMemberCellIdentifier"
#define kUsernameCellIdentifier @"kUsernameCellIdentifier"
#define kPasswordCellIdentifier @"kPasswordCellIdentifier"
#define kAPIVersionsCellIdentifier @"kAPIVersionsCellIdentifier"
#define kPanelIdentityCellIdentifier @"kPanelIdentityCellIdentifier"

#define kSectionControllerURL 1
#define kSectionRoundrobinMembers 2
#define kSectionLogin 3
#define kSectionCapabilities 4
#define kSectionPanelIdentities 5

@interface ControllerDetailViewController()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) ORControllerConfig *controller;
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *urlField;
// We're using this group member property instead of accessing controller.groupMembers directly
// because we want an array to have an order to display in table view
// We observe controller.groupMembers to keep this on in sync
@property (nonatomic, strong) NSArray *groupMembers;

@property (nonatomic, assign) NSInteger currentNumberOfCapabilitiesRow;
@property (nonatomic, assign) NSInteger currentNumberOfPanelIdentitiesRow;

// Used to indicate that the done button has been clicked -> cancel management because no target/action on back button
@property (nonatomic, assign) BOOL doneAction;
@property (nonatomic, strong) NSUndoManager *previousUndoManager;
@property (nonatomic, strong) UIColor *originalTextColor;

@property (nonatomic, strong) UIView *controllerSectionHeaderView;
@property (nonatomic, strong) UILabel *controllerErrorLabel;

- (void)updateTableViewHeaderForGroupMemberFetchStatus;
- (void)refreshCapabilitiesTableViewSection;
- (void)refreshPanelIdentitiesTableViewSection;

@end

@implementation ControllerDetailViewController

- (void)initTableViewSections
{
    self.sectionDefinitions = @[// Section header for controller URL is handled by custom view so error message can be displayed
                               [[ORTableViewSectionDefinition alloc] initWithSectionIdentifier:kSectionControllerURL sectionHeader:nil sectionFooter:@"Sample:192.168.1.2:8080/controller"],
                               [[ORTableViewSectionDefinition alloc] initWithSectionIdentifier:kSectionLogin sectionHeader:@"Login:" sectionFooter:nil],
                               [[ORTableViewSectionDefinition alloc] initWithSectionIdentifier:kSectionPanelIdentities sectionHeader:@"Panel identities:" sectionFooter:nil],
                               [[ORTableViewSectionDefinition alloc] initWithSectionIdentifier:kSectionRoundrobinMembers sectionHeader:@"Roundrobin group members:" sectionFooter:nil],
                               [[ORTableViewSectionDefinition alloc] initWithSectionIdentifier:kSectionCapabilities sectionHeader:@"Controller capabilities:" sectionFooter:nil]];
}

- (id)initWithController:(ORControllerConfig *)aController
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.controller = aController;
        [self initTableViewSections];
    }
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc
{
	self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.managedObjectContext = moc;
        [self initTableViewSections];
    }
	return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        
    UIView *footerView  = [[UIView alloc] init];
    UIButton *deleteInstallBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [deleteInstallBtn setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteInstallBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    deleteInstallBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [deleteInstallBtn sizeToFit];

    [deleteInstallBtn addTarget:self action:@selector(deleteController:) forControlEvents:UIControlEventTouchUpInside];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [deleteInstallBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    } else {
        [deleteInstallBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIImage *deleteGradient = [[UIImage imageNamed:@"delete_button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 5, 1, 5)];
        [deleteInstallBtn setBackgroundImage:deleteGradient forState:UIControlStateNormal];
        CGRect frame = deleteInstallBtn.frame;
        frame.size.height = 47.0;
        [deleteInstallBtn setFrame:frame];
    }

    footerView.frame = CGRectMake(0, 0, self.view.frame.size.width, deleteInstallBtn.frame.size.height + 8.0);
    [footerView addSubview:deleteInstallBtn];
    deleteInstallBtn.center = footerView.center;
    self.tableView.tableFooterView = footerView;
    
    [self updateTableViewHeaderForGroupMemberFetchStatus];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.managedObjectContext.undoManager endUndoGrouping];

    // Prevents update of values when text field looses 1st responder
    self.urlField.delegate = nil;
    self.usernameField.delegate = nil;
    self.passwordField.delegate = nil;

    if (!self.doneAction) {
        if (!self.presentedViewController) {
            // don't undo if login view controller is presented
            [self.controller.managedObjectContext undo];
        }
    }
    self.controller.managedObjectContext.undoManager = self.previousUndoManager;
    self.previousUndoManager = nil;

    [self.controller removeObserver:self forKeyPath:@"groupMembers"];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.urlField = nil;
    self.usernameField = nil;
    self.passwordField = nil;

    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerGroupMembersFetchStatusChanged:) name:kORControllerGroupMembersFetchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerGroupMembersFetchStatusChanged:) name:kORControllerGroupMembersFetchFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerGroupMembersFetchStatusChanged:) name:kORControllerGroupMembersFetchSucceededNotification object:nil];
    // We don't present a login panel when on this page, user can use "regular" fields to enter credentials
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerGroupMembersFetchStatusChanged:) name:kORControllerGroupMembersFetchRequiresAuthenticationNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerCapabilitiesFetchStatusChanged:) name:kORControllerCapabilitiesFetchStatusChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orControllerPanelIdentitiesFetchStatusChanged:) name:kORControllerPanelIdentitiesFetchStatusChange object:nil];

    self.doneAction = NO;

    // Make sure we're delegate of text fields if they exist so we get values update
    if (self.urlField) {
        self.urlField.delegate = self;
    }
    if (self.usernameField) {
        self.usernameField.delegate = self;
    }
    if (self.passwordField) {
        self.passwordField.delegate = self;
    }

    if (self.controller) {
        self.managedObjectContext = self.controller.managedObjectContext;
    } else {
        NSAssert(self.managedObjectContext, @"If no controller was specified, a managed object context must be");
        self.controller = [NSEntityDescription insertNewObjectForEntityForName:@"ORController" inManagedObjectContext:self.managedObjectContext];
    }

    if (self.creating) {
        self.title = @"Add a Controller";
    } else {
        self.title = [NSString stringWithFormat:@"Editing %@", self.controller.primaryURL];
    }

    self.previousUndoManager = self.managedObjectContext.undoManager;
    self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
    [self.managedObjectContext.undoManager beginUndoGrouping];

    self.groupMembers = [self.controller.groupMembers allObjects];
    [self.controller addObserver:self forKeyPath:@"groupMembers" options:0 context:NULL];

    [self.controller fetchCapabilities];
    [self.controller fetchPanels];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.creating) {
        [self.urlField becomeFirstResponder];
    }
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - Actions

- (void)done:(id)sender
{
    [self.urlField resignFirstResponder];
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    if (!self.controller || !self.controller.primaryURL) {
        [self.delegate didFailToAddController];
        return;
    }
    self.doneAction = YES;
    if (self.creating) {
        [self.delegate didAddController:self.controller];      
    } else {
        [self.delegate didEditController:self.controller];
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{    
    if (textField == self.urlField) {
        NSURL *nsUrl = [NSURLHelper parseControllerURL:textField.text];
        if (!nsUrl) {
            self.urlField.textColor = [UIColor redColor];
            self.controllerErrorLabel.text = @"Invalid controller URL";
            return NO;
        }
        NSString *url = [nsUrl absoluteString];
        self.urlField.textColor = self.originalTextColor;
        self.controllerErrorLabel.text = @"";
        self.urlField.text = url;
        self.controller.primaryURL = url;
    } else if (textField == self.usernameField) {
        self.controller.userName = textField.text;
    } else if (textField == self.passwordField) {
        self.controller.password = textField.text;
    }

    [self.controller cancelGroupMembersFetch];
    self.groupMembers = nil;
    [self.controller fetchGroupMembers];
    [self.controller fetchCapabilities];
    [self.controller fetchPanels];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.controllerErrorLabel.text = @"";
    self.urlField.textColor = self.originalTextColor;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ORTableView customization methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSectionWithIdentifier:(NSInteger)sectionIdentifier
{
    switch (sectionIdentifier) {
        case kSectionControllerURL:
            return 1;
        case kSectionRoundrobinMembers:
            return [self.groupMembers count];
        case kSectionLogin:
            return 2;
        case kSectionCapabilities:
            self.currentNumberOfCapabilitiesRow = (self.controller.capabilitiesFetchStatus != FetchSucceeded)?1:(1 + [self.controller.capabilities.apiSecurities count] + [self.controller.capabilities.capabilities count]);
            return self.currentNumberOfCapabilitiesRow;
        case kSectionPanelIdentities:
            self.currentNumberOfPanelIdentitiesRow = (self.controller.panelIdentitiesFetchStatus != FetchSucceeded)?0:[self.controller.panelIdentities count];
            return self.currentNumberOfPanelIdentitiesRow;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row inSectionWithIdentifier:(NSInteger)sectionIdentifier
{
    UITableViewCell *cell = nil;
    switch (sectionIdentifier) {
        case kSectionControllerURL:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kControllerUrlCellIdentifier];
            if (cell == nil) {
                cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kControllerUrlCellIdentifier];
                self.urlField = ((TextFieldCell *)cell).textField;
                self.urlField.delegate = self;
                self.originalTextColor = self.urlField.textColor;
            }
            self.urlField.text = self.controller.primaryURL;
            break;
        }
        case kSectionRoundrobinMembers:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kGroupMemberCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGroupMemberCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }            
            cell.textLabel.text = ((ORGroupMember *)[self.groupMembers objectAtIndex:row]).url;
            break;
        }
        case kSectionLogin:
        {
            switch (row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:kUsernameCellIdentifier];
                    if (!cell) {
                        cell = [[StyleValue1TextEntryCell alloc] initWithReuseIdentifier:kUsernameCellIdentifier];
                        self.usernameField = ((TextFieldCell *)cell).textField;
                        self.usernameField.delegate = self;
                    }
                    cell.textLabel.text = @"User name";
                    ((TextFieldCell *)cell).textField.text = self.controller.userName;
                    break;
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:kPasswordCellIdentifier];
                    if (!cell) {
                        cell = [[StyleValue1TextEntryCell alloc] initWithReuseIdentifier:kPasswordCellIdentifier];
                        self.passwordField = ((TextFieldCell *)cell).textField;
                        self.passwordField.secureTextEntry = YES;
                        
                        self.passwordField.delegate = self;
                    }
                    cell.textLabel.text = @"Password";
                    ((TextFieldCell *)cell).textField.text = self.controller.password;
                    ((TextFieldCell *)cell).textField.secureTextEntry = YES;
                    break;
            }
            break;
        }
        case kSectionCapabilities:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kAPIVersionsCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kAPIVersionsCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if (row == 0) {
                cell.textLabel.text = @"Supported API versions";
                if (self.controller.capabilitiesFetchStatus != FetchSucceeded) {
                    cell.detailTextLabel.text = @"Error getting versions";
                } else {
                    if (self.controller.capabilities) {
                        cell.detailTextLabel.text = [self.controller.capabilities.supportedVersions componentsJoinedByString:@", "];
                    } else {
                        cell.detailTextLabel.text = @"Not reported by controller";
                    }
                }
            } else if (row > 0 && row <= [self.controller.capabilities.capabilities count]) {
                cell.textLabel.text = (row == 1)?@"Capabilities":@"";
                cell.detailTextLabel.text = [[self.controller.capabilities.capabilities objectAtIndex:(row - 1)] description];
            } else {
                NSInteger adjustedRow = row - [self.controller.capabilities.capabilities count] - 1;
                cell.textLabel.text = (adjustedRow == 0)?@"Security rules":@"";
                cell.detailTextLabel.text = [[self.controller.capabilities.apiSecurities objectAtIndex:adjustedRow] description];
            }
            break;
        }
        case kSectionPanelIdentities:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kPanelIdentityCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPanelIdentityCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            NSString *identity = [self.controller.panelIdentities objectAtIndex:row];
            cell.textLabel.text = identity;
            cell.accessoryType = [self.controller.selectedPanelIdentity isEqualToString:identity]?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
            break;
        }
    }
    return cell;    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
	return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self sectionIdentifierForSection:section] == kSectionControllerURL) {
        if (!self.controllerSectionHeaderView) {
            CGFloat totalWidth = tableView.frame.size.width;
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, totalWidth)];
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 11.0, (totalWidth / 2.0) - 54.0, 21.0)];
            l.text = @"Controller URL:";
            l.font = [UIFont boldSystemFontOfSize:17];
            l.textColor = [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1.0];
            l.backgroundColor = [UIColor clearColor];
            [v addSubview:l];
            l = [[UILabel alloc] initWithFrame:CGRectMake(totalWidth / 2.0, 11.0, (totalWidth / 2.0) - 54.0, 21.0)];
            l.font = [UIFont boldSystemFontOfSize:17];
            l.textColor = [UIColor redColor];
            l.backgroundColor = [UIColor clearColor];
            l.textAlignment = NSTextAlignmentRight;
            [v addSubview:l];
            self.controllerErrorLabel = l;
            self.controllerSectionHeaderView = v;
        }
        return self.controllerSectionHeaderView;
    }
    return nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // Only observing one value, no need to check
    self.groupMembers = [self.controller.groupMembers allObjects];
}

#pragma mark - ORController group members fetch notifications

- (void)orControllerGroupMembersFetchStatusChanged:(NSNotification *)notification
{
    [self updateTableViewHeaderForGroupMemberFetchStatus];
}

- (void)orControllerCapabilitiesFetchStatusChanged:(NSNotification *)notification
{
    [self refreshCapabilitiesTableViewSection];
}

- (void)orControllerPanelIdentitiesFetchStatusChanged:(NSNotification *)notification
{
    [self refreshPanelIdentitiesTableViewSection];
}

#pragma mark - Utility methods

- (void)updateTableViewHeaderForGroupMemberFetchStatus
{
    UIView *statusView = [ORControllerGroupMembersFetchStatusIconProvider viewForGroupMembersFetchStatus:self.controller.groupMembersFetchStatus];
    CGRect sectionBounds = [self.tableView rectForSection:[self sectionWithIdentifier:kSectionControllerURL]];
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(sectionBounds.origin.x, 0.0, sectionBounds.size.width, 40.0)];
    // Status view is centered but with a 12 points offset from top. Also offset 44 from right border to align on rows' border
    statusView.frame = CGRectMake(sectionBounds.size.width - statusView.frame.size.width - 44.0, (int)(12.0 + (aView.frame.size.height - statusView.frame.size.height)/ 2.0), statusView.frame.size.width, statusView.frame.size.height);
    [aView addSubview:statusView];
    self.tableView.tableHeaderView = aView;
}

- (void)refreshCapabilitiesTableViewSection
{    
    NSInteger plannedRowCount = (self.controller.capabilitiesFetchStatus != FetchSucceeded)?1:(1 + [self.controller.capabilities.apiSecurities count] + [self.controller.capabilities.capabilities count]);
    [self.tableView beginUpdates];
    NSInteger section = [self sectionWithIdentifier:kSectionCapabilities];
    if (plannedRowCount != self.currentNumberOfCapabilitiesRow) {
        NSArray *rows = [UITableViewHelper indexPathsForRowCountGoingFrom:self.currentNumberOfCapabilitiesRow to:plannedRowCount section:section];
        if (plannedRowCount > self.currentNumberOfCapabilitiesRow) {
            [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
         } else {
             [self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
         }
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)refreshPanelIdentitiesTableViewSection
{
    NSInteger plannedRowCount = (self.controller.panelIdentitiesFetchStatus != FetchSucceeded)?0:[self.controller.panelIdentities count];    
    if (plannedRowCount != self.currentNumberOfPanelIdentitiesRow) {
        NSInteger section = [self sectionWithIdentifier:kSectionPanelIdentities];
        [self.tableView beginUpdates];
        NSArray *rows = [UITableViewHelper indexPathsForRowCountGoingFrom:self.currentNumberOfPanelIdentitiesRow to:plannedRowCount section:section];
        if (plannedRowCount > self.currentNumberOfPanelIdentitiesRow) {
            [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
    }
}

- (void)deleteController:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Delete controller" message:@"Are you sure you want to delete this controller?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
        [self.delegate didDeleteController:self.controller];
	} 
}

@synthesize delegate;
@synthesize managedObjectContext;
@synthesize controller;
@synthesize groupMembers;
@synthesize currentNumberOfCapabilitiesRow;
@synthesize currentNumberOfPanelIdentitiesRow;
@synthesize usernameField;
@synthesize passwordField;
@synthesize urlField;
@synthesize doneAction;
@synthesize creating;
@synthesize previousUndoManager;
@synthesize originalTextColor;
@synthesize controllerSectionHeaderView;
@synthesize controllerErrorLabel;

- (void)setGroupMembers:(NSArray *)theGroupMembers
{
    if (groupMembers != theGroupMembers) {
        NSUInteger oldCount = [groupMembers count];
        NSUInteger newCount = [theGroupMembers count];
        
        groupMembers = theGroupMembers;
        
        [self.tableView beginUpdates];
        NSArray *rows = [UITableViewHelper indexPathsForRowCountGoingFrom:oldCount to:newCount section:[self sectionWithIdentifier:kSectionRoundrobinMembers]];
        if (newCount > oldCount) {
            [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
    }
}

@end