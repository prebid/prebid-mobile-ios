//
//  OXMLocationManagerProtocol.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol OXMLocationManagerProtocol <NSObject>

@property(assign, nonatomic, nullable) id<CLLocationManagerDelegate> delegate;
@property(readonly, nonatomic, copy, nullable) CLLocation *location;
@property(assign, nonatomic) CLLocationDistance distanceFilter;
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
