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
#import "ORConsoleSettingsManager.h"
#import "DirectoryDefinition.h"
#import "ORConsoleSettings.h"
#import "ORControllerConfig.h"
#import "ORControllerProxy.h"


// TODO: error handling

@implementation ORConsoleSettingsManager


#pragma mark

- (ORControllerProxy *)currentController
{
    return self.consoleSettings.selectedController.proxy;
}

#pragma mark ORConsoleSettings management

- (ORConsoleSettings *)consoleSettings
{
    if (!consoleSettings) {
        log4Info(@"console settings not loaded");
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:@"ORConsoleSettings" inManagedObjectContext:self.managedObjectContext];
        NSError *error = nil;
        consoleSettings = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] lastObject];
        if (error) {
            NSLog(@"Error reading %@", error);
            // TODO: handle error
        }
        NSLog(@"Console settings read %@", consoleSettings);
        NSLog(@"auto discover %d ", consoleSettings.autoDiscovery);
        if (!consoleSettings) {
            NSLog(@"Console settings non existant in DB, creating one");
            consoleSettings = [NSEntityDescription insertNewObjectForEntityForName:@"ORConsoleSettings" inManagedObjectContext:self.managedObjectContext];

            // We add the public default controller to the list but we don't select it
            // For now, we let the user choose the controller to use
            // TODO: Final goal is use the local controller is auto-discovered, use the public one otherwise
            ORControllerConfig *controller = [NSEntityDescription insertNewObjectForEntityForName:@"ORController" inManagedObjectContext:self.managedObjectContext];
            controller.primaryURL = @"http://demo.openremote.com:8688/controller";
            [consoleSettings addController:controller];
            
            [self saveConsoleSettings];
        }
    }
    return consoleSettings;
}

- (void)saveConsoleSettings
{
    NSLog(@"Asked to save console settings");
    NSLog(@"auto discover %d ", consoleSettings.autoDiscovery);
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Could not save console settings %@", error);
        // TODO
    }
    NSLog(@"out of save console settings");
}

- (void)cancelConsoleSettingsChanges
{
    [self.managedObjectContext rollback];
}

#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
	// Initializing with URL instead of mergedModelFromBundles. If later used, exception thrown during save if validation errors instead of returning an error
	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ORConsoleSettings" ofType:@"momd"]]];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[DirectoryDefinition applicationDocumentsDirectory] stringByAppendingPathComponent: @"ORConsoleSettings.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl
														options:@{NSMigratePersistentStoresAutomaticallyOption : [NSNumber numberWithBool:YES],
                                                                  NSInferMappingModelAutomaticallyOption : [NSNumber numberWithBool:YES]}
                                                          error:&error]) {

                                                            NSLog(@"Error %@", error);
                                                        // TODO
                                                        

    }
	
    return persistentStoreCoordinator;
}

@synthesize currentController;

@end