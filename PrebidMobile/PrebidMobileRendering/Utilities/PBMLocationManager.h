/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol PBMLocationManagerProtocol;
@protocol PBMNSThreadProtocol;

@interface PBMLocationManager : NSObject

@property (class, readonly, nonnull) PBMLocationManager *shared;

@property (assign, readonly) CLLocationCoordinate2D coordinates;
@property (assign, readonly) CLLocationAccuracy horizontalAccuracy;
@property (nonatomic, readonly, nullable, copy) NSDate *timestamp;
@property (assign, readonly) BOOL coordinatesAreValid;
@property (nonatomic, assign) BOOL locationUpdatesEnabled;

#pragma mark - DI
- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithThread:(nonnull id<PBMNSThreadProtocol>)thread;
- (nonnull instancetype)initWithLocationManager:(nonnull id<PBMLocationManagerProtocol>)locationManager;

@end
