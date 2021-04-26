//
//  PBMORTBParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMParameterBuilderProtocol.h"

@interface PBMORTBParameterBuilder : NSObject

+ (NSDictionary<NSString *, NSString *> *)buildOpenRTBFor:(PBMORTBBidRequest *)bidRequest;

@end
