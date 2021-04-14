//
//  OXMLocationManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OXMLocationManagerProtocol.h"
#import "OXMNSThreadProtocol.h"

@interface OXMLocationManager : NSObject

@property (class, readonly, nonnull) OXMLocationManager *singleton;

@property (assign, readonly) CLLocationCoordinate2D coordinates;
@property (assign, readonly) CLLocationAccuracy horizontalAccuracy;
@property (nonatomic, readonly, nullable, copy) NSDate *timestamp;
@property (assign, readonly) BOOL coordinatesAreValid;
@property (nonatomic, assign) BOOL locationUpdatesEnabled;

#pragma mark - DI
- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithThread:(nonnull id<OXMNSThreadProtocol>)thread;
- (nonnull instancetype)initWithLocationManager:(nonnull id<OXMLocationManagerProtocol>)locationManager;

@end
