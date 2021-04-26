//
//  PBMNetworkParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "PBMParameterBuilderProtocol.h"
#import "PBMReachability.h"

NS_SWIFT_NAME(NetworkParameterBuilder)
@interface PBMNetworkParameterBuilder : NSObject <PBMParameterBuilder>

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithCtTelephonyNetworkInfo:(nonnull CTTelephonyNetworkInfo *)ctTelephonyNetworkInfo reachability:(nonnull PBMReachability *)reachability NS_DESIGNATED_INITIALIZER;

@end
