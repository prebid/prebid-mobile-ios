//
//  OXMORTBParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMParameterBuilderProtocol.h"

@interface OXMORTBParameterBuilder : NSObject

+ (NSDictionary<NSString *, NSString *> *)buildOpenRTBFor:(OXMORTBBidRequest *)bidRequest;

@end
