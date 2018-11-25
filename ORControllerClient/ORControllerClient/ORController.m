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

#import "ORController.h"
#import "ORControllerAddress.h"
#import "ORPanelDefinitionSensorRegistry.h"
#import "ORDeviceModelSensorRegistry.h"
#import "ORSensorPollingManager.h"
#import "ORSensor.h"
#import "ORPanel.h"
#import "Definition.h"
#import "Definition_Private.h"

#import "ORLabel.h"
#import "ORButton.h"
#import "ORSwitch.h"
#import "ORSlider.h"
#import "ORColorPicker.h"
#import "ORGesture.h"

#import "ControllerREST_2_0_0_API.h"
#import "ORDevice.h"
#import "ORDeviceSensor.h"
#import "Sequencer.h"
#import "ORControllerDeviceModel_Private.h"
#import "ORDeviceCommand.h"

@interface ORController ()

@property (strong, nonatomic) ORControllerAddress *address;
@property (nonatomic) BOOL connected;

@property (nonatomic, strong) ORSensorPollingManager *pollingManager;

@property (nonatomic, strong) Definition *lastPanelDefinition;

@property (nonatomic, strong) ControllerREST_2_0_0_API *controllerAPI;

- (void)controlForWidget:(ORWidget *)widget action:(NSString *)action;

/**
 * Request the full devices list in the configuration of the controller
 */
- (void)requestDevicesListWithSuccessHandler:(void (^)(NSArray *))successHandler errorHandler:(void (^)(NSError *))errorHandler;

/**
 * Request a device
 */
- (void)requestDevice:(ORDevice *)device withSuccessHandler:(void (^)(ORDevice *theDevice))successHandler errorHandler:(void (^)(NSError *))errorHandler;

@end

@implementation ORController

- (instancetype)initWithControllerAddress:(ORControllerAddress *)anAddress
{
    self = [super init];
    if (self) {
        if (anAddress) {
            self.address = anAddress;

            // TODO: later based on information gathered during connect, would select the appropriate API/Object Model version
            // at that time, this should move to connect method
            self.controllerAPI = [[ControllerREST_2_0_0_API alloc] init];
            
            self.pollingManager = [[ORSensorPollingManager alloc] initWithControllerAPI:self.controllerAPI controllerAddress:self.address];
        } else {
            return nil;
        }
    }
    return self;
}

- (void)connectWithSuccessHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSError *))errorHandler;
{
    // In this first version, we actually do not try to connect at this stage but wait for read configuration request
    
    // TODO: in next version, could fetch group members
    // TODO: in later version, this could be a good place to get the controller capabilities

    self.connected = YES;
    
    // If we have a panel definition, (re-)start polling for model changes
    if (self.lastPanelDefinition) {
        // Make sure we have latest version of authentication manager set on API before call
        self.controllerAPI.authenticationManager = self.authenticationManager;
        
        [self.pollingManager addSensorRegistry:self.lastPanelDefinition.sensorRegistry];
    }
    [self.pollingManager start];
    if (successHandler) {
        successHandler();
    }
}

- (void)disconnect
{
    [self.pollingManager stop];
    
    self.connected = NO;
}

- (BOOL)isConnected
{
    return self.connected;
}

- (void)requestPanelIdentityListWithSuccessHandler:(void (^)(NSArray *))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    // Make sure we have latest version of authentication manager set on API before call
    self.controllerAPI.authenticationManager = self.authenticationManager;

    dispatch_queue_t originalQueue = dispatch_get_current_queue();
    
    [self.controllerAPI requestPanelIdentityListAtBaseURL:self.address.primaryURL
                                  withSuccessHandler:^(NSArray *panels) {
                                      dispatch_async(originalQueue, ^() {
                                          successHandler(panels);
                                      });
                                  }
                                        errorHandler:^(NSError *error) {
                                            if (errorHandler) {
                                                dispatch_async(originalQueue, ^() {
                                                    // TODO: encapsulate error ?
                                                    errorHandler(error);
                                                });
                                            }
                                        }];
}


// The returned Definition (should rename to PanelUILayout or something) will be connected to controller
// and update dynamically as required / instructed by controller.
// => this call should start the polling loop -> ORController object has responsibility for that -> should be a specific call for it / object dedicated to handling that
// Sensor registry is part of the PanelUILayout as it's a passive register, it basically maintains links
// Sensor update (cache ?) is part of ORController and has the logic to perform the updates based on values received
// Should the PanelUILayout contain the images / resources ?
- (void)requestPanelUILayout:(NSString *)panelName successHandler:(void (^)(Definition *))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    // TODO: what if not connected, how to handle that: either report as an error or try to connect
    // but define it, document it and test/handle as appropriate in this implementation
    
    // TODO: if we already had a configuration and sensor polling going, we need to stop it
    // Maybe wait to have received new configuration before doing it ?

    
    // TODO: this might be where the caching and resource fetching can take place ?
    
    // Following call returns an ORRestCall
    // -> it could return it but not start it
    // -> we can queue it, then start it ourself
    // -> we can also return to caller -> they can cancel call
    
    // Make sure we have latest version of authentication manager set on API before call
    self.controllerAPI.authenticationManager = self.authenticationManager;
    
    dispatch_queue_t originalQueue = dispatch_get_current_queue();

    [self.controllerAPI requestPanelLayoutWithLogicalName:panelName
                                           atBaseURL:self.address.primaryURL
                                  withSuccessHandler:^(Definition *panelDefinition) {
                                      [self attachPanelDefinition:panelDefinition];
                                      dispatch_async(originalQueue, ^() {
                                          successHandler(panelDefinition);
                                      });
                                  }
                                        errorHandler:^(NSError *error) {
                                            if (errorHandler) {
                                                dispatch_async(originalQueue, ^() {
                                                    // TODO: encapsulate error ?
                                                    errorHandler(error);
                                                });
                                            }
                                        }];
}

- (void)attachPanelDefinition:(Definition *)panelDefinition
{
    if (self.lastPanelDefinition) {
        self.lastPanelDefinition.controller = nil;
    }
    self.lastPanelDefinition = panelDefinition;
    panelDefinition.controller = self;
    [self.pollingManager stop];
    [self.pollingManager removeSensorRegistry:self.lastPanelDefinition.sensorRegistry];
    // Make sure we have latest version of authentication manager set on API before call
    self.controllerAPI.authenticationManager = self.authenticationManager;

    [self.pollingManager addSensorRegistry:panelDefinition.sensorRegistry];
    if (self.isConnected) {
      [self.pollingManager start];
    }
}

- (void)requestDeviceModelWithSuccessHandler:(void (^)(ORControllerDeviceModel *))successHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    // Make sure we have latest version of authentication manager set on API before call
    self.controllerAPI.authenticationManager = self.authenticationManager;

    dispatch_queue_t originalQueue = dispatch_get_current_queue();

    Sequencer *sequencer = [[Sequencer alloc] init];
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        [self.controllerAPI requestDevicesListAtBaseURL:self.address.primaryURL
                                     withSuccessHandler:^(NSArray *devices) {
                                         completion(devices);
                                     }
                                           errorHandler:^(NSError *error) {
                                               if (errorHandler) {
                                                   dispatch_async(originalQueue, ^() {
                                                       // TODO: encapsulate error ?
                                                       errorHandler(error);
                                                   });
                                               }
                                           }];
    }];
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        ORControllerDeviceModel *deviceModel = [[ORControllerDeviceModel alloc] initWithDevices:result];
        // queue requests for each device
        [deviceModel.devices enumerateObjectsUsingBlock:^(ORDevice *device, NSUInteger idx, BOOL *stop) {
            [sequencer enqueueStep:[self deviceRequestStepForDevice:device errorHandler:errorHandler originalQueue:originalQueue]];
        }];
        // queue request for success
        [sequencer enqueueStep:^(id successResult, SequencerCompletion successCompletion) {
            
            // Create registry for all sensors and start the polling manager if required
            
            ORDeviceModelSensorRegistry *registry = [[ORDeviceModelSensorRegistry alloc] init];
            for (ORDevice *device in deviceModel.devices) {
                for (ORDeviceSensor *deviceSensor in device.sensors) {
                    [registry registerSensor:[[ORSensor alloc] initWithIdentifier:deviceSensor.identifier] linkedToORDeviceSensor:deviceSensor];
                }
            }
            [self.pollingManager addSensorRegistry:registry];
            if (self.isConnected) {
                [self.pollingManager start];
            }
            
            dispatch_async(originalQueue, ^() {
                if (successHandler) {
                    successHandler(deviceModel);
                }
            });
        }];
        completion(nil);
    }];
    [sequencer run];
}

- (void)requestDevicesListWithSuccessHandler:(void (^)(NSArray *))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    // Make sure we have latest version of authentication manager set on API before call
    self.controllerAPI.authenticationManager = self.authenticationManager;

    dispatch_queue_t originalQueue = dispatch_get_current_queue();

    [self.controllerAPI requestDevicesListAtBaseURL:self.address.primaryURL
                                       withSuccessHandler:^(NSArray *devices) {
                                           dispatch_async(originalQueue, ^() {
                                               successHandler(devices);
                                           });
                                       }
                                             errorHandler:^(NSError *error) {
                                                 if (errorHandler) {
                                                     dispatch_async(originalQueue, ^() {
                                                         // TODO: encapsulate error ?
                                                         errorHandler(error);
                                                     });
                                                 }
                                             }];

}

- (void)requestDevice:(ORDevice *)device withSuccessHandler:(void (^)(ORDevice *theDevice))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    // Make sure we have latest version of authentication manager set on API before call
    self.controllerAPI.authenticationManager = self.authenticationManager;

    dispatch_queue_t originalQueue = dispatch_get_current_queue();

    [self.controllerAPI requestDevice:device
                              baseURL:self.address.primaryURL
                   withSuccessHandler:^(ORDevice *theDevice) {
                       dispatch_async(originalQueue, ^() {
                           successHandler(theDevice);
                       });
                   }
                         errorHandler:^(NSError *error) {
                             if (errorHandler) {
                                 dispatch_async(originalQueue, ^() {
                                     // TODO: encapsulate error ?
                                     errorHandler(error);
                                 });
                             }
                         }];

}

- (void)executeCommand:(ORDeviceCommand *)command withParameter:(NSString *)parameter successHandler:(void (^)())successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    // Make sure we have latest version of authentication manager set on API before call
    self.controllerAPI.authenticationManager = self.authenticationManager;

    dispatch_queue_t originalQueue = dispatch_get_current_queue();

    [self.controllerAPI executeCommand:command
                             parameter:parameter
                               baseURL:self.address.primaryURL
                    withSuccessHandler:^(NSArray *array) {
        if (successHandler) {
            dispatch_async(originalQueue, ^{
                successHandler();
            });
        }
    }                     errorHandler:^(NSError *error) {
        if (errorHandler) {
            dispatch_async(originalQueue, ^{
                errorHandler(error);
            });
        }

    }];
}


- (void)retrieveResourceNamed:(NSString *)resourceName successHandler:(void (^)(NSData *))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    // Make sure we have latest version of authentication manager set on API before call
    self.controllerAPI.authenticationManager = self.authenticationManager;
    
    dispatch_queue_t originalQueue = dispatch_get_current_queue();

    [self.controllerAPI retrieveResourceNamed:resourceName
                                    atBaseURL:self.address.primaryURL
                           withSuccessHandler:^(NSData *resource) {
                               dispatch_async(originalQueue, ^() {
                                   successHandler(resource);
                               });
                           }
                                 errorHandler:^(NSError *error) {
                                     if (errorHandler) {
                                         dispatch_async(originalQueue, ^() {
                                             // TODO: encapsulate error ?
                                             errorHandler(error);
                                         });
                                     }
                                 }];
}

- (void)sendPressCommandForButton:(ORButton *)sender
{
    [self controlForWidget:sender action:@"click"];
    
    // TODO : must implement differently for 2.1
}

- (void)sendShortReleaseCommandForButton:(ORButton *)sender
{
    // TODO : nothing for 2.0 API but must implement for 2.1
}

- (void)sendLongPressCommandForButton:(ORButton *)sender
{
    // TODO : nothing for 2.0 API but must implement for 2.1
}

- (void)sendLongReleaseCommandForButton:(ORButton *)sender
{
    // TODO : nothing for 2.0 API but must implement for 2.1
}

- (void)controlForWidget:(ORWidget *)widget action:(NSString *)action
{
    // Make sure we have latest version of authentication manager set on API before call
    self.controllerAPI.authenticationManager = self.authenticationManager;

    // TODO: success and error handlers
    [self.controllerAPI controlForWidget:widget action:action atBaseURL:self.address.primaryURL withSuccessHandler:NULL errorHandler:NULL];
}

- (void)sendOnForSwitch:(ORSwitch *)sender
{
    [self controlForWidget:sender action:@"on"];
}

- (void)sendOffForSwitch:(ORSwitch *)sender
{
    [self controlForWidget:sender action:@"off"];
}

- (void)sendValue:(float)value forSlider:(ORSlider *)sender
{
    [self controlForWidget:sender action:[NSString stringWithFormat:@"%d", (int)value]];
}

- (void)sendColor:(UIColor *)color forPicker:(ORColorPicker *)sender
{
    const CGFloat *c = CGColorGetComponents(color.CGColor);
    [self controlForWidget:sender action:[NSString stringWithFormat:@"%02x%02x%02x", (int)(c[0]*255), (int)(c[1]*255), (int)(c[2]*255)]];
}

- (void)performGesture:(ORGesture *)sender
{
    [self controlForWidget:sender action:@"swipe"];
}

- (void)dealloc
{
    [self disconnect];
}

#pragma mark - private

- (void (^)(id, SequencerCompletion))deviceRequestStepForDevice:(ORDevice *)device errorHandler:(void (^)(NSError *))errorHandler originalQueue:(dispatch_queue_t)originalQueue
{
    return ^(id deviceResult, SequencerCompletion deviceCompletion) {
        [self.controllerAPI requestDevice:device
                                  baseURL:self.address.primaryURL
                       withSuccessHandler:^(ORDevice *currentDevice) {
                           deviceCompletion(nil);
                       } errorHandler:^(NSError *error) {
                    if (errorHandler) {
                        dispatch_async(originalQueue, ^() {
                            // TODO: encapsulate error ?
                            errorHandler(error);
                        });
                    }
                }];
    };
}


@end