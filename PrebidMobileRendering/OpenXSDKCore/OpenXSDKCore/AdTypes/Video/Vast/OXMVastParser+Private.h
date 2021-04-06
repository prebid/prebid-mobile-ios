//
//  OXMVastParser+Private.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMVastParser.h"

@interface OXMVastParser (Private)

- (void)parseResourceForType:(OXMVastResourceType)type;
- (NSTimeInterval)parseTimeInterval:(nullable NSString *)str;

- (nullable id <OXMVastResourceContainerProtocol>)extractCreativeContainer;

@end
