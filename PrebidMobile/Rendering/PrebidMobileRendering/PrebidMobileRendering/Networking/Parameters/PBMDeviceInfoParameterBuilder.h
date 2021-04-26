//
//  PBMDeviceInfoParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMParameterBuilderProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class PBMDeviceAccessManager;

NS_SWIFT_NAME(DeviceInfoParameterBuilder)
@interface PBMDeviceInfoParameterBuilder : NSObject <PBMParameterBuilder>

//TODO: move this properties to extensions for tests
@property (class, readonly) NSString *ifaKey;
@property (class, readonly) NSString *lmtKey;
@property (class, readonly) NSString *attsKey;
@property (class, readonly) NSString *ifvKey;


- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithDeviceAccessManager:(nonnull PBMDeviceAccessManager *)deviceAccessManager NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
