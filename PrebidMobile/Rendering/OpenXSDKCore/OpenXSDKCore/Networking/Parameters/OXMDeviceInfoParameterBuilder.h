//
//  OXMDeviceInfoParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMParameterBuilderProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@class OXMDeviceAccessManager;

NS_SWIFT_NAME(DeviceInfoParameterBuilder)
@interface OXMDeviceInfoParameterBuilder : NSObject <OXMParameterBuilder>

//TODO: move this properties to extensions for tests
@property (class, readonly) NSString *ifaKey;
@property (class, readonly) NSString *lmtKey;
@property (class, readonly) NSString *attsKey;
@property (class, readonly) NSString *ifvKey;


- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithDeviceAccessManager:(nonnull OXMDeviceAccessManager *)deviceAccessManager NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
