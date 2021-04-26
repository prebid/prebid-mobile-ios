//
//  PBMVastParser+Private.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMVastParser.h"

@interface PBMVastParser (Private)

- (void)parseResourceForType:(PBMVastResourceType)type;
- (NSTimeInterval)parseTimeInterval:(nullable NSString *)str;

- (nullable id <PBMVastResourceContainerProtocol>)extractCreativeContainer;

@end
