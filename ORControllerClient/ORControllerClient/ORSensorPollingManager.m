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

#import "ORSensorPollingManager.h"
#import "ORControllerAddress.h"
#import "ORSensorRegistry.h"
#import "ORSensorLink.h"
#import "ORObjectIdentifier.h"
#import "ORSensorStatesMapping.h"
#import "ORRESTCall.h"
#import "ORControllerRESTAPI.h"
#import "UIDevice+ORUDID.h"

typedef void (^PollingBlock)();

@interface ORSensorPollingManager ()

@property (nonatomic, strong) ORControllerRESTAPI *_controllerAPI;
@property (nonatomic, strong) ORControllerAddress *_controllerAddress;
@property (nonatomic, strong) NSMutableArray *_sensorRegistries;

@property (atomic, strong) ORRESTCall *_currentCall;

// This will be non nil when a polling is underway
@property (atomic, strong) PollingBlock sensorPollingBlock;

@end

@implementation ORSensorPollingManager

- (instancetype)initWithControllerAPI:(ORControllerRESTAPI *)api
                    controllerAddress:(ORControllerAddress *)controllerAddress
{
    self = [super init];
    if (self) {
        self._controllerAPI = api;
        self._controllerAddress = controllerAddress;
        self._sensorRegistries = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addSensorRegistry:(ORSensorRegistry *)sensorRegistry
{
    BOOL needsRestart = NO;
    if (self.sensorPollingBlock) {
       [self stop];
       needsRestart = YES;
    }
    [self._sensorRegistries addObject:sensorRegistry];
    if (needsRestart) {
      [self start];
    }
}

- (void)removeSensorRegistry:(ORSensorRegistry *)sensorRegistry
{
    BOOL needsRestart = NO;
    if (self.sensorPollingBlock) {
        [self stop];
        needsRestart = YES;
    }
    [self._sensorRegistries removeObject:sensorRegistry];
    if (needsRestart) {
        [self start];
    }
}


// TODO: Q ? how are error reported on start, during poll ?
// delegate ?
// do we also have some isPolling flag ?

- (void)start
{
    // If polling is already underway, don't start again
    if (self.sensorPollingBlock) {
        return;
    }
    
    // Only poll if there are sensors to poll
    if (![[self allSensorIdentifiers] count]) {
        return;
    }

    __weak typeof(self)weakSelf = self;
    
    self.sensorPollingBlock = ^{
        weakSelf._currentCall = [weakSelf._controllerAPI pollSensorIdentifiers:[weakSelf allSensorIdentifiers]
                                fromDeviceWithIdentifier:[[UIDevice currentDevice] or_uniqueID]
                                               atBaseURL:weakSelf._controllerAddress.primaryURL
                                      withSuccessHandler:^(NSDictionary *sensorValues) {
                                          for (ORSensorRegistry *sensorRegistry in weakSelf._sensorRegistries) {
                                              [sensorRegistry updateWithSensorValues:sensorValues];
                                          }
                                          
//                                          NSLog(@"poll got values");
                                          
                                          // TODO: fix the memory management issue
                                          
                                          weakSelf.sensorPollingBlock();
                                      } errorHandler:^(NSError *error) {
                                          // Timeout is "mechanism" used by server push, simply poll again
                                          if ([kORClientErrorDomain isEqualToString:error.domain]) {
                                              if (error.code == 504) { // HTTP timeout
                                                  weakSelf.sensorPollingBlock();
                                              }
                                          } else {
                                              NSLog(@"poll error %@", error);
                                              
                                              // TODO: report the error -> most probably delegate methods
                                              
                                              // This stops the polling, nil the block to indicate that
                                              weakSelf.sensorPollingBlock = nil;
                                          }
                                      }];
    };

    self._currentCall = [weakSelf._controllerAPI statusForSensorIdentifiers:[weakSelf allSensorIdentifiers]
                            atBaseURL:weakSelf._controllerAddress.primaryURL
                   withSuccessHandler:^(NSDictionary *sensorValues) {
                       for (ORSensorRegistry *sensorRegistry in weakSelf._sensorRegistries) {
                           [sensorRegistry updateWithSensorValues:sensorValues];
                       }
                       weakSelf.sensorPollingBlock();
                   }
                         errorHandler:^(NSError *error) {
                         }];
}

- (void)stop
{
    [self._currentCall cancel];
    self._currentCall = nil;
    // TODO: make sure we don't loop -> cancel might be enough if we make sure we don't restart polling (e.g. have a Cancelled error)
    self.sensorPollingBlock = nil;
}

- (NSSet *)allSensorIdentifiers
{
    NSMutableSet *allSensorIdentifiers = [[NSMutableSet alloc] init];
    for (ORSensorRegistry *sensorRegistry in self._sensorRegistries) {
        [allSensorIdentifiers unionSet:[sensorRegistry sensorIdentifiers]];
    }
    return allSensorIdentifiers;
}

@end
