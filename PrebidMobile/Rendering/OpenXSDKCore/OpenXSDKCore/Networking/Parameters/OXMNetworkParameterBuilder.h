//
//  OXMNetworkParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "OXMParameterBuilderProtocol.h"
#import "OXMReachability.h"

NS_SWIFT_NAME(NetworkParameterBuilder)
@interface OXMNetworkParameterBuilder : NSObject <OXMParameterBuilder>

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithCtTelephonyNetworkInfo:(nonnull CTTelephonyNetworkInfo *)ctTelephonyNetworkInfo reachability:(nonnull OXMReachability *)reachability NS_DESIGNATED_INITIALIZER;

@end
